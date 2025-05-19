import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/find_locale.dart';
import 'package:logging/logging.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/models/reminder_database.dart';
import 'package:moments_diary/screens/home_screen.dart';
import 'package:moments_diary/screens/reminders_screen.dart'; // Add this import
import 'package:moments_diary/theme/theme.dart';
import 'package:moments_diary/utils.dart';
import 'package:moments_diary/constants/prompts.dart' as prompt_constants;
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  runApp(const SplashScreen());

  await initializeStuff();

  runApp(const MainApp());
}

Future<void> initializeStuff() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  try {
    await Future.any([
      Future(() async {
        await NoteDatabase.initialize();
        await ReminderDatabase.initialize();
        await prefillReflectionPrompts();
        await findSystemLocale();
        initializeDateFormatting();

        tz.initializeTimeZones();
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));

        await initializeNotifications();
      }),
      Future.delayed(const Duration(seconds: 5), () {
        throw TimeoutException('Initialization timed out');
      }),
    ]);
  } catch (e) {
    debugPrint('Error during initialization: $e');
    rethrow;
  }
}

Future<void> initializeNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (pl) => print("TODO"),
  );
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
    return MaterialApp(
      home: Scaffold(
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
    MaterialTheme theme = MaterialTheme();

    return ChangeNotifierProvider(
      create: (context) => NoteDatabase(),
      child: ChangeNotifierProvider(
        create: (context) => ReminderDatabase(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
      ),
    );
  }
}
