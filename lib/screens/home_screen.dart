import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/screens/new_note_screen.dart';
import 'package:moments_diary/screens/reflection_prompts_screen.dart';
import 'package:moments_diary/screens/settings_screen.dart'; // Import the settings screen
import 'package:moments_diary/widgets/home_header.dart';
import 'package:moments_diary/widgets/note_list.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add a GlobalKey

  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  void createNote() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewNoteScreen()));
  }

  @override
  void initState() {
    super.initState();
    readNotes();
  }

  @override
  Widget build(BuildContext context) {
    String currDayStr = DateFormat.MMMd(
      Intl.getCurrentLocale(),
    ).format(DateTime.now());

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Use the GlobalKey to open the drawer
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(title: const Text('Menu')),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('Reflection Prompts'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReflectionPromptsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
            HomeHeader(currDayStr: currDayStr),
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
