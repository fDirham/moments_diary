import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/utils.dart';
import 'package:moments_diary/widgets/note_list_group_header.dart';
import 'package:moments_diary/widgets/note_list_row.dart';

class NoteList extends StatefulWidget {
  final List<Note> notes;

  const NoteList({super.key, required this.notes});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Map<String, dynamic>> putNotesIntoGroups(List<Note> notes) {
    List<Map<String, dynamic>> groupedNotes = [];

    for (final note in notes) {
      String groupLabel = getRelativeDayDisplay(note.createdAt);

      final DateTime dateWithoutTime = DateTime(
        note.createdAt.year,
        note.createdAt.month,
        note.createdAt.day,
      );

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
    putNotesIntoGroups(widget.notes);
    final groupedNotes = putNotesIntoGroups(widget.notes);

    return widget.notes.isEmpty
        ? Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            "No notes available.\nAdd a new note to get started!",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
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
          shrinkWrap: true,
          itemBuilder: (context, element) {
            final currNote = element["note"];

            return NoteListRow(currNote: currNote);
          },
        );
  }
}
