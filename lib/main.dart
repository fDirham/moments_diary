import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/find_locale.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/screens/home_screen.dart';
import 'package:moments_diary/screens/reminders_screen.dart'; // Add this import
import 'package:moments_diary/theme/theme.dart';
import 'package:moments_diary/theme/util.dart';
import 'package:moments_diary/utils.dart';
import 'package:moments_diary/constants/prompts.dart' as prompt_constants;
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(const SplashScreen());

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Future.any([
      Future(() async {
        await NoteDatabase.initialize();
        await prefillReflectionPrompts();
        await findSystemLocale();
        await Future.delayed(
          const Duration(seconds: 5),
        ); // Add a 5-second delay
      }),
      Future.delayed(const Duration(seconds: 30), () {
        throw TimeoutException('Initialization timed out');
      }),
    ]);
  } catch (e) {
    debugPrint('Error during initialization: $e');
    rethrow;
  }

  runApp(const MainApp());
}

Future<void> prefillReflectionPrompts() async {
  final prompts = await getReflectionPrompts();
  if (prompts.isEmpty) {
    await saveReflectionPrompts(prompt_constants.defaultPrompts);
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading Moments Diary...'),
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentPageIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    RemindersScreen(), // Add your RemindersScreen here
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Inter", "Inter");
    MaterialTheme theme = MaterialTheme(textTheme);

    return ChangeNotifierProvider(
      create: (context) => NoteDatabase(),
      child: MaterialApp(
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: screens[currentPageIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentPageIndex,
            onTap: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm),
                label: 'Reminders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
