import 'package:flutter/material.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:provider/provider.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  void updateNote(Note note) {
    print("TODO: Update");
  }

  void deleteNote(int id) {
    print("TODO: Delete");
  }

  @override
  Widget build(BuildContext context) {
    final NoteDatabase noteDB = context.read<NoteDatabase>();
    List<Note> currNotes = noteDB.currentNotes;

    return ListView.builder(
      itemCount: currNotes.length,
      itemBuilder: (context, index) {
        final currNote = currNotes[index];
        return ListTile(
          title: Text(currNote.content),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => deleteNote(currNote.id),
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () => updateNote(currNote),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        );
      },
    );
  }
}
