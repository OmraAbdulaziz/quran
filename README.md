# متابع الحفظ (Quran Tracker)

تطبيق Flutter شخصي لمتابعة حفظ القرآن الكريم. يولّد جدولاً يومياً يتضمّن ثلاث مهام تفاعلية (نصاب، تكرار، ربط) ويتابع تقدّم المستخدم محلياً.

## المميزات

- **Onboarding** من 5 خطوات: نقطة البداية، المقدار اليومي (نصف وجه / وجه / صفحة / صفحتان)، أيام التسميع الأسبوعية، عدد نصابات الربط، وقت التذكير.
- **لوحة رئيسية** عربية RTL بخط Cairo، تعرض نصاب اليوم كمرجع (سورة + من آية إلى آية) مع ٣ بطاقات تفاعلية.
- **جدولة تلقائية**: بعد إتمام كل مهام اليوم، يتقدم الموضع الحالي تلقائياً للنصاب التالي.
- **معالجة الأيام الفائتة**: ورقة منبثقة تخيّر المستخدم بين "التعويض باليوم التالي" أو "ملء أقرب يوم خالي في الأسبوع".
- **إشعارات يومية** عبر `flutter_local_notifications` مجدولة على أيام التسميع في الوقت المختار.
- **تخزين محلي** عبر `sqflite` (قاعدة بيانات واحدة: `settings`، `daily_plan`، `completed_portions`).
- **وضع ليلي** تلقائي (ThemeMode.system).

## الإعداد المحلي

المستودع يحتوي على كود Dart فقط (`lib/`، `test/`، `assets/`). لتوليد مجلّدات المنصات (`android/`، `ios/`):

```bash
# 1. ولّد scaffolding المنصات
flutter create . --project-name quran_tracker --platforms android,ios

# 2. ثبّت التبعيات
flutter pub get

# 3. شغّل على المحاكي
flutter run
```

## الهيكل

```
lib/
├─ main.dart                         # نقطة الدخول، تهيئة intl و notifications
├─ app.dart                          # MaterialApp.router + RTL + theme
├─ core/
│  ├─ theme/                         # ألوان + ThemeData (light/dark)
│  ├─ l10n/strings_ar.dart           # كل النصوص العربية
│  ├─ utils/date_utils.dart
│  └─ providers.dart                 # Riverpod providers للـ DI
├─ data/
│  ├─ db/                            # sqflite + migrations
│  └─ quran/quran_meta.dart          # موديل QuranMeta + Loader
└─ features/
   ├─ onboarding/                    # 5 خطوات + SurahAyahPicker
   ├─ planner/
   │  ├─ domain/scheduler.dart       # خوارزمية الجدولة (pure)
   │  ├─ domain/models/              # Position, DailyPlan, CompletedPortion
   │  ├─ data/                       # SettingsRepository, PlanRepository
   │  └─ application/plan_controller.dart  # AsyncNotifier
   ├─ dashboard/                     # Dashboard + TaskCard + MissedDaySheet
   ├─ settings/                      # Settings + EditPosition
   └─ notifications/notification_service.dart
```

## الاختبارات

```bash
flutter test test/scheduler_test.dart
```

يغطي:
- حساب نهاية النصاب بوحدات الوجه (نصف وجه، وجه كامل، صفحتان).
- تجاوز نهاية القرآن.
- التقدّم عبر حدود السور.
- تخطي أيام غير تسميعية.
- أقرب يوم خالي ضمن الأسبوع.

## بيانات المصحف

ملف `assets/data/quran_meta.json` يحتوي:
- قائمة 114 سورة مع أسمائها العربية وعدد آياتها (رواية حفص — موحّدة).
- بدايات 30 جزءاً (موحّدة).

الأوجه (1208 وجهاً) تُحسب وقت التحميل بتوزيع الآيات بالتساوي داخل كل جزء. للحصول على دقة وجه-بوجه مطابقة لمصحف المدينة، يمكن استبدال الملف ببيانات QPC من [qul.tarteel.ai](https://qul.tarteel.ai/) (انظر `assets/data/README.md`).

## القرارات المعمارية

- **Riverpod v2**: اختير لخفة الوزن وإمكانية الاختبار بدون BuildContext.
- **Repository pattern** منفصل عن الواجهة، مع `PlanController` (AsyncNotifier) كطبقة Application.
- **Scheduler pure**: لا يعتمد على DB أو حالة — يسهل اختباره بالكامل بوحدات.
- **مرجع فقط** بدلاً من عرض نص القرآن — المستخدم يفتح مصحفه الخاص.

## خارج نطاق النسخة 1

- عرض نص القرآن أو صوت التلاوة.
- إحصائيات (سلاسل، تقدّم إجمالي، سجل).
- مزامنة سحابية أو تعدد مستخدمين.
- خوارزمية Spaced Repetition للربط.

## الترخيص

مشروع شخصي.
