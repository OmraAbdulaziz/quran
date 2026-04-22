import 'package:sqflite/sqflite.dart';

import '../../../core/utils/date_utils.dart';
import '../domain/models/daily_plan.dart';

class PlanRepository {
  final Database _db;
  PlanRepository(this._db);

  // ---- daily_plan ----

  Future<DailyPlan?> readByDate(DateTime date) async {
    final rows = await _db.query(
      'daily_plan',
      where: 'date = ?',
      whereArgs: [formatYmd(date)],
      limit: 1,
    );
    return rows.isEmpty ? null : DailyPlan.fromRow(rows.first);
  }

  Future<void> upsert(DailyPlan plan) async {
    await _db.insert(
      'daily_plan',
      plan.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(DateTime date) async {
    await _db.delete(
      'daily_plan',
      where: 'date = ?',
      whereArgs: [formatYmd(date)],
    );
  }

  /// الخطط غير المكتملة التي تاريخها قبل [today] (لكشف الأيام الفائتة).
  Future<List<DailyPlan>> readIncompleteBefore(DateTime today) async {
    final rows = await _db.query(
      'daily_plan',
      where: 'completed_at IS NULL AND date < ?',
      whereArgs: [formatYmd(today)],
      orderBy: 'date ASC',
    );
    return rows.map(DailyPlan.fromRow).toList();
  }

  // ---- completed_portions ----

  Future<int> appendCompleted(CompletedPortion portion) =>
      _db.insert('completed_portions', portion.toRow());

  Future<List<CompletedPortion>> readLastCompleted(int limit) async {
    final rows = await _db.query(
      'completed_portions',
      orderBy: 'id DESC',
      limit: limit,
    );
    return rows.map(CompletedPortion.fromRow).toList();
  }
}
