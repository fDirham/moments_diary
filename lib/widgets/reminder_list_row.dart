import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:moments_diary/screens/edit_reminder_screen.dart';
import 'package:moments_diary/utils.dart';

class ReminderListRow extends StatefulWidget {
  final Reminder currReminder;

  const ReminderListRow({required this.currReminder, super.key});

  @override
  State<ReminderListRow> createState() => _ReminderListRowState();
}

class _ReminderListRowState extends State<ReminderListRow> {
  void editReminder(Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditReminderScreen(reminder: reminder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currReminder = widget.currReminder;

    final isInPast =
        !currReminder.recurring &&
        currReminder.toPublishAt.isBefore(DateTime.now());

    final String publishDay = getRelativeDayDisplay(currReminder.toPublishAt);
    final String publishTime = DateFormat.jm(
      Intl.getCurrentLocale(),
    ).format(currReminder.toPublishAt);
    final String timestampStr =
        currReminder.recurring ? publishTime : "$publishDay - $publishTime";

    return InkWell(
      onTap: () => editReminder(currReminder),
      child: Opacity(
        opacity: isInPast ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  currReminder.content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currReminder.recurring)
                      Icon(Icons.restore)
                    else
                      Container(),
                    Text(
                      timestampStr,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
