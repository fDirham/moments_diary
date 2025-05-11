import 'package:flutter/material.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/widgets/note_editor.dart';
import 'package:provider/provider.dart';

class EditNoteScreen extends StatelessWidget {
  final Note note;

  const EditNoteScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    void saveNote(String newText) {
      final NoteDatabase noteDB = context.read<NoteDatabase>();
      noteDB.updateNote(note.id, newText);
      Navigator.of(context).pop(); // Close the screen after saving
    }

    return NoteEditor(title: "Edit", onSave: saveNote, startingNote: note);
  }
}
