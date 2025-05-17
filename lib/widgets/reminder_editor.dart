import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:moments_diary/utils.dart';

class ReminderEditor extends StatefulWidget {
  final void Function(String newText, DateTime toPublishAt) onSave;
  final void Function() onDelete;
  final Reminder? startingReminder;

  const ReminderEditor({
    super.key,
    required this.onSave,
    required this.onDelete,
    this.startingReminder,
  });

  @override
  State<ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends State<ReminderEditor> {
  final TextEditingController _contentController =
      TextEditingController(); // Add a controller
  DateTime workingToPublishAt = DateTime.now();

  void _saveReminder() {
    widget.onSave(
      _contentController.text,
      workingToPublishAt,
    ); // Call the onSave function
  }

  void _deleteReminder() {
    widget.onDelete(); // Call the onDelete function
  }

  void _changeDate() async {
    final userRes = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: workingToPublishAt,
    );

    if (userRes != null) {
      setState(() {
        workingToPublishAt = DateTime(
          userRes.year,
          userRes.month,
          userRes.day,
          workingToPublishAt.hour,
          workingToPublishAt.minute,
        );
      });
    }
  }

  void _changeTime() async {
    final userRes = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(workingToPublishAt),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (userRes != null) {
      final newDateTime = DateTime(
        workingToPublishAt.year,
        workingToPublishAt.month,
        workingToPublishAt.day,
        userRes.hour,
        userRes.minute,
      );

      // final isBefore = false;
      final isBefore = newDateTime.isBefore(
        DateTime.now().add(const Duration(minutes: 5)),
      );

      if (isBefore) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot set a time this early.')),
        );
        return;
      }
      setState(() {
        workingToPublishAt = newDateTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller with an empty string
    _contentController.text = widget.startingReminder?.content ?? "";

    if (widget.startingReminder != null) {
      workingToPublishAt = widget.startingReminder!.toPublishAt;
    } else {
      workingToPublishAt = DateTime.now().add(const Duration(minutes: 20));
    }

    _contentController.addListener(() {
      // Listen for changes in the text field
      setState(() {}); // Update the state when the text changes
    });
  }

  @override
  void dispose() {
    _contentController
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String timeCreated = DateFormat.jm(
      Intl.getCurrentLocale(),
    ).format(workingToPublishAt);
    final String dayCreated = getRelativeDayDisplay(workingToPublishAt);

    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title), // Set the title of the AppBar
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, {
                "delete": true,
              }); // Close the screen after deletion
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: PopScope(
        onPopInvokedWithResult: (bool result, dynamic data) {
          if (result == true) {
            if (data != null && data['delete'] == true) {
              _deleteReminder(); // Delete the note when the user pops the screen
            } else {
              _saveReminder(); // Save the note when the user pops the screen
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12), // Add padding around the TextField
          child: Column(
            children: [
              WorkingDateInput(
                dayText: dayCreated,
                timeText: timeCreated,
                onDayTap: _changeDate,
                onTimeTap: _changeTime,
              ),
              Expanded(
                child: TextField(
                  controller: _contentController, // Assign the controller
                  maxLines: null, // Allow unlimited lines
                  expands: true, // Make the TextField fill the available space
                  keyboardType:
                      TextInputType.multiline, // Enable multiline input
                  onSubmitted:
                      (value) => _saveReminder(), // Save the note on submission
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Remove the bottom border
                    hintText:
                        "E.g go shopping...", // Optional: Add a placeholder
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkingDateInput extends StatelessWidget {
  final String dayText;
  final String timeText;
  final void Function() onDayTap;
  final void Function() onTimeTap;

  const WorkingDateInput({
    super.key,
    required this.dayText,
    required this.timeText,
    required this.onDayTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: onDayTap,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Text(
                  dayText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onTimeTap,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Text(
                  timeText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
