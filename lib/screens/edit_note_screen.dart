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
    void saveNote(String newText, bool isReflection) {
      final NoteDatabase noteDB = context.read<NoteDatabase>();

      if (newText.isEmpty) {
        noteDB.deleteNote(note.id);
        return;
      }

      noteDB.updateNote(note.id, newText);
    }

    void deleteNote() {
      final NoteDatabase noteDB = context.read<NoteDatabase>();
      noteDB.deleteNote(note.id);
    }

    return NoteEditor(
      onSave: saveNote,
      onDelete: deleteNote,
      startingNote: note,
    );
  }
}
