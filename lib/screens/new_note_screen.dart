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
  void saveNote(String newText) {
    // Save the note to the database
    final NoteDatabase noteDB = context.read<NoteDatabase>();
    noteDB.addNote(newText);
    Navigator.of(context).pop(); // Close the screen after saving
  }

  @override
  Widget build(BuildContext context) {
    return NoteEditor(title: "New", onSave: saveNote);
  }
}
