import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../core/providers.dart';
import '../../planner/application/plan_controller.dart';
import '../../planner/data/user_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(planControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.settings)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (state) {
          final s = state.settings;
          final meta = ref.read(quranMetaProvider).requireValue;
          final currentSurahName = meta.surah(s.currentPosition.surah).nameAr;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _tile(
                context,
                icon: Icons.menu_book_outlined,
                title: Ar.settingsAmount,
                subtitle: _amountLabel(s.dailyAmountWajh),
                onTap: () => _editAmount(context, ref, s),
              ),
              _tile(
                context,
                icon: Icons.calendar_today_outlined,
                title: Ar.settingsWeekdays,
                subtitle: _weekdaysLabel(s.memorizationWeekdays),
                onTap: () => _editWeekdays(context, ref, s),
              ),
              _tile(
                context,
                icon: Icons.link_rounded,
                title: Ar.settingsRabtCount,
                subtitle: '${s.rabtCount}',
                onTap: () => _editRabtCount(context, ref, s),
              ),
              _tile(
                context,
                icon: Icons.access_time,
                title: Ar.settingsNotifyTime,
                subtitle:
                    '${(s.notifyHour ?? 6).toString().padLeft(2, '0')}:${(s.notifyMinute ?? 0).toString().padLeft(2, '0')}',
                onTap: () => _editNotifyTime(context, ref, s),
              ),
              _tile(
                context,
                icon: Icons.bookmark_outline,
                title: Ar.settingsCurrentPosition,
                subtitle:
                    '${Ar.surah} $currentSurahName، ${Ar.ayah} ${s.currentPosition.ayah}',
                onTap: () => context.push('/edit-position'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _amountLabel(double v) => switch (v) {
        0.5 => Ar.amountHalfWajh,
        1.0 => Ar.amountOneWajh,
        2.0 => Ar.amountOnePage,
        4.0 => Ar.amountTwoPages,
        _ => '$v وجه',
      };

  String _weekdaysLabel(Set<int> days) {
    if (days.isEmpty) return '—';
    final sorted = (days.toList()..sort());
    return sorted.map((d) => Ar.weekdaysShort[d - 1]).join(' • ');
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      );

  Future<void> _editAmount(
    BuildContext context,
    WidgetRef ref,
    UserSettings s,
  ) async {
    final picked = await showModalBottomSheet<double>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (v, label) in const [
              (0.5, Ar.amountHalfWajh),
              (1.0, Ar.amountOneWajh),
              (2.0, Ar.amountOnePage),
              (4.0, Ar.amountTwoPages),
            ])
              ListTile(
                title: Text(label),
                trailing: v == s.dailyAmountWajh
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(v),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await ref
        .read(settingsRepositoryProvider)
        .write(s.copyWith(dailyAmountWajh: picked));
    await ref.read(planControllerProvider.notifier).refresh();
  }

  Future<void> _editWeekdays(
    BuildContext context,
    WidgetRef ref,
    UserSettings s,
  ) async {
    final selected = <int>{...s.memorizationWeekdays};
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text(Ar.settingsWeekdays),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var wd = 1; wd <= 7; wd++)
                  CheckboxListTile(
                    value: selected.contains(wd),
                    onChanged: (v) => setState(() {
                      if (v ?? false) {
                        selected.add(wd);
                      } else {
                        selected.remove(wd);
                      }
                    }),
                    title: Text(Ar.weekdays[wd - 1]),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(Ar.cancel),
            ),
            ElevatedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.of(ctx).pop(selected),
              child: const Text(Ar.save),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await ref.read(settingsRepositoryProvider).write(
          s.copyWith(memorizationWeekdays: result),
        );
    await ref.read(planControllerProvider.notifier).refresh();
  }

  Future<void> _editRabtCount(
    BuildContext context,
    WidgetRef ref,
    UserSettings s,
  ) async {
    var v = s.rabtCount;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text(Ar.settingsRabtCount),
          content: Row(
            children: [
              Text('$v', style: Theme.of(ctx).textTheme.headlineSmall),
              Expanded(
                child: Slider(
                  value: v.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$v',
                  onChanged: (nv) => setState(() => v = nv.round()),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(Ar.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(v),
              child: const Text(Ar.save),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await ref
        .read(settingsRepositoryProvider)
        .write(s.copyWith(rabtCount: result));
    await ref.read(planControllerProvider.notifier).refresh();
  }

  Future<void> _editNotifyTime(
    BuildContext context,
    WidgetRef ref,
    UserSettings s,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: s.notifyHour ?? 6,
        minute: s.notifyMinute ?? 0,
      ),
    );
    if (picked == null) return;
    await ref.read(settingsRepositoryProvider).write(
          s.copyWith(notifyHour: picked.hour, notifyMinute: picked.minute),
        );
    await ref.read(planControllerProvider.notifier).refresh();
  }
}
