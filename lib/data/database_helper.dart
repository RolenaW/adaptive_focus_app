import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal(); //shared helper for the app / singleton
  static Database? _database; //stores opened database in memory
  static const String _databaseName = 'adaptive_focus_studio.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initializeDatabase();
    return _database!;
  }
  Future<Database> _initializeDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onConfigure: _configureDatabase,
    );
  }
  Future<void> _configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  Future<void> _createDatabase(Database db, int version) async {}
}