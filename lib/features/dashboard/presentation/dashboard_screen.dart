import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../core/providers.dart';
import '../../planner/application/plan_controller.dart';
import 'missed_day_sheet.dart';
import 'nisab_reference_card.dart';
import 'rabt_list.dart';
import 'task_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _missedSheetShown = false;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(planControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Ar.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (state) {
          // إذا لم يكمل المستخدم الإعداد، حوّله للـ onboarding.
          if (!state.settings.onboarded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/onboarding');
            });
            return const SizedBox.shrink();
          }

          // اعرض ورقة الأيام الفائتة مرة واحدة.
          if (state.hasMissedDays && !_missedSheetShown) {
            _missedSheetShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => MissedDaySheet(
                  missedCount: state.incompleteBefore.length,
                  onAction: (action) async {
                    Navigator.of(context).pop();
                    await ref
                        .read(planControllerProvider.notifier)
                        .resolveMissedDays(action);
                  },
                ),
              );
            });
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(planControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DateHeader(),
                const SizedBox(height: 16),
                if (!state.isMemorizationDayToday)
                  const _RestDayCard()
                else ...[
                  NisabReferenceCard(
                    plan: state.todayPlan!,
                    meta: ref.read(quranMetaProvider).requireValue,
                  ),
                  const SizedBox(height: 16),
                  TaskCard(
                    title: Ar.taskNisab,
                    description: Ar.taskNisabDesc,
                    icon: Icons.auto_stories_outlined,
                    done: state.todayPlan!.nisabDone,
                    onChanged: (v) => ref
                        .read(planControllerProvider.notifier)
                        .toggleNisab(v),
                  ),
                  const SizedBox(height: 12),
                  TaskCard(
                    title: Ar.taskTakrar,
                    description: Ar.taskTakrarDesc,
                    icon: Icons.repeat_rounded,
                    done: state.todayPlan!.takrarDone,
                    onChanged: (v) => ref
                        .read(planControllerProvider.notifier)
                        .toggleTakrar(v),
                  ),
                  const SizedBox(height: 12),
                  TaskCard(
                    title: Ar.taskRabt,
                    description: Ar.taskRabtDesc,
                    icon: Icons.link_rounded,
                    done: state.todayPlan!.rabtDone,
                    onChanged: (v) => ref
                        .read(planControllerProvider.notifier)
                        .toggleRabt(v),
                    expandedChild: RabtList(
                      portions: state.rabtPortions,
                      meta: ref.read(quranMetaProvider).requireValue,
                    ),
                  ),
                  if (state.todayPlan!.allDone) ...[
                    const SizedBox(height: 20),
                    _CompletedBanner(),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gregorian = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    final hijri = HijriCalendar.fromDate(now);
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}هـ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gregorian,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          hijriStr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.spa_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              Ar.noMemorizationToday,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Ar.noMemorizationTodayHint,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Ar.completedToday,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
