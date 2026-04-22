import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../notifications/notification_service.dart';
import '../data/user_settings.dart';
import '../domain/models/daily_plan.dart';
import '../domain/scheduler.dart';

class TodayState {
  final UserSettings settings;
  final DailyPlan? todayPlan;
  final List<CompletedPortion> rabtPortions;
  final List<DailyPlan> incompleteBefore;

  const TodayState({
    required this.settings,
    required this.todayPlan,
    required this.rabtPortions,
    required this.incompleteBefore,
  });

  bool get isMemorizationDayToday => todayPlan != null;
  bool get hasMissedDays => incompleteBefore.isNotEmpty;

  TodayState copyWith({
    UserSettings? settings,
    DailyPlan? todayPlan,
    bool clearTodayPlan = false,
    List<CompletedPortion>? rabtPortions,
    List<DailyPlan>? incompleteBefore,
  }) =>
      TodayState(
        settings: settings ?? this.settings,
        todayPlan: clearTodayPlan ? null : (todayPlan ?? this.todayPlan),
        rabtPortions: rabtPortions ?? this.rabtPortions,
        incompleteBefore: incompleteBefore ?? this.incompleteBefore,
      );
}

class PlanController extends AsyncNotifier<TodayState> {
  @override
  Future<TodayState> build() async {
    // ننتظر إتاحة البيانات الأساسية.
    await ref.watch(databaseProvider.future);
    await ref.watch(quranMetaProvider.future);
    return _loadState();
  }

  Future<TodayState> _loadState() async {
    final settings = await ref.read(settingsRepositoryProvider).read();
    if (settings == null || !settings.onboarded) {
      return TodayState(
        settings: settings ?? UserSettings.defaults(),
        todayPlan: null,
        rabtPortions: const [],
        incompleteBefore: const [],
      );
    }

    final scheduler = ref.read(schedulerProvider);
    final today = dateOnly(DateTime.now());
    final planRepo = ref.read(planRepositoryProvider);

    DailyPlan? todayPlan;
    if (scheduler.isMemorizationDay(today, settings.memorizationWeekdays)) {
      todayPlan = await planRepo.readByDate(today) ??
          await _generateTodayPlan(settings, scheduler, today);
    }

    final rabt = await planRepo.readLastCompleted(settings.rabtCount);
    final missed = await planRepo.readIncompleteBefore(today);

    return TodayState(
      settings: settings,
      todayPlan: todayPlan,
      rabtPortions: rabt,
      incompleteBefore: missed,
    );
  }

  Future<DailyPlan> _generateTodayPlan(
    UserSettings settings,
    Scheduler scheduler,
    DateTime today,
  ) async {
    final start = settings.currentPosition;
    final end = scheduler.computeNisabEnd(start, settings.dailyAmountWajh);
    final plan = DailyPlan(
      date: today,
      nisabStart: start,
      nisabEnd: end,
    );
    await ref.read(planRepositoryProvider).upsert(plan);
    return plan;
  }

  Future<void> toggleTask(_TaskKind kind, bool value) async {
    final current = state.valueOrNull;
    final plan = current?.todayPlan;
    if (plan == null) return;

    final updated = switch (kind) {
      _TaskKind.nisab => plan.copyWith(nisabDone: value),
      _TaskKind.takrar => plan.copyWith(takrarDone: value),
      _TaskKind.rabt => plan.copyWith(rabtDone: value),
    };

    if (updated.allDone && plan.completedAt == null) {
      await _finalizePlan(updated, current!);
    } else {
      await ref.read(planRepositoryProvider).upsert(updated);
      state = AsyncData(current!.copyWith(todayPlan: updated));
    }
  }

  Future<void> _finalizePlan(DailyPlan plan, TodayState current) async {
    final stamped = plan.copyWith(completedAt: DateTime.now());
    final planRepo = ref.read(planRepositoryProvider);
    await planRepo.upsert(stamped);

    // سجّل النصاب في completed_portions
    await planRepo.appendCompleted(
      CompletedPortion(
        completedDate: stamped.date,
        start: stamped.nisabStart,
        end: stamped.nisabEnd,
      ),
    );

    // قدّم currentPosition إلى الآية التالية
    final scheduler = ref.read(schedulerProvider);
    final nextStart = scheduler.advanceFrom(stamped.nisabEnd);
    final updatedSettings = current.settings.copyWith(
      currentPosition: nextStart ?? stamped.nisabEnd,
    );
    await ref.read(settingsRepositoryProvider).write(updatedSettings);

    final rabt = await planRepo.readLastCompleted(updatedSettings.rabtCount);
    state = AsyncData(
      current.copyWith(
        settings: updatedSettings,
        todayPlan: stamped,
        rabtPortions: rabt,
      ),
    );
  }

  /// يعيد تحميل الحالة — يستخدم بعد تعديل الإعدادات.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final next = await _loadState();
      // إعادة جدولة الإشعارات بعد أي تغيير في الإعدادات.
      if (next.settings.onboarded) {
        await NotificationService.instance.reschedule(next.settings);
      }
      return next;
    });
  }

  /// ينهي الـ onboarding بكتابة الإعدادات وجدولة الإشعارات.
  Future<void> completeOnboarding(UserSettings settings) async {
    final finalSettings = settings.copyWith(onboarded: true);
    await ref.read(settingsRepositoryProvider).write(finalSettings);
    await NotificationService.instance.requestPermission();
    await NotificationService.instance.reschedule(finalSettings);
    await refresh();
  }

  /// معالجة اليوم الفائت.
  Future<void> resolveMissedDays(MissedDayAction action) async {
    final current = state.valueOrNull;
    if (current == null || current.incompleteBefore.isEmpty) return;

    final scheduler = ref.read(schedulerProvider);
    final planRepo = ref.read(planRepositoryProvider);
    final today = dateOnly(DateTime.now());

    switch (action) {
      case MissedDayAction.pushToNext:
        // احذف الصفوف الفائتة — Dashboard سيولّد نصاباً جديداً لليوم.
        for (final miss in current.incompleteBefore) {
          await planRepo.delete(miss.date);
        }
        break;

      case MissedDayAction.fillGap:
        // حوّل النصاب الفائت إلى أقرب يوم غير تسميعي قادم.
        for (final miss in current.incompleteBefore) {
          final gap = scheduler.nearestNonMemorizationDayThisWeek(
            today,
            current.settings.memorizationWeekdays,
          );
          if (gap != null) {
            await planRepo.upsert(miss.copyWith(date: gap));
          }
          await planRepo.delete(miss.date);
        }
        break;
    }

    await refresh();
  }
}

enum _TaskKind { nisab, takrar, rabt }

final planControllerProvider =
    AsyncNotifierProvider<PlanController, TodayState>(PlanController.new);

/// امتدادات عامة لتسهيل الاستدعاء من الواجهة.
extension TaskToggleExt on PlanController {
  Future<void> toggleNisab(bool v) => toggleTask(_TaskKind.nisab, v);
  Future<void> toggleTakrar(bool v) => toggleTask(_TaskKind.takrar, v);
  Future<void> toggleRabt(bool v) => toggleTask(_TaskKind.rabt, v);
}
