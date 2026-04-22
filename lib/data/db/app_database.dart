import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';

class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;
  Database get db => _db;

  static AppDatabase? _instance;

  static Future<AppDatabase> open({Database? override}) async {
    if (_instance != null) return _instance!;
    late final Database db;
    if (override != null) {
      db = override;
    } else {
      final String dbPath;
      if (kIsWeb) {
        // على الويب: اسم منطقي فقط — البيانات تُحفظ في IndexedDB.
        dbPath = 'quran_tracker.db';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        dbPath = p.join(dir.path, 'quran_tracker.db');
      }
      db = await openDatabase(
        dbPath,
        version: Migrations.latestVersion,
        onCreate: (d, v) => Migrations.createAll(d),
        onUpgrade: (d, oldV, newV) => Migrations.upgrade(d, oldV, newV),
      );
    }
    final instance = AppDatabase._(db);
    _instance = instance;
    return instance;
  }

  /// للاختبارات.
  static Future<void> reset() async {
    await _instance?._db.close();
    _instance = null;
  }
}
