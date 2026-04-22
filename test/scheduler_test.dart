import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tracker/features/planner/domain/models/position.dart';
import 'package:quran_tracker/features/planner/domain/scheduler.dart';

import 'support/fake_quran_meta.dart';

void main() {
  final meta = FakeQuranMetaBuilder.build();
  final s = Scheduler(meta);

  group('Scheduler.computeNisabEnd', () {
    test('نصف وجه يعطي نصف عدد آيات الوجه الكامل تقريباً', () {
      // نختار وجهاً فيه عدة آيات (البقرة) لنختبر التجزئة فعلياً.
      final start = const Position(2, 1);
      final endHalf = s.computeNisabEnd(start, 0.5);
      final endFull = s.computeNisabEnd(start, 1);
      // نصف الوجه يجب أن ينتهي قبل الوجه الكامل (تجزئة حقيقية).
      expect(endHalf < endFull, isTrue,
          reason: 'نصف الوجه لازم يكون أقل من الوجه الكامل');
    });

    test('نصف وجه من بداية السورة يغطي نصف آيات الوجه تقريباً', () {
      final start = const Position(2, 1);
      final nextWajhStart = meta.wajhStart(meta.wajhIndexContaining(start) + 1);
      expect(nextWajhStart, isNotNull);
      final endHalf = s.computeNisabEnd(start, 0.5);
      // نتحقق أن endHalf داخل الوجه نفسه (قبل بداية الوجه التالي).
      expect(endHalf < nextWajhStart!, isTrue);
    });

    test('وجه كامل يقدّم إلى بداية الوجه التالي ثم يسحب آية واحدة', () {
      final start = meta.wajhStart(1)!;
      final end = s.computeNisabEnd(start, 1);
      final nextStart = meta.wajhStart(2)!;
      final expected = meta.previousAyah(nextStart);
      expect(end, expected);
    });

    test('مقدار يتجاوز نهاية القرآن يرجع آخر آية من الناس', () {
      final start = meta.wajhStart(meta.lastWajh)!;
      final end = s.computeNisabEnd(start, 10);
      expect(end, meta.quranEnd);
      expect(end.surah, 114);
    });

    test('صفحتان من أول البقرة يتقدم وجهان كاملان', () {
      final start = const Position(2, 1);
      final startIdx = meta.wajhIndexContaining(start);
      final end = s.computeNisabEnd(start, 4); // صفحتان = 4 أوجه
      final endIdx = meta.wajhIndexContaining(end);
      expect(endIdx - startIdx, 3); // نهاية الوجه الرابع نسبياً
    });
  });

  group('Scheduler.advanceFrom', () {
    test('يتقدم للآية التالية داخل نفس السورة', () {
      expect(s.advanceFrom(const Position(2, 5)), const Position(2, 6));
    });

    test('يتقدم لأول آية من السورة التالية إذا كنا عند النهاية', () {
      final end = const Position(1, 7); // آخر آية من الفاتحة
      expect(s.advanceFrom(end), const Position(2, 1));
    });

    test('آخر آية من القرآن ترجع null', () {
      expect(s.advanceFrom(meta.quranEnd), null);
    });
  });

  group('Scheduler.isMemorizationDay', () {
    test('يعترف بالأيام المختارة فقط', () {
      // ISO weekday: 1=الإثنين ... 7=الأحد
      const weekdays = {1, 2, 3, 4, 7}; // إث ثل أر خ ح
      expect(s.isMemorizationDay(DateTime(2026, 4, 20), weekdays), true);
      // 2026-04-25 سبت = weekday 6
      expect(s.isMemorizationDay(DateTime(2026, 4, 25), weekdays), false);
      expect(s.isMemorizationDay(DateTime(2026, 4, 26), weekdays), true); // أحد
    });
  });

  group('Scheduler.nextMemorizationDay', () {
    test('يتخطى الأيام غير التسميعية', () {
      const weekdays = {1, 2, 3, 4, 7};
      final friday = DateTime(2026, 4, 24);
      expect(
        s.nextMemorizationDay(friday, weekdays, inclusive: false),
        DateTime(2026, 4, 26), // الأحد
      );
    });

    test('inclusive يرجع نفس اليوم إذا كان يوم تسميع', () {
      const weekdays = {1, 2, 3, 4, 7};
      final monday = DateTime(2026, 4, 20);
      expect(s.nextMemorizationDay(monday, weekdays), monday);
    });
  });

  group('Scheduler.nearestNonMemorizationDayThisWeek', () {
    test('يرجع أقرب يوم غير تسميعي خلال الأسبوع نفسه', () {
      const weekdays = {1, 2, 3, 4, 7}; // الجمعة والسبت خارج
      final thursday = DateTime(2026, 4, 23);
      expect(
        s.nearestNonMemorizationDayThisWeek(thursday, weekdays),
        DateTime(2026, 4, 24), // الجمعة
      );
    });

    test('null إذا انقضى الأسبوع دون يوم خالي', () {
      const weekdays = {1, 2, 3, 4, 5, 6, 7};
      final tuesday = DateTime(2026, 4, 21);
      expect(s.nearestNonMemorizationDayThisWeek(tuesday, weekdays), null);
    });
  });
}
