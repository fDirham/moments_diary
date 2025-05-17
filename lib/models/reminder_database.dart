import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:path_provider/path_provider.dart';

class ReminderDatabase extends ChangeNotifier {
  static late Isar isar;

  // Initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(name: "reminder db", [
      ReminderSchema,
    ], directory: dir.path);
  }

  // list of notes
  final List<Reminder> currentReminders = [];

  // add note
  Future<void> addReminder(String content, DateTime toPublishAt) async {
    var newReminder = Reminder();
    newReminder.content = content;
    newReminder.toPublishAt = toPublishAt;
    newReminder.createdAt = DateTime.now();

    // save in db
    await isar.writeTxn(() => isar.reminders.put(newReminder));

    // reread to update changes
    await fetchReminders();
  }

  // Get notes
  Future<void> fetchReminders() async {
    List<Reminder> fetched =
        await isar.reminders.where().sortByToPublishAt().findAll();

    currentReminders.clear();
    currentReminders.addAll(fetched);
    notifyListeners();
  }

  // Update note
  Future<void> updateReminder(
    int id,
    String newContent,
    DateTime newToPublishAt,
  ) async {
    final existing = await isar.reminders.get(id);

    if (existing != null) {
      existing.content = newContent;
      existing.toPublishAt = newToPublishAt;

      await isar.writeTxn(() => isar.reminders.put(existing));
      await fetchReminders();
    }
  }

  // Delete note
  Future<void> deleteReminder(int id) async {
    await isar.writeTxn(() => isar.reminders.delete(id));
    await fetchReminders();
  }
}
