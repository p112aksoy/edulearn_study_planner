import 'package:flutter/foundation.dart';
import 'package:edulearn/data/database/database_helper.dart';
import 'package:edulearn/data/models/deadline_mode.dart';
// manages database (CRUD) operations specifically for task deadlines
class DeadlineDao {
  Future<List<Deadline>> getAllDeadlines(int userId) async {
    try {
      final db = await DatabaseHelper.db;
      final result = await db.query(
        'deadlines',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return result.map((e) => Deadline.fromMap(e)).toList();
    } catch (e) {
      // catches and logs errors to prevent the app from crashing
      debugPrint('DeadlineDao.getAllDeadlines error: $e');
      return [];
    }
  }

  Future<int?> insertDeadline(Deadline deadline, int userId) async {
    try {
      final db = await DatabaseHelper.db;
      final map = deadline.toMap();
      map['userId'] = userId;
      return await db.insert('deadlines', map);
    } catch (e) {
      debugPrint('DeadlineDao.insertDeadline error: $e');
      return null;
    }
  }

  Future<bool> deleteDeadline(String id) async {
    try {
      final db = await DatabaseHelper.db;
      final count = await db.delete(
        'deadlines',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      debugPrint('DeadlineDao.deleteDeadline error: $e');
      return false;
    }
  }
}