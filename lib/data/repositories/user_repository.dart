import 'package:flutter/foundation.dart';
import 'package:edulearn/data/dao/user_dao.dart';
import 'package:edulearn/data/models/user_model.dart';

class UserRepository {
  final UserDao _dao;

  UserRepository({UserDao? dao}) : _dao = dao ?? UserDao();

  Future<int?> registerUser(UserModel user) async {
    final normalizedUser = user.copyWith(
      email: user.email.trim().toLowerCase(),
    );

    try {
      final id = await _dao.insertUser(normalizedUser);

      debugPrint("USER INSERTED SUCCESSFULLY, ID = $id");

      return id;
    } catch (e, stack) {
      debugPrint(" registerUser FAILED: $e");
      debugPrint(stack.toString());

      rethrow;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      return await _dao.getUserByEmail(email.trim().toLowerCase());
    } catch (e, stack) {
      debugPrint(" getUserByEmail error: $e");
      debugPrint(stack.toString());
      return null;
    }
  }

  Future<UserModel?> getUserById(int id) async {
    try {
      return await _dao.getUserById(id);
    } catch (e, stack) {
      debugPrint(" getUserById error: $e");
      debugPrint(stack.toString());
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(
        email: user.email.trim().toLowerCase(),
      );

      await _dao.updateUser(updatedUser);
      return true;
    } catch (e, stack) {
      debugPrint(" updateUser error: $e");
      debugPrint(stack.toString());
      return false;
    }
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      await _dao.updatePassword(
        email.trim().toLowerCase(),
        newPassword,
      );
      return true;
    } catch (e, stack) {
      debugPrint(" updatePassword error: $e");
      debugPrint(stack.toString());
      return false;
    }
  }

  Future<bool> deleteAllUsers() async {
    try {
      await _dao.deleteAllUsers();
      return true;
    } catch (e, stack) {
      debugPrint(" deleteAllUsers error: $e");
      debugPrint(stack.toString());
      return false;
    }
  }
}