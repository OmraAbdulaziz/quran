import '../../../../core/utils/date_utils.dart';
import 'position.dart';

class DailyPlan {
  final DateTime date;
  final Position nisabStart;
  final Position nisabEnd;
  final bool nisabDone;
  final bool takrarDone;
  final bool rabtDone;
  final DateTime? completedAt;

  const DailyPlan({
    required this.date,
    required this.nisabStart,
    required this.nisabEnd,
    this.nisabDone = false,
    this.takrarDone = false,
    this.rabtDone = false,
    this.completedAt,
  });

  bool get allDone => nisabDone && takrarDone && rabtDone;

  DailyPlan copyWith({
    DateTime? date,
    Position? nisabStart,
    Position? nisabEnd,
    bool? nisabDone,
    bool? takrarDone,
    bool? rabtDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) =>
      DailyPlan(
        date: date ?? this.date,
        nisabStart: nisabStart ?? this.nisabStart,
        nisabEnd: nisabEnd ?? this.nisabEnd,
        nisabDone: nisabDone ?? this.nisabDone,
        takrarDone: takrarDone ?? this.takrarDone,
        rabtDone: rabtDone ?? this.rabtDone,
        completedAt:
            clearCompletedAt ? null : (completedAt ?? this.completedAt),
      );

  Map<String, Object?> toRow() => {
        'date': formatYmd(date),
        'nisab_start_surah': nisabStart.surah,
        'nisab_start_ayah': nisabStart.ayah,
        'nisab_end_surah': nisabEnd.surah,
        'nisab_end_ayah': nisabEnd.ayah,
        'nisab_done': nisabDone ? 1 : 0,
        'takrar_done': takrarDone ? 1 : 0,
        'rabt_done': rabtDone ? 1 : 0,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory DailyPlan.fromRow(Map<String, Object?> r) => DailyPlan(
        date: parseYmd(r['date'] as String),
        nisabStart: Position(
          r['nisab_start_surah'] as int,
          r['nisab_start_ayah'] as int,
        ),
        nisabEnd: Position(
          r['nisab_end_surah'] as int,
          r['nisab_end_ayah'] as int,
        ),
        nisabDone: (r['nisab_done'] as int) == 1,
        takrarDone: (r['takrar_done'] as int) == 1,
        rabtDone: (r['rabt_done'] as int) == 1,
        completedAt: r['completed_at'] == null
            ? null
            : DateTime.parse(r['completed_at'] as String),
      );
}

class CompletedPortion {
  final int? id;
  final DateTime completedDate;
  final Position start;
  final Position end;

  const CompletedPortion({
    this.id,
    required this.completedDate,
    required this.start,
    required this.end,
  });

  Map<String, Object?> toRow() => {
        if (id != null) 'id': id,
        'completed_date': formatYmd(completedDate),
        'start_surah': start.surah,
        'start_ayah': start.ayah,
        'end_surah': end.surah,
        'end_ayah': end.ayah,
      };

  factory CompletedPortion.fromRow(Map<String, Object?> r) => CompletedPortion(
        id: r['id'] as int?,
        completedDate: parseYmd(r['completed_date'] as String),
        start: Position(
          r['start_surah'] as int,
          r['start_ayah'] as int,
        ),
        end: Position(
          r['end_surah'] as int,
          r['end_ayah'] as int,
        ),
      );
}
