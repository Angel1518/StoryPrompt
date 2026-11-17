import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/story_models.dart';

class StoryRepository {
  StoryRepository({Database? testDb}) : _db = testDb;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'story_prompt.db'),
      version: 1,
      onCreate: createSchema,
    );
    return _db!;
  }

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE personas (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        relation TEXT NOT NULL DEFAULT '',
        birth_year INTEGER,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sesiones (
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        topic TEXT NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE fragmentos (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        prompt_question TEXT NOT NULL DEFAULT '',
        verbatim_quote TEXT NOT NULL,
        chapter_title TEXT NOT NULL DEFAULT 'Sin clasificar',
        is_reviewed INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<List<Persona>> listPeople() async {
    final db = await database;
    final rows = await db.query('personas', orderBy: 'created_at DESC');
    return rows.map(Persona.fromMap).toList();
  }

  Future<List<Sesion>> listSessions() async {
    final db = await database;
    final rows = await db.query('sesiones', orderBy: 'recorded_at DESC');
    return rows.map(Sesion.fromMap).toList();
  }

  Future<List<Fragmento>> listFragments() async {
    final db = await database;
    final rows = await db.query('fragmentos');
    return rows.map(Fragmento.fromMap).toList();
  }

  Future<void> upsertPerson(Persona person) async {
    final db = await database;
    await db.insert('personas', person.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveSessionWithFragment({
    required Sesion session,
    required Fragmento fragment,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('sesiones', session.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('fragmentos', fragment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> upsertFragment(Fragmento fragment) async {
    final db = await database;
    await db.insert('fragmentos', fragment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

