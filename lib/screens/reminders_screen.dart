import 'package:flutter/material.dart';
import 'package:moments_diary/models/reminder_database.dart';
import 'package:moments_diary/screens/new_reminder_screen.dart';
import 'package:moments_diary/widgets/reminder_list.dart';
import 'package:provider/provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReminderDatabase>().fetchReminders();
  }

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
