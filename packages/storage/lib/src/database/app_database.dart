import 'package:storage/src/database/database_helper.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  AppDatabase._init();

  Future<Database> get database => _dbHelper.database;

  Future<void> close() => _dbHelper.close();
}
