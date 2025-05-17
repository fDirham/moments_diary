import 'package:flutter/material.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:moments_diary/models/reminder_database.dart';
import 'package:moments_diary/widgets/reminder_editor.dart';
import 'package:provider/provider.dart';

class EditReminderScreen extends StatelessWidget {
  final Reminder reminder;
  const EditReminderScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    void onSave(String newText, DateTime toPublishAt) {
      final ReminderDatabase reminderDB = context.read<ReminderDatabase>();
      if (newText.isEmpty) {
        reminderDB.deleteReminder(reminder.id);
        return;
      }

      // Save the note to the database
      reminderDB.updateReminder(reminder.id, newText, toPublishAt);
    }

    void onDelete() {
      final ReminderDatabase reminderDB = context.read<ReminderDatabase>();
      reminderDB.deleteReminder(reminder.id);
    }

    return ReminderEditor(
      onSave: onSave,
      onDelete: onDelete,
      startingReminder: reminder,
    );
  }
}
