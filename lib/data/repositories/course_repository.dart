import 'package:flutter/foundation.dart';
import 'package:edulearn/data/dao/course_dao.dart';
import 'package:edulearn/data/models/course_model.dart';

class CourseRepository {
  final CourseDao _dao;
// acts as a bridge between the user interface (UI) and the database (DAO)
  CourseRepository({CourseDao? dao}) : _dao = dao ?? CourseDao();
// fetches courses and handles any database errors safely
  Future<List<CourseModel>> fetchCourses(int userId) async {
    try {
      return await _dao.getCourses(userId);
    } catch (e) {
      debugPrint('CourseRepository.fetchCourses error: $e');
      return [];
    }
  }

  Future<void> addCourse(CourseModel course, int userId) async {
    try {
      await _dao.insertCourse(course, userId);
    } catch (e) {
      debugPrint('CourseRepository.addCourse error: $e');
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await _dao.deleteCourse(id);
    } catch (e) {
      debugPrint('CourseRepository.deleteCourse error: $e');
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      await _dao.updateCourse(course);
    } catch (e) {
      debugPrint('CourseRepository.updateCourse error: $e');
    }
  }
}