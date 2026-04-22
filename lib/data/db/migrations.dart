import 'package:sqflite/sqflite.dart';

class Migrations {
  const Migrations._();

  static const int latestVersion = 1;

  static Future<void> createAll(Database d) async {
    await d.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        daily_amount_wajh REAL NOT NULL,
        memorization_weekdays TEXT NOT NULL,
        rabt_count INTEGER NOT NULL DEFAULT 5,
        current_surah INTEGER NOT NULL,
        current_ayah  INTEGER NOT NULL,
        notify_hour INTEGER,
        notify_minute INTEGER,
        onboarded INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await d.execute('''
      CREATE TABLE daily_plan (
        date TEXT PRIMARY KEY,
        nisab_start_surah INTEGER NOT NULL,
        nisab_start_ayah INTEGER NOT NULL,
        nisab_end_surah INTEGER NOT NULL,
        nisab_end_ayah INTEGER NOT NULL,
        nisab_done INTEGER NOT NULL DEFAULT 0,
        takrar_done INTEGER NOT NULL DEFAULT 0,
        rabt_done INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT
      )
    ''');

    await d.execute('''
      CREATE TABLE completed_portions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        completed_date TEXT NOT NULL,
        start_surah INTEGER NOT NULL,
        start_ayah INTEGER NOT NULL,
        end_surah INTEGER NOT NULL,
        end_ayah INTEGER NOT NULL
      )
    ''');

    await d.execute(
      'CREATE INDEX idx_completed_date ON completed_portions(completed_date DESC)',
    );
  }

  static Future<void> upgrade(Database d, int oldV, int newV) async {
    // لا ترقيات بعد.
  }
}
