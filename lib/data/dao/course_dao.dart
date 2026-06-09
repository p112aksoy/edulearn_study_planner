import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:edulearn/data/database/database_helper.dart';
import 'package:edulearn/data/models/course_model.dart';
// This class handles all Database (CRUD) operations for the Course model
class CourseDao {
  Future<List<CourseModel>> getCourses(int userId) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      'courses',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    // Converts database rows (maps) into a list of CourseModel objects
    return result.map((e) => CourseModel.fromMap(e)).toList();
  }

  Future<void> insertCourse(CourseModel course, int userId) async {
    final db = await DatabaseHelper.db;
    final map = course.toMap();
    map['userId'] = userId;
    await db.insert('courses', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCourse(int id) async {
    final db = await DatabaseHelper.db;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCourse(CourseModel course) async {
    final db = await DatabaseHelper.db;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }
}