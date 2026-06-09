import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edulearn/data/models/user_model.dart';
import 'package:edulearn/data/repositories/user_repository.dart';
import 'package:edulearn/data/database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _repository;

  AuthProvider({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  UserModel? _currentUser;
  bool _isLoggedIn  = false;
  bool _isLoading   = false;
  String? _errorMessage;

  UserModel? get currentUser  => _currentUser;
  bool get isLoggedIn          => _isLoggedIn;
  bool get isLoading           => _isLoading;
  String? get errorMessage     => _errorMessage;

  // for init part

  Future<void> checkLoginStatus() async {
    _setLoading(true);
    try {
      final prefs  = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) { _setLoggedOut(); return; }

      final user = await _repository.getUserById(userId);

      if (user == null) {
        await prefs.remove('userId');
        _setLoggedOut();
        return;
      }

      _currentUser  = user;
      _isLoggedIn   = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load session.";
      _setLoggedOut();
    } finally {
      _setLoading(false);
    }
  }

  // for login part, i did

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _repository.getUserByEmail(email.trim().toLowerCase());

      if (user == null) {
        _errorMessage = "No account found with this email.";
        return false;
      }

      if (user.password != password) {
        _errorMessage = "Incorrect password.";
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      _currentUser = user;
      _isLoggedIn  = true;
      return true;
    } catch (e) {
      _errorMessage = "Login failed: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // for register section

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? studentId,
    String? major,
    String? school,
    String? year,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final existing = await _repository.getUserByEmail(email.trim().toLowerCase());
      if (existing != null) {
        _errorMessage = "An account with this email already exists.";
        return false;
      }

      final newUser = UserModel(
        fullName:  fullName.trim(),
        email:     email.trim().toLowerCase(),
        password:  password,
        studentId: studentId,
        major:     major,
        school:    school,
        year:      year,
      );

      final id = await _repository.registerUser(newUser);

      if (id == null) {
        _errorMessage = "Database failed to return a valid User ID.";
        return false;
      }

      _currentUser = newUser.copyWith(id: id);
      _isLoggedIn  = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', id);

      return true;
    } catch (e, stacktrace) {
      debugPrint("CRITICAL REGISTRATION ERROR: $e");
      debugPrint("STACKTRACE: $stacktrace");
      _errorMessage = "Error: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // for reset password

  Future<String?> resetPassword(String email) async {
    _setLoading(true);
    try {
      final user = await _repository.getUserByEmail(email.trim().toLowerCase());
      if (user == null) return null;

      final newPassword = _generateRandomPassword();
      final success = await _repository.updatePassword(
          email.trim().toLowerCase(), newPassword);

      return success ? newPassword : null;
    } finally {
      _setLoading(false);
    }
  }

  // for logout section

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _setLoggedOut();
    notifyListeners();
  }

  // for delete account
  // deleting all datas which belongs users: users, courses , SharedPreferences

  Future<void> deleteAccount() async {
    try {
      // 1. delete all things in database(users ,courses)
      await DatabaseHelper.deleteAllData();

      // 2. delete in SharedPreferences session temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      // 3. state makes null
      _setLoggedOut();
      notifyListeners();
    } catch (e) {
      debugPrint("deleteAccount error: $e");
    }
  }

  // for helpers

  void _setLoggedOut() {
    _currentUser  = null;
    _isLoggedIn   = false;
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _generateRandomPassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    final seed = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
        8, (i) => chars[(seed + i * 7) % chars.length]).join();
  }
}


