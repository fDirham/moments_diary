import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moments_diary/models/monthly_activity_doc.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/utils.dart';
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
  Future<void> addNote(String newContent, bool isReflection) async {
    var newNote = Note();
    newNote.content = newContent;
    newNote.createdAt = DateTime.now();
    newNote.isReflection = isReflection;

    // save in db
    await isar.writeTxn(() => isar.notes.put(newNote));

    // reread to update changes
    await fetchNotes();

    // Updates calendar prefs
    final startDate = await getCalendarStartDate();
    if (startDate == null) {
      await setCalendarStartDate(newNote.createdAt);
    }
    await setCalendarEndDate(newNote.createdAt);

    // Update monthly activity doc
    final year = newNote.createdAt.year;
    final month = newNote.createdAt.month;
    final day = newNote.createdAt.day;

    final doc = await MonthlyActivityDoc.readFromDisk(year, month);
    doc.addNoteForDay(day, isReflection);
    await doc.saveToDisk();
  }

  // Get notes
  Future<void> fetchNotes() async {
    List<Note> fetched =
        await isar.notes.where().sortByCreatedAtDesc().findAll();

    currentNotes.clear();
    currentNotes.addAll(fetched);
    notifyListeners();
  }

  Future<List<Note>> fetchDayNotes(DateTime day) async {
    // Get start and end of the day
    final start = DateTime(day.year, day.month, day.day, 0, 0, 0);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);

    List<Note> fetched =
        await isar.notes
            .filter()
            .createdAtBetween(start, end)
            .sortByCreatedAtDesc()
            .findAll();

    return fetched;
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
    final existing = await isar.notes.get(id);
    if (existing == null) return;

    // Update monthly activity doc
    final year = existing.createdAt.year;
    final month = existing.createdAt.month;
    final day = existing.createdAt.day;

    final doc = await MonthlyActivityDoc.readFromDisk(year, month);
    doc.removeNoteForDay(day, existing.isReflection);
    await doc.saveToDisk();

    // Delete note from db
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}
