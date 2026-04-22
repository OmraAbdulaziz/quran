import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../planner/data/user_settings.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'daily_memorization';
  static const _channelName = 'ورد الحفظ اليومي';
  static const _channelDescription = 'تذكير بوقت التسميع اليومي';
  static const _baseId = 1000;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _ensureAndroidChannel();
    _initialized = true;
  }

  Future<void> _ensureAndroidChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
  }

  /// يطلب صلاحية الإشعارات (Android 13+ و iOS).
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// يعيد جدولة الإشعارات الأسبوعية بناءً على الإعدادات الحالية.
  Future<void> reschedule(UserSettings s) async {
    if (!_initialized) await init();
    await _plugin.cancelAll();

    final hour = s.notifyHour;
    final minute = s.notifyMinute;
    if (hour == null || minute == null || s.memorizationWeekdays.isEmpty) {
      return;
    }

    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    for (final wd in s.memorizationWeekdays) {
      final first = _nextInstance(hour, minute, wd);
      await _plugin.zonedSchedule(
        _baseId + wd,
        'حان وقت ورد الحفظ',
        'انطلق لنصاب اليوم، بارك الله فيك.',
        first,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// يحسب موعد أول إشعار في اليوم المستهدف.
  tz.TZDateTime _nextInstance(int hour, int minute, int isoWeekday) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (d.weekday != isoWeekday || d.isBefore(now)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}
