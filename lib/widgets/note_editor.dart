import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/utils.dart';

class NoteEditor extends StatefulWidget {
  final void Function(String newText) onSave;
  final Note? startingNote;
  final String title;

  const NoteEditor({
    super.key,
    required this.onSave,
    this.startingNote,
    required this.title,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _noteController =
      TextEditingController(); // Add a controller
  DateTime createdAt = DateTime.now();

  void _saveNote() {
    widget.onSave(_noteController.text);
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller with an empty string
    _noteController.text = widget.startingNote?.content ?? "";

    if (widget.startingNote != null) {
      createdAt = widget.startingNote!.createdAt;
    }
  }

  @override
  void dispose() {
    _noteController
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeCreated = DateFormat.jm(
      Intl.getCurrentLocale(),
    ).format(createdAt);
    final dayCreated = getRelativeDayDisplay(createdAt);
    final createdAtText = '$dayCreated - $timeCreated';

    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title), // Set the title of the AppBar
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: Text(
              "save",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12), // Add padding around the TextField
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(children: [Text(createdAtText)]),
            ),
            Expanded(
              child: TextField(
                controller: _noteController, // Assign the controller
                maxLines: null, // Allow unlimited lines
                expands: true, // Make the TextField fill the available space
                keyboardType: TextInputType.multiline, // Enable multiline input
                onSubmitted:
                    (value) => _saveNote(), // Save the note on submission
                decoration: const InputDecoration(
                  border: InputBorder.none, // Remove the bottom border
                  hintText: "New note...", // Optional: Add a placeholder
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
