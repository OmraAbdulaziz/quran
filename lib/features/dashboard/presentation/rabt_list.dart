import 'package:flutter/material.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../data/quran/quran_meta.dart';
import '../../planner/domain/models/daily_plan.dart';

class RabtList extends StatelessWidget {
  final List<CompletedPortion> portions;
  final QuranMeta meta;

  const RabtList({super.key, required this.portions, required this.meta});

  @override
  Widget build(BuildContext context) {
    if (portions.isEmpty) {
      return Text(
        'لا توجد نصابات سابقة بعد',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in portions)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _format(p),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  String _format(CompletedPortion p) {
    final startName = meta.surah(p.start.surah).nameAr;
    final endName = meta.surah(p.end.surah).nameAr;
    if (p.start.surah == p.end.surah) {
      return '${Ar.surah} $startName: ${p.start.ayah}–${p.end.ayah}';
    }
    return '$startName:${p.start.ayah} → $endName:${p.end.ayah}';
  }
}
