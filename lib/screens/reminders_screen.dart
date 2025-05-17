import 'package:flutter/material.dart';
import 'package:moments_diary/screens/new_reminder_screen.dart';
import 'package:moments_diary/widgets/reminder_list.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewReminderScreen(),
                ),
              );
              // Handle add reminder action
            },
          ),
        ],
      ),
      body: ReminderList(),
    );
  }
}
