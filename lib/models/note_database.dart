import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moments_diary/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  // Initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(name: "note db", [NoteSchema], directory: dir.path);
  }

  // list of notes
  final List<Note> currentNotes = [];

  // add note
  Future<void> addNote(String newContent) async {
    var newNote = Note();
    newNote.content = newContent;
    newNote.createdAt = DateTime.now();

    // save in db
    await isar.writeTxn(() => isar.notes.put(newNote));

    // reread to update changes
    await fetchNotes();
  }

  // Get notes
  Future<void> fetchNotes() async {
    List<Note> fetched =
        await isar.notes.where().sortByCreatedAtDesc().findAll();

    currentNotes.clear();
    currentNotes.addAll(fetched);
    notifyListeners();
  }

  // Update note
  Future<void> updateNote(int id, String newContent) async {
    final existing = await isar.notes.get(id);
    if (existing != null) {
      existing.content = newContent;
      existing.updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.notes.put(existing));
      await fetchNotes();
    }
  }

  // Delete note
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}
