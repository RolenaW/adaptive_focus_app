import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper { //DatabaseHelper class created
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal(); //shared helper for the app / singleton
  static Database? _database; //stores opened database in memory
  static const int _databaseVersion = 1;
  static const String _databaseName = 'adaptive_focus_studio.db';
  static const String focusSessionsTable = 'focus_sessions';
  static const String soundPresetsTable = 'sound_presets';
  static const String sessionBlueprintsTable = 'session_blueprints';

  Future<Database> get database async { //gives access to database instance
    if (_database != null) { //if the database already exist then it's returned
      return _database!;
    }
    _database = await _initializeDatabase(); //opens database
    return _database!;
  }
  Future<Database> _initializeDatabase() async { //gives access to 
    final String databasesPath = await getDatabasesPath(); //database folder
    final String path = join(databasesPath, _databaseName); //builds files

    return openDatabase( //opens database
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onConfigure: _configureDatabase,
    );
  }
  Future<void> _configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON'); //foreign key support
  }
  Future<void> _createDatabase(Database db, int version) async { //focus session table created
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
    //sound presets table
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
  //session blueprint table
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
  Future<int> createFocusSession(Map<String, dynamic> sessionData) async { //insert new row into table
    final Database db = await database;
    return db.insert(focusSessionsTable, sessionData); //return row ID
  }

  Future<List<Map<String, dynamic>>> getAllFocusSessions() async { //returns all saved sessions
    final Database db = await database;
    return db.query(
      focusSessionsTable,
      orderBy: 'created_at DESC', //shows the newest sessions first
    );
  }

  Future<Map<String, dynamic>?> getFocusSessionById(int id) async { //returns a session by ID
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      focusSessionsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );

    if (results.isEmpty) { //not found then null
      return null;
    }

    return results.first;
  }
  Future<int> updateFocusSession( //updates row using its ID
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

  Future<int> deleteFocusSession(int id) async { //deletes row by ID
    final Database db = await database;

    return db.delete(
      focusSessionsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<int> createSoundPreset(Map<String, dynamic> presetData) async { //SOUND PRESET: same operations as focus 
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
Future<int> createSessionBlueprint(Map<String, dynamic> blueprintData) async { //SESSION BLUEPRINT: same operations as focus 
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
}