import 'package:flutter/material.dart';
import 'package:edulearn/data/models/deadline_mode.dart';
import 'package:edulearn/data/models/scratchpad_model.dart';
import 'package:edulearn/data/repositories/deadline_repository.dart';
import 'package:edulearn/data/repositories/scratchpad_repository.dart';

// manages the state of both deadlines and scratchpad notes for the home screen
class HomeProvider with ChangeNotifier {
  final DeadlineRepository _deadlineRepo;
  final ScratchpadRepository _scratchpadRepo;
  final int userId;

  HomeProvider({
    required this.userId,
    DeadlineRepository? deadlineRepository,
    ScratchpadRepository? scratchpadRepository,
  })  : _deadlineRepo = deadlineRepository ?? DeadlineRepository(),
        _scratchpadRepo = scratchpadRepository ?? ScratchpadRepository() {
    // loads all data immediately when the provider is first created
    loadAllData();
  }

  List<Deadline> _deadlines = [];
  List<ScratchpadModel> _scratchNotes = [];

  // exposes unmodifiable lists to prevent direct mutation from the UI
  List<Deadline> get deadlines => List.unmodifiable(_deadlines);
  List<ScratchpadModel> get scratchNotes => List.unmodifiable(_scratchNotes);

  // loads both deadlines and scratchpad notes in sequence
  Future<void> loadAllData() async {
    await loadDeadlines();
    await loadScratchNotes();
  }

  // fetches deadlines from repository and sorts them by date
  Future<void> loadDeadlines() async {
    try {
      _deadlines = await _deadlineRepo.fetchDeadlines(userId);
      _sortDeadlines();
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider.loadDeadlines error: $e');
    }
  }

  // creates a new deadline with a unique timestamp id and saves it
  Future<void> addDeadline(String title, DateTime date) async {
    try {
      final newDeadline = Deadline(
        // millisecondsSinceEpoch ensures a unique string id for each deadline
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        date: date,
      );
      // optimistic update: adds to local list before saving to database
      _deadlines.add(newDeadline);
      _sortDeadlines();
      notifyListeners();
      await _deadlineRepo.addDeadline(newDeadline, userId);
    } catch (e) {
      debugPrint('HomeProvider.addDeadline error: $e');
    }
  }

  // removes deadline from local list instantly then deletes from database
  Future<void> removeDeadline(String id) async {
    try {
      _deadlines.removeWhere((item) => item.id == id);
      notifyListeners();
      await _deadlineRepo.removeDeadline(id);
    } catch (e) {
      debugPrint('HomeProvider.removeDeadline error: $e');
    }
  }

  // sorts deadlines in ascending order so the nearest deadline appears first
  void _sortDeadlines() {
    _deadlines.sort((a, b) => a.date.compareTo(b.date));
  }

  // fetches all scratchpad notes for the current user from the repository
  Future<void> loadScratchNotes() async {
    try {
      _scratchNotes = await _scratchpadRepo.fetchNotes(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider.loadScratchNotes error: $e');
    }
  }

  // adds a new note and reloads the full list to keep state in sync
  Future<void> addScratchNote(String task) async {
    try {
      final success = await _scratchpadRepo.addNote(task, userId);
      if (success) await loadScratchNotes();
    } catch (e) {
      debugPrint('HomeProvider.addScratchNote error: $e');
    }
  }

  // optimistic update: marks note as done in local state before database call
  Future<void> completeScratchNote(int index) async {
    try {
      if (index < 0 || index >= _scratchNotes.length) return;
      final note = _scratchNotes[index];
      // copyWith creates a new model instance with isDone set to true
      _scratchNotes[index] = note.copyWith(isDone: true);
      notifyListeners();
      await _scratchpadRepo.markNoteAsDone(note.id!);
    } catch (e) {
      debugPrint('HomeProvider.completeScratchNote error: $e');
    }
  }

  // removes the note from local list then permanently deletes from database
  Future<void> removeScratchNoteAt(int index) async {
    try {
      if (index < 0 || index >= _scratchNotes.length) return;
      final note = _scratchNotes[index];
      _scratchNotes.removeAt(index);
      notifyListeners();
      await _scratchpadRepo.deleteNote(note.id!);
    } catch (e) {
      debugPrint('HomeProvider.removeScratchNoteAt error: $e');
    }
  }
}