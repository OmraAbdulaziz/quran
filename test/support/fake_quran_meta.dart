import 'package:quran_tracker/data/quran/quran_meta.dart';
import 'package:quran_tracker/features/planner/domain/models/position.dart';

/// يبني QuranMeta بسيطة للاختبارات فقط عبر passthrough عام.
///
/// نستخدم JSON الحقيقي الموجود في assets عبر تنفيذ خوارزمية التوليد يدوياً
/// بدون الاعتماد على rootBundle. نحتفظ بنفس منطق التوليد: توزيع الآيات
/// بالتساوي داخل كل جزء.
class FakeQuranMetaBuilder {
  static QuranMeta build() {
    // قائمة مبسّطة مبنية يدوياً من البيانات الحقيقية — يكفي لاختبارات الجدولة.
    final surahs = _hafsSurahs();
    final surahMap = {for (final s in surahs) s.number: s};
    final juzStarts = _juzStarts();

    const wajhsPerJuz = QuranMeta.totalWajh ~/ 30;
    final wajhs = <WajhEntry>[];

    for (var j = 0; j < juzStarts.length; j++) {
      final start = juzStarts[j];
      final next = j + 1 < juzStarts.length
          ? juzStarts[j + 1]
          : const Position(115, 1);

      final ayahList = <Position>[];
      var cur = start;
      while (cur < next) {
        ayahList.add(cur);
        final s = surahMap[cur.surah]!;
        if (cur.ayah < s.ayahCount) {
          cur = Position(cur.surah, cur.ayah + 1);
        } else {
          cur = Position(cur.surah + 1, 1);
        }
      }

      for (var w = 0; w < wajhsPerJuz; w++) {
        final idx = (w * ayahList.length) ~/ wajhsPerJuz;
        final wajhIndex = j * wajhsPerJuz + w + 1;
        wajhs.add(
          WajhEntry(
            wajhIndex: wajhIndex,
            page: ((wajhIndex - 1) ~/ 2) + 1,
            half: (wajhIndex % 2 == 1) ? 1 : 2,
            start: ayahList[idx],
          ),
        );
      }
    }

    return QuranMetaForTests.build(surahs, wajhs, surahMap);
  }
}

/// امتداد قاذف (exposing) ليبني QuranMeta عبر اختبارات لا تمرّ عبر JSON.
///
/// نستخدم مُنشِئًا خاصًّا عبر reflection-like trick: ننسخ منطق البناء
/// في ملف الاختبار لأن ‎QuranMeta._‎ خاص. لذلك نُعيد تعريف helper
/// يستدعي المنشئ العام من خلال تمرير الحقول.
class QuranMetaForTests {
  static QuranMeta build(
    List<Surah> surahs,
    List<WajhEntry> wajhs,
    Map<int, Surah> surahMap,
  ) {
    // بما أن المنشئ خاص، نستخدم دالة مساعدة في quran_meta نفسه.
    // نمرّر البيانات عبر JSON فعلياً لا، نستخدم QuranMeta.testBuild.
    return QuranMeta.testBuild(surahs, wajhs, surahMap);
  }
}

