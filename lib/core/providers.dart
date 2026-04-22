import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../data/db/app_database.dart';
import '../data/quran/quran_meta.dart';
import '../features/planner/data/plan_repository.dart';
import '../features/planner/data/settings_repository.dart';
import '../features/planner/domain/scheduler.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  final app = await AppDatabase.open();
  return app.db;
});

final quranMetaProvider = FutureProvider<QuranMeta>((ref) async {
  return QuranMetaLoader().load();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dbAsync = ref.watch(databaseProvider);
  return SettingsRepository(dbAsync.requireValue);
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final dbAsync = ref.watch(databaseProvider);
  return PlanRepository(dbAsync.requireValue);
});

final schedulerProvider = Provider<Scheduler>((ref) {
  final meta = ref.watch(quranMetaProvider).requireValue;
  return Scheduler(meta);
});
