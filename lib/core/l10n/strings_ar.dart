class Ar {
  const Ar._();

  static const appTitle = 'متابع الحفظ';

  // Onboarding
  static const onboardingWelcomeTitle = 'أهلاً بك';
  static const onboardingWelcomeSubtitle =
      'نساعدك على الالتزام بورد الحفظ اليومي بإذن الله';
  static const onboardingStartingPointTitle = 'من أين تبدأ؟';
  static const onboardingStartingPointSubtitle =
      'اختر السورة والآية التي تبدأ منها الحفظ';
  static const onboardingAmountTitle = 'كم تحفظ يومياً؟';
  static const onboardingAmountSubtitle = 'اختر المقدار الذي يناسبك';
  static const onboardingWeekdaysTitle = 'أيام التسميع';
  static const onboardingWeekdaysSubtitle = 'اختر الأيام التي تلتزم فيها';
  static const onboardingRabtTitle = 'مقدار الربط';
  static const onboardingRabtSubtitle =
      'كم نصاباً سابقاً تريد مراجعته كل يوم؟';
  static const onboardingNotifyTitle = 'وقت التذكير';
  static const onboardingNotifySubtitle = 'متى تريد أن نذكّرك؟';

  static const next = 'التالي';
  static const previous = 'السابق';
  static const finish = 'ابدأ';
  static const save = 'حفظ';
  static const cancel = 'إلغاء';
  static const confirm = 'تأكيد';

  // Amounts
  static const amountHalfWajh = 'نصف وجه';
  static const amountOneWajh = 'وجه';
  static const amountOnePage = 'صفحة';
  static const amountTwoPages = 'صفحتان';

  // Tasks
  static const taskNisab = 'النصاب';
  static const taskNisabDesc = 'حفظ الآيات المقررة لليوم';
  static const taskTakrar = 'التكرار';
  static const taskTakrarDesc = 'تكرار نصاب اليوم للتثبيت';
  static const taskRabt = 'الربط';
  static const taskRabtDesc = 'مراجعة النصابات السابقة';

  // Dashboard
  static const todayNisab = 'نصاب اليوم';
  static const fromAyah = 'من آية';
  static const toAyah = 'إلى آية';
  static const surah = 'سورة';
  static const noMemorizationToday = 'ليس من أيام التسميع';
  static const noMemorizationTodayHint =
      'استرح اليوم أو راجع ما حفظت. غداً رزق جديد بإذن الله';
  static const completedToday = 'أتممت ورد اليوم، بارك الله فيك';

  // Missed day
  static const missedDayTitle = 'فاتك يوم التسميع';
  static const missedDayBody =
      'هل تريد تعويض النصاب الفائت في يوم تسميع آخر، أم إكماله اليوم الخالي القادم؟';
  static const missedDayPush = 'تعويض باليوم التالي';
  static const missedDayFillGap = 'املأ اليوم الخالي';

  // Settings
  static const settings = 'الإعدادات';
  static const settingsAmount = 'المقدار اليومي';
  static const settingsWeekdays = 'أيام التسميع';
  static const settingsRabtCount = 'عدد نصابات الربط';
  static const settingsNotifyTime = 'وقت التذكير';
  static const settingsCurrentPosition = 'الموضع الحالي';
  static const settingsAbout = 'عن التطبيق';
  static const editPosition = 'تعديل الموضع';

  // Weekdays (ISO: Mon=1 .. Sun=7)
  static const weekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const weekdaysShort = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];

  // Pickers
  static const pickSurah = 'اختر السورة';
  static const pickAyah = 'اختر الآية';
  static const ayah = 'آية';
}
