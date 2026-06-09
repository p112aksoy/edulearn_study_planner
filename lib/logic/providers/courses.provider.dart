import 'package:flutter/material.dart';
import 'package:edulearn/data/models/course_model.dart';
import 'package:edulearn/data/repositories/course_repository.dart';
// manages the state of courses and automatically updates the UI when data changes
class CoursesProvider with ChangeNotifier {
  final CourseRepository repository;
  final int userId;

  CoursesProvider({required this.repository, required this.userId});

  List<CourseModel> _courses = [];
  List<CourseModel> get courses => List.unmodifiable(_courses);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadCourses() async {
    _setLoading(true);
    try {
      _courses = await repository.fetchCourses(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load courses';
      debugPrint('loadCourses error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCourse(String name, int hours) async {
    try {
      final course = CourseModel(
        title: name.trim(),
        targetHours: hours,
        progress: 0,
      );
      await repository.addCourse(course, userId);
      await loadCourses();
      return true;
    } catch (e) {
      debugPrint('addCourse error: $e');
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      await repository.deleteCourse(id);
      _courses.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('deleteCourse error: $e');
      return false;
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      await repository.updateCourse(course);
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('updateCourse error: $e');
    }
  }

  Future<void> updateProgress(int courseId, int addMinutes) async {
    try {
      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index == -1) return;
      final course = _courses[index];
      final targetMinutes = course.targetHours * 60;
      if (targetMinutes <= 0) return;
      // calculates the new progress percentage based on added minutes
      final currentMinutes = ((course.progress / 100) * targetMinutes).round();
      final newProgress = (((currentMinutes + addMinutes) / targetMinutes) * 100)
          .clamp(0, 100)
          .round();
      final updated = course.copyWith(progress: newProgress);
      await repository.updateCourse(updated);
      _courses[index] = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('updateProgress error: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    // tells the Flutter UI to rebuild and show the new data, loading spinner
    notifyListeners();
  }
}