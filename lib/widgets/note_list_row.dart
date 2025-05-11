import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/screens/edit_note_screen.dart';

class NoteListRow extends StatefulWidget {
  final Note currNote;

  const NoteListRow({required this.currNote, super.key});

  @override
  State<NoteListRow> createState() => _NoteListRowState();
}

class _NoteListRowState extends State<NoteListRow> {
  void editNote(Note note) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)));
  }

  @override
  Widget build(BuildContext context) {
    final currNote = widget.currNote;

    String timestampStr = DateFormat.jm(
      Intl.getCurrentLocale(),
    ).format(currNote.createdAt);

    return InkWell(
      onTap: () => editNote(currNote),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                currNote.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timestampStr,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
