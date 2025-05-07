import 'package:flutter/material.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:provider/provider.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _noteController =
      TextEditingController(); // Add a controller

  late final NoteDatabase noteDB = context.read<NoteDatabase>();

  void _saveNote() {
    // Save the note to the database
    noteDB.addNote(_noteController.text);
    Navigator.of(context).pop(); // Close the screen after saving
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller with an empty string
    _noteController.text = "";
  }

  @override
  void dispose() {
    _noteController
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote, // Save the note when the button is pressed
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12), // Add padding around the TextField
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _noteController, // Assign the controller
                maxLines: null, // Allow unlimited lines
                expands: true, // Make the TextField fill the available space
                keyboardType: TextInputType.multiline, // Enable multiline input
                onSubmitted:
                    (value) => _saveNote(), // Save the note on submission
              ),
            ),
          ],
        ),
      ),
    );
  }
}
