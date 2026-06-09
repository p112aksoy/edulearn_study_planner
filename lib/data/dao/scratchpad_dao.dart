import 'package:flutter/foundation.dart';
import 'package:edulearn/data/database/database_helper.dart';
import 'package:edulearn/data/models/scratchpad_model.dart';

// manages all database (CRUD) operations for the scratchpad notes
class ScratchpadDao {

  // fetches all notes belonging to the given user, newest first
  Future<List<ScratchpadModel>> getAllNotes(int userId) async {
    try {
      final db = await DatabaseHelper.db;
      final result = await db.query(
        'scratchpad',
        where: 'userId = ?',
        whereArgs: [userId],
        // orders notes so the newest ones appear at the top
        orderBy: 'id DESC',
      );
      // converts each database row into a ScratchpadModel object
      return result.map((e) => ScratchpadModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('ScratchpadDao.getAllNotes error: $e');
      return [];
    }
  }

  // inserts a new note into the database for the given user
  Future<int?> insertNote(String task, int userId) async {
    try {
      final db = await DatabaseHelper.db;
      // creates model with isDone false by default for new notes
      final model = ScratchpadModel(task: task, isDone: false);
      final map = model.toMap();
      map['userId'] = userId;
      return await db.insert('scratchpad', map);
    } catch (e) {
      debugPrint('ScratchpadDao.insertNote error: $e');
      return null;
    }
  }

  // marks a note as completed by updating isDone to 1 (true) in sqlite
  Future<bool> markDone(int id) async {
    try {
      final db = await DatabaseHelper.db;
      final count = await db.update(
        'scratchpad',
        // 1 represents true in sqlite boolean convention
        {'isDone': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      // returns true only if at least one row was updated
      return count > 0;
    } catch (e) {
      debugPrint('ScratchpadDao.markDone error: $e');
      return false;
    }
  }

  // permanently removes a note from the database by its id
  Future<bool> deleteNote(int id) async {
    try {
      final db = await DatabaseHelper.db;
      final count = await db.delete(
        'scratchpad',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      debugPrint('ScratchpadDao.deleteNote error: $e');
      return false;
    }
  }
}