import 'package:flutter/material.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/widgets/note_editor.dart';
import 'package:provider/provider.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  void saveNote(String newText, bool isReflection) {
    if (newText.isEmpty) {
      return;
    }

    // Save the note to the database
    final NoteDatabase noteDB = context.read<NoteDatabase>();
    noteDB.addNote(newText, isReflection);
  }

  void deleteNote() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return NoteEditor(onSave: saveNote, onDelete: deleteNote);
  }
}
