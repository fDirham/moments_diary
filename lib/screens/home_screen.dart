import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/screens/new_note_screen.dart';
import 'package:moments_diary/screens/reflection_prompts_screen.dart';
import 'package:moments_diary/screens/settings_screen.dart'; // Import the settings screen
import 'package:moments_diary/widgets/calendar_content.dart';
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
    final NoteDatabase noteDB = context.watch<NoteDatabase>();
    List<Note> currNotes = noteDB.currentNotes;

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
      drawer: MenuDrawer(),
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
            CustomTabBar(),
            Expanded(
              child: TabBarView(
                children: [NoteList(notes: currNotes), CalendarContent()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
    );
  }
}

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 4,
            bottom: 4,
          ),
          child: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            // tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 32),
            ),
            tabs: [
              SizedBox(width: 80, child: Align(child: Tab(text: "List"))),
              SizedBox(width: 80, child: Align(child: Tab(text: "Calendar"))),
            ],
          ),
        ),
      ),
    );
  }
}
