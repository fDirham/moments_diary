import 'package:flutter/material.dart';
import 'package:moments_diary/screens/new_note_screen.dart';
import 'package:moments_diary/widgets/note_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void createNote() {
    // Function to create a new note
    // This is where you would implement the logic to create a new note
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewNoteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu action
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: createNote,
        child: const Icon(Icons.add),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Diary",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      "May 4",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,

                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(tabs: [Tab(text: "List"), Tab(text: "Calendar")]),
            Expanded(
              child: TabBarView(
                children: [NoteList(), Center(child: Text("Calendar Content"))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
