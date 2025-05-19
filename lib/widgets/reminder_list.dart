import 'package:flutter/material.dart';
import 'package:moments_diary/widgets/reminder_list_row.dart';
import 'package:provider/provider.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:moments_diary/models/reminder_database.dart';

class ReminderList extends StatelessWidget {
  const ReminderList({super.key});

  @override
  Widget build(BuildContext context) {
    final ReminderDatabase reminderDB = context.watch<ReminderDatabase>();
    final List<Reminder> reminders = reminderDB.currentReminders;

    if (reminders.isEmpty) {
      return Center(
        child: Text(
          "No reminders available.\nAdd a new one to get started!",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ReminderListRow(currReminder: reminder);
      },
    );
  }
}
