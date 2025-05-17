import 'package:flutter/material.dart';
import 'package:moments_diary/models/reminder_database.dart';
import 'package:moments_diary/widgets/reminder_editor.dart';
import 'package:provider/provider.dart';

class NewReminderScreen extends StatelessWidget {
  const NewReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void onSave(String newText, DateTime toPublishAt) {
      if (newText.isEmpty) {
        return;
      }

      // Save the note to the database
      final ReminderDatabase reminderDB = context.read<ReminderDatabase>();
      reminderDB.addReminder(newText, toPublishAt);
    }

    void onDelete() {
      return;
    }

    return ReminderEditor(onSave: onSave, onDelete: onDelete);
  }
}
