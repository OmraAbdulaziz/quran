import 'dart:convert';
import 'package:flutter/services.dart';

import '../../features/planner/domain/models/position.dart';

class Surah {
  final int number;
  final String nameAr;
  final int ayahCount;

  const Surah({
    required this.number,
    required this.nameAr,
    required this.ayahCount,
  });

  factory Surah.fromJson(Map<String, dynamic> j) => Surah(
        number: j['number'] as int,
        nameAr: j['name_ar'] as String,
        ayahCount: j['ayah_count'] as int,
      );
}

class WajhEntry {
  final int wajhIndex; // 1..1208
  final int page; // 1..604
  final int half; // 1 أعلى، 2 أسفل
  final Position start;

  const WajhEntry({
    required this.wajhIndex,
    required this.page,
    required this.half,
    required this.start,
  });
}

/// بيانات المصحف الهيكلية (محمّلة من الأصل JSON مرة واحدة).
class QuranMeta {
  final List<Surah> surahs;
  final List<WajhEntry> wajhs;

  /// فهرس السور مفتاحه رقم السورة.
  final Map<int, Surah> surahByNumber;

  const QuranMeta._(this.surahs, this.wajhs, this.surahByNumber);

  /// مخصّص للاختبارات فقط — يبني QuranMeta من بيانات مُعدَّة مسبقاً.
  factory QuranMeta.testBuild(
    List<Surah> surahs,
    List<WajhEntry> wajhs,
    Map<int, Surah> surahByNumber,
  ) =>
      QuranMeta._(surahs, wajhs, surahByNumber);

  static const int totalWajh = 1208;
  static const int totalPages = 604;

  Position get quranStart => const Position(1, 1);
  Position get quranEnd {
    final last = surahs.last;
    return Position(last.number, last.ayahCount);
  }

  int get lastWajh => wajhs.length;

  Surah surah(int number) =>
      surahByNumber[number] ??
      (throw ArgumentError('Unknown surah: $number'));

  /// الآية التالية للموضع؛ null إذا تجاوزنا آخر القرآن.
  Position? nextAyah(Position p) {
    final s = surah(p.surah);
    if (p.ayah < s.ayahCount) return Position(p.surah, p.ayah + 1);
    if (p.surah < 114) return Position(p.surah + 1, 1);
    return null;
  }

  /// الآية السابقة؛ null إذا تجاوزنا أول القرآن.
  Position? previousAyah(Position p) {
    if (p.ayah > 1) return Position(p.surah, p.ayah - 1);
    if (p.surah > 1) {
      final prev = surah(p.surah - 1);
      return Position(p.surah - 1, prev.ayahCount);
    }
    return null;
  }

  /// رقم الوجه الذي يحتوي الموضع المحدد (1..lastWajh).
  int wajhIndexContaining(Position p) {
    int lo = 0, hi = wajhs.length - 1, ans = 0;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (wajhs[mid].start <= p) {
        ans = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return wajhs[ans].wajhIndex;
  }

  /// موضع بداية الوجه ذي الرقم المحدد (أول وجه = 1). null إذا تخطينا الآخر.
  Position? wajhStart(int index) {
    if (index < 1 || index > wajhs.length) return null;
    return wajhs[index - 1].start;
  }

  WajhEntry wajhAt(int index) => wajhs[index - 1];
}

class QuranMetaLoader {
  static const _assetPath = 'assets/data/quran_meta.json';

  /// يحمّل البيانات من أصل التطبيق ويحسب خريطة الأوجه من حدود الأجزاء
  /// بالتوزيع المتساوي داخل كل جزء (40 وجهاً لكل جزء تقريباً).
  Future<QuranMeta> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final surahs = (json['surahs'] as List)
        .cast<Map<String, dynamic>>()
        .map(Surah.fromJson)
        .toList(growable: false);
    final surahMap = {for (final s in surahs) s.number: s};

    final juzStarts = (json['juz_starts'] as List)
        .cast<Map<String, dynamic>>()
        .map((j) => Position(j['surah'] as int, j['ayah'] as int))
        .toList(growable: false);

    final wajhs = _buildWajhMap(surahs, surahMap, juzStarts);
    return QuranMeta._(surahs, wajhs, surahMap);
  }

  /// يولّد قائمة 1208 وجهاً بتوزيع الآيات بالتساوي داخل كل جزء.
  /// النتيجة تقريبية ويمكن استبدالها لاحقاً ببيانات مصحف المدينة الرسمية.
  List<WajhEntry> _buildWajhMap(
    List<Surah> surahs,
    Map<int, Surah> surahMap,
    List<Position> juzStarts,
  ) {
    const wajhsPerJuz = QuranMeta.totalWajh ~/ 30; // 40
    final result = <WajhEntry>[];

    final quranEnd = Position(
      surahs.last.number,
      surahs.last.ayahCount,
    );

    for (var j = 0; j < juzStarts.length; j++) {
      final start = juzStarts[j];
      final next = j + 1 < juzStarts.length
          ? juzStarts[j + 1]
          : _afterEnd(quranEnd, surahMap);

      final ayahList = _expandAyahs(start, next, surahMap);
      final total = ayahList.length;
      for (var w = 0; w < wajhsPerJuz; w++) {
        final idx = (w * total) ~/ wajhsPerJuz;
        final p = ayahList[idx];
        final wajhIndex = j * wajhsPerJuz + w + 1;
        final page = ((wajhIndex - 1) ~/ 2) + 1;
        final half = (wajhIndex % 2 == 1) ? 1 : 2;
        result.add(
          WajhEntry(
            wajhIndex: wajhIndex,
            page: page,
            half: half,
            start: p,
          ),
        );
      }
    }

    return result;
  }

  /// يوسّع نطاق [from, to) إلى قائمة مواضع (سورة، آية).
  List<Position> _expandAyahs(
    Position from,
    Position to,
    Map<int, Surah> surahMap,
  ) {
    final out = <Position>[];
    var cur = from;
    while (cur < to) {
      out.add(cur);
      final s = surahMap[cur.surah]!;
      if (cur.ayah < s.ayahCount) {
        cur = Position(cur.surah, cur.ayah + 1);
      } else {
        cur = Position(cur.surah + 1, 1);
      }
    }
    return out;
  }

  /// موضع "بعد الآية الأخيرة" لاستخدامه كحدّ علوي حصري.
  Position _afterEnd(Position end, Map<int, Surah> surahMap) {
    // آية افتراضية بعد نهاية القرآن.
    return Position(end.surah + 1, 1);
  }
}
