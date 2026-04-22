import '../../../core/utils/date_utils.dart';
import '../../../data/quran/quran_meta.dart';
import 'models/position.dart';

/// خيارات معالجة اليوم الفائت.
enum MissedDayAction {
  /// دفع النصاب الفائت إلى اليوم التالي (كل الجدول ينزلق).
  pushToNext,

  /// تعويضه في أقرب يوم غير تسميعي ضمن نفس الأسبوع.
  fillGap,
}

class Scheduler {
  final QuranMeta meta;
  const Scheduler(this.meta);

  /// يحسب نهاية نصاب اليوم بناءً على بدايته والمقدار اليومي بالوجه.
  ///
  /// - عدد صحيح (1، 2، 4): يغطي ذلك العدد من الأوجه كاملة ابتداءً من
  ///   الوجه الذي تحوي البداية. النهاية هي آخر آية قبل بداية الوجه التالي.
  /// - كسر (0.5): يغطي نصف عدد الآيات بين [start] وبداية الوجه التالي.
  /// - إذا تجاوز المقدار نهاية القرآن، ترجع آخر آية من سورة الناس.
  Position computeNisabEnd(Position start, double amountWajh) {
    assert(amountWajh > 0, 'amountWajh must be positive');
    final startIdx = meta.wajhIndexContaining(start);
    final whole = amountWajh.floor();
    final frac = amountWajh - whole;

    // الحالة الصحيحة (وجه كامل أو أكثر بلا كسر).
    if (frac == 0) {
      final endWajh = startIdx + whole - 1;
      final clamped = endWajh > meta.lastWajh ? meta.lastWajh : endWajh;
      final nextStart = meta.wajhStart(clamped + 1);
      if (nextStart == null) return meta.quranEnd;
      return meta.previousAyah(nextStart) ?? meta.quranEnd;
    }

    // الحالة الكسرية: غطِّ `whole` وجهاً كاملاً، ثم جزءاً من الوجه التالي.
    final partialIdx = startIdx + whole;
    if (partialIdx > meta.lastWajh) return meta.quranEnd;

    final partialStart =
        whole == 0 ? start : (meta.wajhStart(partialIdx) ?? start);
    final partialNextStart = meta.wajhStart(partialIdx + 1);

    final ayahs = _expandAyahs(partialStart, partialNextStart);
    if (ayahs.isEmpty) return meta.quranEnd;
    final count = (ayahs.length * frac).ceil().clamp(1, ayahs.length);
    return ayahs[count - 1];
  }

  /// يوسّع [from] إلى قائمة مواضع حتى (لكن قبل) [to] الحصري؛ إذا كان
  /// [to] = null استمر حتى نهاية القرآن.
  List<Position> _expandAyahs(Position from, Position? to) {
    final out = <Position>[];
    Position? cur = from;
    while (cur != null && (to == null || cur < to)) {
      out.add(cur);
      cur = meta.nextAyah(cur);
    }
    return out;
  }

  /// الموضع التالي للنصاب (لبدء نصاب الغد).
  Position? advanceFrom(Position end) => meta.nextAyah(end);

  bool isMemorizationDay(DateTime d, Set<int> weekdays) =>
      weekdays.contains(d.weekday);

  /// أقرب يوم تسميع يأتي بعد [from] (قد يكون [from] نفسه إذا لم يُستبعد).
  DateTime nextMemorizationDay(
    DateTime from,
    Set<int> weekdays, {
    bool inclusive = true,
  }) {
    var d = dateOnly(from);
    if (!inclusive) d = d.add(const Duration(days: 1));
    for (var i = 0; i < 14; i++) {
      if (isMemorizationDay(d, weekdays)) return d;
      d = d.add(const Duration(days: 1));
    }
    return d; // fallback
  }

  /// أقرب يوم غير تسميعي ضمن نفس الأسبوع بعد [from]. إذا لم يوجد، ترجع null.
  DateTime? nearestNonMemorizationDayThisWeek(
    DateTime from,
    Set<int> weekdays,
  ) {
    final start = dateOnly(from);
    final endOfWeek = start.add(Duration(days: 7 - start.weekday)); // الأحد
    var d = start.add(const Duration(days: 1));
    while (!d.isAfter(endOfWeek)) {
      if (!isMemorizationDay(d, weekdays)) return d;
      d = d.add(const Duration(days: 1));
    }
    return null;
  }
}
