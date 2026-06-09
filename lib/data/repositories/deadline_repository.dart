import 'package:flutter/foundation.dart';
import 'package:edulearn/data/dao/deadline_dao.dart';
import 'package:edulearn/data/models/deadline_mode.dart';

class DeadlineRepository {
  final DeadlineDao _dao;
// serves as a clean API for the UI to access deadline data
  DeadlineRepository({DeadlineDao? dao}) : _dao = dao ?? DeadlineDao();

  Future<List<Deadline>> fetchDeadlines(int userId) async {
    try {
      return await _dao.getAllDeadlines(userId);
    } catch (e) {
      debugPrint('DeadlineRepository.fetchDeadlines error: $e');
      return [];
    }
  }

  Future<bool> addDeadline(Deadline deadline, int userId) async {
    try {
      final id = await _dao.insertDeadline(deadline, userId);
      return id != null;// returns true if the database successfully saves the item
    } catch (e) {
      debugPrint('DeadlineRepository.addDeadline error: $e');
      return false;
    }
  }

  Future<bool> removeDeadline(String id) async {
    try {
      return await _dao.deleteDeadline(id);
    } catch (e) {
      debugPrint('DeadlineRepository.removeDeadline error: $e');
      return false;
    }
  }
}