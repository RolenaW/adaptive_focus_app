import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Private constructor for singleton pattern
  DatabaseHelper._internal();

  // One shared instance of this helper
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Cached database object
  static Database? _database;

  // Database name and version
  static const int _databaseVersion = 1;
  static const String _databaseName = 'adaptive_focus_studio.db';

  // Table names
  static const String focusSessionsTable = 'focus_sessions';
  static const String soundPresetsTable = 'sound_presets';
  static const String sessionBlueprintsTable = 'session_blueprints';

  // Get database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  // Create/open database file
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

  // Enable foreign keys in SQLite
  Future<void> _configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create tables the first time the database is built
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $focusSessionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_name TEXT NOT NULL,
        mood TEXT NOT NULL,
        task_type TEXT NOT NULL,
        energy_level INTEGER NOT NULL,
        work_duration_minutes INTEGER NOT NULL,
        break_duration_minutes INTEGER NOT NULL,
        session_date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $soundPresetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_name TEXT NOT NULL,
        rain_enabled INTEGER NOT NULL DEFAULT 0,
        cafe_enabled INTEGER NOT NULL DEFAULT 0,
        white_noise_enabled INTEGER NOT NULL DEFAULT 0,
        nature_enabled INTEGER NOT NULL DEFAULT 0,
        instrumental_enabled INTEGER NOT NULL DEFAULT 0,
        master_volume REAL NOT NULL DEFAULT 0.5,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $sessionBlueprintsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        blueprint_name TEXT NOT NULL,
        mood TEXT NOT NULL,
        task_type TEXT NOT NULL,
        energy_level INTEGER NOT NULL,
        work_duration_minutes INTEGER NOT NULL,
        break_duration_minutes INTEGER NOT NULL,
        preset_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (preset_id) REFERENCES $soundPresetsTable (id)
          ON DELETE SET NULL
      )
    ''');
  }

  // -----------------------------
  // Focus session CRUD
  // -----------------------------

  // Create a new focus session
  Future<int> createFocusSession(Map<String, dynamic> sessionData) async {
    final Database db = await database;
    return db.insert(focusSessionsTable, sessionData);
  }

  // Read all focus sessions, newest first
  Future<List<Map<String, dynamic>>> getAllFocusSessions() async {
    final Database db = await database;
    return db.query(
      focusSessionsTable,
      orderBy: 'created_at DESC',
    );
  }

  // Read one focus session by ID
  Future<Map<String, dynamic>?> getFocusSessionById(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      focusSessionsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  // Update one focus session
  Future<int> updateFocusSession(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    final Database db = await database;

    return db.update(
      focusSessionsTable,
      updatedData,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  // Delete one focus session
  Future<int> deleteFocusSession(int id) async {
    final Database db = await database;

    return db.delete(
      focusSessionsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  // -----------------------------
  // Sound preset CRUD
  // -----------------------------

  Future<int> createSoundPreset(Map<String, dynamic> presetData) async {
    final Database db = await database;
    return db.insert(soundPresetsTable, presetData);
  }

  Future<List<Map<String, dynamic>>> getAllSoundPresets() async {
    final Database db = await database;
    return db.query(
      soundPresetsTable,
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getSoundPresetById(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      soundPresetsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  Future<int> updateSoundPreset(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    final Database db = await database;

    return db.update(
      soundPresetsTable,
      updatedData,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<int> deleteSoundPreset(int id) async {
    final Database db = await database;

    return db.delete(
      soundPresetsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  // -----------------------------
  // Session blueprint CRUD
  // -----------------------------

  Future<int> createSessionBlueprint(Map<String, dynamic> blueprintData) async {
    final Database db = await database;
    return db.insert(sessionBlueprintsTable, blueprintData);
  }

  Future<List<Map<String, dynamic>>> getAllSessionBlueprints() async {
    final Database db = await database;
    return db.query(
      sessionBlueprintsTable,
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getSessionBlueprintById(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      sessionBlueprintsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  Future<int> updateSessionBlueprint(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    final Database db = await database;

    return db.update(
      sessionBlueprintsTable,
      updatedData,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<int> deleteSessionBlueprint(int id) async {
    final Database db = await database;

    return db.delete(
      sessionBlueprintsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  // Close database when needed
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}