import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Database? _db;
// opens the database only once and reuses it
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            email TEXT UNIQUE,
            password TEXT,
            studentId TEXT,
            major TEXT,
            school TEXT,
            year TEXT,
            photoUrl TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            title TEXT,
            progress INTEGER,
            targetHours INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE deadlines(
            id TEXT PRIMARY KEY,
            userId INTEGER NOT NULL,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE scratchpad(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            task TEXT NOT NULL,
            isDone INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
      // updates the database tables when you increase the version number
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE users ADD COLUMN photoUrl TEXT');
          } catch (e) {
            debugPrint('DatabaseHelper onUpgrade (v3): $e');
          }
        }

        if (oldVersion < 4) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS deadlines(
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                date TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS scratchpad(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                task TEXT NOT NULL,
                isDone INTEGER NOT NULL
              )
            ''');
          } catch (e) {
            debugPrint('DatabaseHelper onUpgrade (v4): $e');
          }
        }

        // v5: userId is adding
        if (oldVersion < 5) {
          try {
            await db.execute(
              'ALTER TABLE courses ADD COLUMN userId INTEGER NOT NULL DEFAULT 1',
            );
          } catch (e) {
            debugPrint('DatabaseHelper onUpgrade (v5) courses: $e');
          }
          try {
            await db.execute(
              'ALTER TABLE deadlines ADD COLUMN userId INTEGER NOT NULL DEFAULT 1',
            );
          } catch (e) {
            debugPrint('DatabaseHelper onUpgrade (v5) deadlines: $e');
          }
          try {
            await db.execute(
              'ALTER TABLE scratchpad ADD COLUMN userId INTEGER NOT NULL DEFAULT 1',
            );
          } catch (e) {
            debugPrint('DatabaseHelper onUpgrade (v5) scratchpad: $e');
          }
        }
      },
    );
  }

  static Future<void> deleteAllData() async {
    final dbClient = await DatabaseHelper.db;
    await dbClient.delete('users');
    await dbClient.delete('courses');
    await dbClient.delete('deadlines');
    await dbClient.delete('scratchpad');
  }
}