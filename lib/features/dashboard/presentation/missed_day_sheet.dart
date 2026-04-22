import 'package:flutter/material.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../planner/domain/scheduler.dart';

class MissedDaySheet extends StatelessWidget {
  final int missedCount;
  final ValueChanged<MissedDayAction> onAction;

  const MissedDaySheet({
    super.key,
    required this.missedCount,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              Ar.missedDayTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              missedCount == 1
                  ? Ar.missedDayBody
                  : 'فاتك $missedCount أيام. ${Ar.missedDayBody}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => onAction(MissedDayAction.pushToNext),
              child: const Text(Ar.missedDayPush),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => onAction(MissedDayAction.fillGap),
              child: const Text(Ar.missedDayFillGap),
            ),
          ],
        ),
      ),
    );
  }
}
