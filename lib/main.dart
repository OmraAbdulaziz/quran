import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  if (kIsWeb) {
    // على الويب: نستخدم sqflite بنسخة IndexedDB/WASM.
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // الإشعارات المحلية لا تعمل على الويب.
    await NotificationService.instance.init();
  }

  runApp(const ProviderScope(child: QuranTrackerApp()));
}
