import 'package:flutter/foundation.dart';
import 'package:edulearn/data/dao/scratchpad_dao.dart';
import 'package:edulearn/data/models/scratchpad_model.dart';

// acts as a middleman between the UI/provider layer and the database (DAO)
class ScratchpadRepository {
  final ScratchpadDao _dao;

  // allows injecting a custom DAO for testing purposes
  ScratchpadRepository({ScratchpadDao? dao}) : _dao = dao ?? ScratchpadDao();

  // fetches all notes for the given user from the database
  Future<List<ScratchpadModel>> fetchNotes(int userId) async {
    try {
      return await _dao.getAllNotes(userId);
    } catch (e) {
      debugPrint('ScratchpadRepository.fetchNotes error: $e');
      return [];
    }
  }

  // adds a new note and returns true if the operation was successful
  Future<bool> addNote(String task, int userId) async {
    try {
      final id = await _dao.insertNote(task, userId);
      // returns true if the database successfully saved the item
      return id != null;
    } catch (e) {
      debugPrint('ScratchpadRepository.addNote error: $e');
      return false;
    }
  }

  // marks a note as done and returns true if the update was successful
  Future<bool> markNoteAsDone(int id) async {
    try {
      return await _dao.markDone(id);
    } catch (e) {
      debugPrint('ScratchpadRepository.markNoteAsDone error: $e');
      return false;
    }
  }

  // deletes a note permanently and returns true if successful
  Future<bool> deleteNote(int id) async {
    try {
      return await _dao.deleteNote(id);
    } catch (e) {
      debugPrint('ScratchpadRepository.deleteNote error: $e');
      return false;
    }
  }
}