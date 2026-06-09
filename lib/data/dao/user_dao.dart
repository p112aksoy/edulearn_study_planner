import 'package:sqflite/sqflite.dart'; // Add this import for ConflictAlgorithm
import 'package:edulearn/data/database/database_helper.dart';
import 'package:edulearn/data/models/user_model.dart';

class UserDao {
  Future<int> insertUser(UserModel user) async {
    final db = await DatabaseHelper.db;
    // conflictAlgorithm.replace will update the record if it already exists
    // instead of throwing an error that returns null/0
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      'users',
      // trim() and toLowerCase() ensure standardizing emails to avoid typos
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await DatabaseHelper.db;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await DatabaseHelper.db;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> updatePassword(String email, String newPassword) async {
    final db = await DatabaseHelper.db;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  Future<void> deleteAllUsers() async {
    final db = await DatabaseHelper.db;
    await db.delete('users');
  }
}