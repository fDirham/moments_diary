import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/widgets/note_list_group_header.dart';
import 'package:moments_diary/widgets/note_list_row.dart';
import 'package:provider/provider.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Map<String, dynamic>> putNotesIntoGroups(List<Note> notes) {
    List<Map<String, dynamic>> groupedNotes = [];
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    for (final note in notes) {
      final DateTime dateWithoutTime = DateTime(
        note.createdAt.year,
        note.createdAt.month,
        note.createdAt.day,
      );

      String groupLabel;
      if (dateWithoutTime == today) {
        groupLabel = "Today";
      } else if (dateWithoutTime == yesterday) {
        groupLabel = "Yesterday";
      } else {
        groupLabel = DateFormat.MMMd(
          Intl.getCurrentLocale(),
        ).format(note.createdAt);
      }

      final int groupSort = dateWithoutTime.millisecondsSinceEpoch;

      groupedNotes.add({
        "groupLabel": groupLabel,
        "groupSort": groupSort,
        "note": note,
      });
    }

    return groupedNotes;
  }

  @override
  Widget build(BuildContext context) {
    final NoteDatabase noteDB = context.watch<NoteDatabase>();
    List<Note> currNotes = noteDB.currentNotes;
    putNotesIntoGroups(currNotes);
    final groupedNotes = putNotesIntoGroups(currNotes);

    return currNotes.isEmpty
        ? const Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            "No notes available.\nAdd a new note to get started!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        )
        : GroupedListView<Map<String, dynamic>, int>(
          elements: groupedNotes,
          groupBy: (element) => element["groupSort"],
          groupHeaderBuilder:
              (element) =>
                  NoteListGroupHeader(groupLabel: element["groupLabel"]),
          order: GroupedListOrder.DESC,
          useStickyGroupSeparators: true,
          itemComparator: (a, b) {
            final aNote = a["note"];
            final bNote = b["note"];
            return aNote.createdAt.compareTo(bNote.createdAt);
          },
          separator: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, element) {
            final currNote = element["note"];

            return NoteListRow(currNote: currNote);
          },
        );
  }
}
