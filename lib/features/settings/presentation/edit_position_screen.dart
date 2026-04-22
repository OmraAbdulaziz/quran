import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../core/providers.dart';
import '../../onboarding/presentation/surah_ayah_picker.dart';
import '../../planner/application/plan_controller.dart';
import '../../planner/domain/models/position.dart';

class EditPositionScreen extends ConsumerStatefulWidget {
  const EditPositionScreen({super.key});

  @override
  ConsumerState<EditPositionScreen> createState() =>
      _EditPositionScreenState();
}

class _EditPositionScreenState extends ConsumerState<EditPositionScreen> {
  Position? _picked;

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(quranMetaProvider).requireValue;
    final stateAsync = ref.watch(planControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.editPosition)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (state) {
          final initial = _picked ?? state.settings.currentPosition;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Ar.editPosition,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  SurahAyahPicker(
                    meta: meta,
                    initial: initial,
                    onChanged: (p) => _picked = p,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final next = _picked ?? initial;
                      final confirm = await _confirm(context);
                      if (!confirm) return;
                      await ref.read(settingsRepositoryProvider).write(
                            state.settings.copyWith(currentPosition: next),
                          );
                      await ref
                          .read(planControllerProvider.notifier)
                          .refresh();
                      if (!mounted) return;
                      context.pop();
                    },
                    child: const Text(Ar.save),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Ar.confirm),
        content: const Text(
          'سيتم تعديل الموضع الحالي. قد يؤثر ذلك على نصاب الغد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Ar.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(Ar.confirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
