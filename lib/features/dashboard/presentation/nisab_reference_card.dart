import 'package:flutter/material.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../data/quran/quran_meta.dart';
import '../../planner/domain/models/daily_plan.dart';

class NisabReferenceCard extends StatelessWidget {
  final DailyPlan plan;
  final QuranMeta meta;

  const NisabReferenceCard({
    super.key,
    required this.plan,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final startSurah = meta.surah(plan.nisabStart.surah);
    final endSurah = meta.surah(plan.nisabEnd.surah);
    final sameSurah = startSurah.number == endSurah.number;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Ar.todayNisab,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (sameSurah)
              _line(
                context,
                '${Ar.surah} ${startSurah.nameAr}: '
                '${Ar.fromAyah} ${plan.nisabStart.ayah} '
                '${Ar.toAyah} ${plan.nisabEnd.ayah}',
              )
            else ...[
              _line(
                context,
                '${Ar.fromAyah} ${plan.nisabStart.ayah} ${Ar.surah} ${startSurah.nameAr}',
              ),
              const SizedBox(height: 4),
              _line(
                context,
                '${Ar.toAyah} ${plan.nisabEnd.ayah} ${Ar.surah} ${endSurah.nameAr}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.6,
            ),
      );
}
