import 'package:sqflite/sqflite.dart';

import 'user_settings.dart';

class SettingsRepository {
  final Database _db;
  SettingsRepository(this._db);

  Future<UserSettings?> read() async {
    final rows = await _db.query('settings', where: 'id = 1');
    if (rows.isEmpty) return null;
    return UserSettings.fromRow(rows.first);
  }

  Future<void> write(UserSettings s) async {
    await _db.insert(
      'settings',
      s.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserSettings> ensureDefaults() async {
    final existing = await read();
    if (existing != null) return existing;
    final defaults = UserSettings.defaults();
    await write(defaults);
    return defaults;
  }
}