List<Surah> _hafsSurahs() => const [
      Surah(number: 1, nameAr: 'الفاتحة', ayahCount: 7),
      Surah(number: 2, nameAr: 'البقرة', ayahCount: 286),
      Surah(number: 3, nameAr: 'آل عمران', ayahCount: 200),
      Surah(number: 4, nameAr: 'النساء', ayahCount: 176),
      Surah(number: 5, nameAr: 'المائدة', ayahCount: 120),
      Surah(number: 6, nameAr: 'الأنعام', ayahCount: 165),
      Surah(number: 7, nameAr: 'الأعراف', ayahCount: 206),
      Surah(number: 8, nameAr: 'الأنفال', ayahCount: 75),
      Surah(number: 9, nameAr: 'التوبة', ayahCount: 129),
      Surah(number: 10, nameAr: 'يونس', ayahCount: 109),
      Surah(number: 11, nameAr: 'هود', ayahCount: 123),
      Surah(number: 12, nameAr: 'يوسف', ayahCount: 111),
      Surah(number: 13, nameAr: 'الرعد', ayahCount: 43),
      Surah(number: 14, nameAr: 'إبراهيم', ayahCount: 52),
      Surah(number: 15, nameAr: 'الحجر', ayahCount: 99),
      Surah(number: 16, nameAr: 'النحل', ayahCount: 128),
      Surah(number: 17, nameAr: 'الإسراء', ayahCount: 111),
      Surah(number: 18, nameAr: 'الكهف', ayahCount: 110),
      Surah(number: 19, nameAr: 'مريم', ayahCount: 98),
      Surah(number: 20, nameAr: 'طه', ayahCount: 135),
      Surah(number: 21, nameAr: 'الأنبياء', ayahCount: 112),
      Surah(number: 22, nameAr: 'الحج', ayahCount: 78),
      Surah(number: 23, nameAr: 'المؤمنون', ayahCount: 118),
      Surah(number: 24, nameAr: 'النور', ayahCount: 64),
      Surah(number: 25, nameAr: 'الفرقان', ayahCount: 77),
      Surah(number: 26, nameAr: 'الشعراء', ayahCount: 227),
      Surah(number: 27, nameAr: 'النمل', ayahCount: 93),
      Surah(number: 28, nameAr: 'القصص', ayahCount: 88),
      Surah(number: 29, nameAr: 'العنكبوت', ayahCount: 69),
      Surah(number: 30, nameAr: 'الروم', ayahCount: 60),
      Surah(number: 31, nameAr: 'لقمان', ayahCount: 34),
      Surah(number: 32, nameAr: 'السجدة', ayahCount: 30),
      Surah(number: 33, nameAr: 'الأحزاب', ayahCount: 73),
      Surah(number: 34, nameAr: 'سبأ', ayahCount: 54),
      Surah(number: 35, nameAr: 'فاطر', ayahCount: 45),
      Surah(number: 36, nameAr: 'يس', ayahCount: 83),
      Surah(number: 37, nameAr: 'الصافات', ayahCount: 182),
      Surah(number: 38, nameAr: 'ص', ayahCount: 88),
      Surah(number: 39, nameAr: 'الزمر', ayahCount: 75),
      Surah(number: 40, nameAr: 'غافر', ayahCount: 85),
      Surah(number: 41, nameAr: 'فصلت', ayahCount: 54),
      Surah(number: 42, nameAr: 'الشورى', ayahCount: 53),
      Surah(number: 43, nameAr: 'الزخرف', ayahCount: 89),
      Surah(number: 44, nameAr: 'الدخان', ayahCount: 59),
      Surah(number: 45, nameAr: 'الجاثية', ayahCount: 37),
      Surah(number: 46, nameAr: 'الأحقاف', ayahCount: 35),
      Surah(number: 47, nameAr: 'محمد', ayahCount: 38),
      Surah(number: 48, nameAr: 'الفتح', ayahCount: 29),
      Surah(number: 49, nameAr: 'الحجرات', ayahCount: 18),
      Surah(number: 50, nameAr: 'ق', ayahCount: 45),
      Surah(number: 51, nameAr: 'الذاريات', ayahCount: 60),
      Surah(number: 52, nameAr: 'الطور', ayahCount: 49),
      Surah(number: 53, nameAr: 'النجم', ayahCount: 62),
      Surah(number: 54, nameAr: 'القمر', ayahCount: 55),
      Surah(number: 55, nameAr: 'الرحمن', ayahCount: 78),
      Surah(number: 56, nameAr: 'الواقعة', ayahCount: 96),
      Surah(number: 57, nameAr: 'الحديد', ayahCount: 29),
      Surah(number: 58, nameAr: 'المجادلة', ayahCount: 22),
      Surah(number: 59, nameAr: 'الحشر', ayahCount: 24),
      Surah(number: 60, nameAr: 'الممتحنة', ayahCount: 13),
      Surah(number: 61, nameAr: 'الصف', ayahCount: 14),
      Surah(number: 62, nameAr: 'الجمعة', ayahCount: 11),
      Surah(number: 63, nameAr: 'المنافقون', ayahCount: 11),
      Surah(number: 64, nameAr: 'التغابن', ayahCount: 18),
      Surah(number: 65, nameAr: 'الطلاق', ayahCount: 12),
      Surah(number: 66, nameAr: 'التحريم', ayahCount: 12),
      Surah(number: 67, nameAr: 'الملك', ayahCount: 30),
      Surah(number: 68, nameAr: 'القلم', ayahCount: 52),
      Surah(number: 69, nameAr: 'الحاقة', ayahCount: 52),
      Surah(number: 70, nameAr: 'المعارج', ayahCount: 44),
      Surah(number: 71, nameAr: 'نوح', ayahCount: 28),
      Surah(number: 72, nameAr: 'الجن', ayahCount: 28),
      Surah(number: 73, nameAr: 'المزمل', ayahCount: 20),
      Surah(number: 74, nameAr: 'المدثر', ayahCount: 56),
      Surah(number: 75, nameAr: 'القيامة', ayahCount: 40),
      Surah(number: 76, nameAr: 'الإنسان', ayahCount: 31),
      Surah(number: 77, nameAr: 'المرسلات', ayahCount: 50),
      Surah(number: 78, nameAr: 'النبأ', ayahCount: 40),
      Surah(number: 79, nameAr: 'النازعات', ayahCount: 46),
      Surah(number: 80, nameAr: 'عبس', ayahCount: 42),
      Surah(number: 81, nameAr: 'التكوير', ayahCount: 29),
      Surah(number: 82, nameAr: 'الانفطار', ayahCount: 19),
      Surah(number: 83, nameAr: 'المطففين', ayahCount: 36),
      Surah(number: 84, nameAr: 'الانشقاق', ayahCount: 25),
      Surah(number: 85, nameAr: 'البروج', ayahCount: 22),
      Surah(number: 86, nameAr: 'الطارق', ayahCount: 17),
      Surah(number: 87, nameAr: 'الأعلى', ayahCount: 19),
      Surah(number: 88, nameAr: 'الغاشية', ayahCount: 26),
      Surah(number: 89, nameAr: 'الفجر', ayahCount: 30),
      Surah(number: 90, nameAr: 'البلد', ayahCount: 20),
      Surah(number: 91, nameAr: 'الشمس', ayahCount: 15),
      Surah(number: 92, nameAr: 'الليل', ayahCount: 21),
      Surah(number: 93, nameAr: 'الضحى', ayahCount: 11),
      Surah(number: 94, nameAr: 'الشرح', ayahCount: 8),
      Surah(number: 95, nameAr: 'التين', ayahCount: 8),
      Surah(number: 96, nameAr: 'العلق', ayahCount: 19),
      Surah(number: 97, nameAr: 'القدر', ayahCount: 5),
      Surah(number: 98, nameAr: 'البينة', ayahCount: 8),
      Surah(number: 99, nameAr: 'الزلزلة', ayahCount: 8),
      Surah(number: 100, nameAr: 'العاديات', ayahCount: 11),
      Surah(number: 101, nameAr: 'القارعة', ayahCount: 11),
      Surah(number: 102, nameAr: 'التكاثر', ayahCount: 8),
      Surah(number: 103, nameAr: 'العصر', ayahCount: 3),
      Surah(number: 104, nameAr: 'الهمزة', ayahCount: 9),
      Surah(number: 105, nameAr: 'الفيل', ayahCount: 5),
      Surah(number: 106, nameAr: 'قريش', ayahCount: 4),
      Surah(number: 107, nameAr: 'الماعون', ayahCount: 7),
      Surah(number: 108, nameAr: 'الكوثر', ayahCount: 3),
      Surah(number: 109, nameAr: 'الكافرون', ayahCount: 6),
      Surah(number: 110, nameAr: 'النصر', ayahCount: 3),
      Surah(number: 111, nameAr: 'المسد', ayahCount: 5),
      Surah(number: 112, nameAr: 'الإخلاص', ayahCount: 4),
      Surah(number: 113, nameAr: 'الفلق', ayahCount: 5),
      Surah(number: 114, nameAr: 'الناس', ayahCount: 6),
    ];

List<Position> _juzStarts() => const [
      Position(1, 1),
      Position(2, 142),
      Position(2, 253),
      Position(3, 92),
      Position(4, 24),
      Position(4, 148),
      Position(5, 82),
      Position(6, 111),
      Position(7, 88),
      Position(8, 41),
      Position(9, 93),
      Position(11, 6),
      Position(12, 53),
      Position(15, 1),
      Position(17, 1),
      Position(18, 75),
      Position(21, 1),
      Position(23, 1),
      Position(25, 21),
      Position(27, 56),
      Position(29, 46),
      Position(33, 31),
      Position(36, 28),
      Position(39, 32),
      Position(41, 47),
      Position(46, 1),
      Position(51, 31),
      Position(58, 1),
      Position(67, 1),
      Position(78, 1),
    ];
