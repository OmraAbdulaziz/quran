import 'package:flutter/material.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../data/quran/quran_meta.dart';
import '../../planner/domain/models/position.dart';

class SurahAyahPicker extends StatefulWidget {
  final QuranMeta meta;
  final Position initial;
  final ValueChanged<Position> onChanged;

  const SurahAyahPicker({
    super.key,
    required this.meta,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<SurahAyahPicker> createState() => _SurahAyahPickerState();
}

class _SurahAyahPickerState extends State<SurahAyahPicker> {
  late int _surah;
  late int _ayah;

  @override
  void initState() {
    super.initState();
    _surah = widget.initial.surah;
    _ayah = widget.initial.ayah;
  }

  void _emit() {
    widget.onChanged(Position(_surah, _ayah));
  }

  @override
  Widget build(BuildContext context) {
    final surahs = widget.meta.surahs;
    final currentSurah = widget.meta.surah(_surah);
    final ayahCount = currentSurah.ayahCount;
    if (_ayah > ayahCount) _ayah = ayahCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledDropdown<int>(
          label: Ar.pickSurah,
          value: _surah,
          items: [
            for (final s in surahs)
              DropdownMenuItem(
                value: s.number,
                child: Text('${s.number}. ${s.nameAr}'),
              ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _surah = v;
              _ayah = 1;
            });
            _emit();
          },
        ),
        const SizedBox(height: 16),
        _LabeledDropdown<int>(
          label: Ar.pickAyah,
          value: _ayah,
          items: [
            for (var i = 1; i <= ayahCount; i++)
              DropdownMenuItem(value: i, child: Text('${Ar.ayah} $i')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _ayah = v);
            _emit();
          },
        ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          menuMaxHeight: 400,
        ),
      ),
    );
  }
}
