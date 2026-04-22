import '../domain/models/position.dart';

class UserSettings {
  final double dailyAmountWajh; // 0.5 / 1 / 2 / 4
  final Set<int> memorizationWeekdays; // ISO: Mon=1 .. Sun=7
  final int rabtCount;
  final Position currentPosition;
  final int? notifyHour;
  final int? notifyMinute;
  final bool onboarded;

  const UserSettings({
    required this.dailyAmountWajh,
    required this.memorizationWeekdays,
    required this.rabtCount,
    required this.currentPosition,
    this.notifyHour,
    this.notifyMinute,
    this.onboarded = false,
  });

  factory UserSettings.defaults() => const UserSettings(
        dailyAmountWajh: 1,
        memorizationWeekdays: {1, 2, 3, 4, 7}, // إث/ثلاثاء/أربعاء/خميس/أحد
        rabtCount: 5,
        currentPosition: Position(1, 1),
        notifyHour: 6,
        notifyMinute: 0,
        onboarded: false,
      );

  UserSettings copyWith({
    double? dailyAmountWajh,
    Set<int>? memorizationWeekdays,
    int? rabtCount,
    Position? currentPosition,
    int? notifyHour,
    int? notifyMinute,
    bool? onboarded,
  }) =>
      UserSettings(
        dailyAmountWajh: dailyAmountWajh ?? this.dailyAmountWajh,
        memorizationWeekdays:
            memorizationWeekdays ?? this.memorizationWeekdays,
        rabtCount: rabtCount ?? this.rabtCount,
        currentPosition: currentPosition ?? this.currentPosition,
        notifyHour: notifyHour ?? this.notifyHour,
        notifyMinute: notifyMinute ?? this.notifyMinute,
        onboarded: onboarded ?? this.onboarded,
      );

  Map<String, Object?> toRow() => {
        'id': 1,
        'daily_amount_wajh': dailyAmountWajh,
        'memorization_weekdays':
            (memorizationWeekdays.toList()..sort()).join(','),
        'rabt_count': rabtCount,
        'current_surah': currentPosition.surah,
        'current_ayah': currentPosition.ayah,
        'notify_hour': notifyHour,
        'notify_minute': notifyMinute,
        'onboarded': onboarded ? 1 : 0,
      };

  factory UserSettings.fromRow(Map<String, Object?> r) => UserSettings(
        dailyAmountWajh: (r['daily_amount_wajh'] as num).toDouble(),
        memorizationWeekdays: (r['memorization_weekdays'] as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toSet(),
        rabtCount: r['rabt_count'] as int,
        currentPosition: Position(
          r['current_surah'] as int,
          r['current_ayah'] as int,
        ),
        notifyHour: r['notify_hour'] as int?,
        notifyMinute: r['notify_minute'] as int?,
        onboarded: (r['onboarded'] as int) == 1,
      );
}
