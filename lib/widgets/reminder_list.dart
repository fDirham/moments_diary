import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:moments_diary/widgets/reminder_list_row.dart';
import 'package:provider/provider.dart';
import 'package:moments_diary/models/reminder.dart';
import 'package:moments_diary/models/reminder_database.dart';
import 'package:moments_diary/widgets/note_list_group_header.dart';

class ReminderList extends StatelessWidget {
  const ReminderList({super.key});

  List<Map<String, dynamic>> putRemindersIntoGroups(List<Reminder> reminders) {
    List<Map<String, dynamic>> grouped = [];

    for (final reminder in reminders) {
      String groupLabel = reminder.recurring ? "Recurring" : "One-time";

      grouped.add({"groupLabel": groupLabel, "reminder": reminder});
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final ReminderDatabase reminderDB = context.watch<ReminderDatabase>();
    final List<Reminder> reminders = reminderDB.currentReminders;
    final grouped = putRemindersIntoGroups(reminders);

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

    return GroupedListView(
      elements: grouped,
      groupBy: (element) => element['groupLabel'],
      groupHeaderBuilder:
          (element) => NoteListGroupHeader(groupLabel: element["groupLabel"]),

      order: GroupedListOrder.DESC,
      useStickyGroupSeparators: true,
      itemComparator: (a, b) {
        final aRem = a["reminder"] as Reminder;
        final bRem = b["reminder"] as Reminder;
        return aRem.toPublishAt.compareTo(bRem.toPublishAt);
      },
      shrinkWrap: true,
      itemBuilder: (context, element) {
        final reminder = element["reminder"] as Reminder;
        return ReminderListRow(currReminder: reminder);
      },
    );
  }
}
