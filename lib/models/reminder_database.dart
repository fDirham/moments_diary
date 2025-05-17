import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:moments_diary/helpers/schedule_notification.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:path_provider/path_provider.dart';

class ReminderDatabase extends ChangeNotifier {
  static late Isar isar;
  static final Logger logger = Logger('ReminderDatabase');

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
    final newId = await isar.writeTxn(
      () async => await isar.reminders.put(newReminder),
    );

    // reread to update changes
    await fetchReminders();

    // Schedule notification
    await scheduleNotification(newId, content, toPublishAt);
  }

  // Get notes
  Future<void> fetchReminders() async {
    List<Reminder> fetched =
        await isar.reminders.where().sortByToPublishAtDesc().findAll();

    currentReminders.clear();
    currentReminders.addAll(fetched);

    logger.info("Fetched ${currentReminders.toString()} reminders");
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

      await cancelNotification(id);
      await scheduleNotification(id, newContent, newToPublishAt);
    }
  }

  // Delete note
  Future<void> deleteReminder(int id) async {
    await isar.writeTxn(() => isar.reminders.delete(id));
    await fetchReminders();
    await cancelNotification(id);
  }
}
