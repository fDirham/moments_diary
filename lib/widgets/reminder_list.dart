import 'package:flutter/material.dart';
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
      Padding(
        padding: EdgeInsets.only(top: 32),
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

    return ListView.separated(
      itemCount: reminders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ListTile(
          title: Text(reminder.content),
          subtitle: Text(reminder.toPublishAt.toString()),
          trailing: Text(
            // Format the date as you like
            reminder.toPublishAt.toLocal().toString().split(
              ' ',
            )[0], // Example: "2023-10-01"
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }
}
