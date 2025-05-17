import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/utils.dart';

class NoteEditor extends StatefulWidget {
  final void Function(String newText) onSave;
  final void Function() onDelete;
  final Note? startingNote;

  const NoteEditor({
    super.key,
    required this.onSave,
    required this.onDelete,
    this.startingNote,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _noteController =
      TextEditingController(); // Add a controller
  DateTime topDate = DateTime.now();

  void _saveNote() {
    widget.onSave(_noteController.text); // Call the onSave function
  }

  void _deleteNote() {
    widget.onDelete(); // Call the onDelete function
  }

  Future<void> _handleReflect() async {
    final prompts = "${(await getReflectionPrompts()).join("\n\n\n")}\n";
    _noteController.text = prompts;

    final firstNewline = prompts.indexOf('\n');
    if (firstNewline != -1) {
      _noteController.selection = TextSelection.collapsed(
        offset: firstNewline + 1,
      );
    } else {
      _noteController.selection = TextSelection.collapsed(
        offset: prompts.length,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller with an empty string
    _noteController.text = widget.startingNote?.content ?? "";

    if (widget.startingNote != null) {
      topDate = widget.startingNote!.createdAt;
    }

    _noteController.addListener(() {
      // Listen for changes in the text field
      setState(() {}); // Update the state when the text changes
    });
  }

  @override
  void dispose() {
    _noteController
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeCreated = DateFormat.jm(Intl.getCurrentLocale()).format(topDate);
    final dayCreated = getRelativeDayDisplay(topDate);
    final topDateText = '$dayCreated - $timeCreated';
    final showReflectionsButton =
        widget.startingNote == null && _noteController.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title), // Set the title of the AppBar
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, {
                "delete": true,
              }); // Close the screen after deletion
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: PopScope(
        onPopInvokedWithResult: (bool result, dynamic data) {
          if (result == true) {
            if (data != null && data['delete'] == true) {
              _deleteNote(); // Delete the note when the user pops the screen
            } else {
              _saveNote(); // Save the note when the user pops the screen
            }
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(
                12,
              ), // Add padding around the TextField
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          topDateText,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(80),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _noteController, // Assign the controller
                      maxLines: null, // Allow unlimited lines
                      expands:
                          true, // Make the TextField fill the available space
                      keyboardType:
                          TextInputType.multiline, // Enable multiline input
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
            if (showReflectionsButton)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _handleReflect();
                  },
                  child: const Text("Reflect"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
