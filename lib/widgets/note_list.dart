import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/models/note_database.dart';
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
    for (final note in notes) {
      String groupLabel = DateFormat.MMMd(
        Intl.getCurrentLocale(),
      ).format(note.createdAt);

      DateTime dateWithoutTime = DateTime(
        note.createdAt.year,
        note.createdAt.month,
        note.createdAt.day,
      );

      int groupSort = dateWithoutTime.millisecondsSinceEpoch;

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
              (element) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        element["groupLabel"],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          order: GroupedListOrder.DESC,
          useStickyGroupSeparators: true,
          itemComparator: (a, b) {
            final aNote = a["note"];
            final bNote = b["note"];
            return aNote.createdAt.compareTo(bNote.createdAt);
          },
          itemBuilder: (context, element) {
            final currNote = element["note"];

            return NoteListRow(currNote: currNote);
          },
        );
  }
}
