import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getRelativeDayDisplay(DateTime time) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  final DateTime dateWithoutTime = DateTime(time.year, time.month, time.day);

  String groupLabel;
  if (dateWithoutTime == today) {
    groupLabel = "Today";
  } else if (dateWithoutTime == yesterday) {
    groupLabel = "Yesterday";
  } else {
    groupLabel = DateFormat.MMMd(Intl.getCurrentLocale()).format(time);
  }

  return groupLabel;
}

Future<void> saveReflectionPrompts(List<String> prompts) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String jsonString = jsonEncode(prompts);
  await prefs.setString('reflection_prompts', jsonString);
}

Future<List<String>> getReflectionPrompts() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? jsonString = prefs.getString('reflection_prompts');
  if (jsonString != null) {
    return List<String>.from(jsonDecode(jsonString));
  }
  return [];
}

Future<void> setCalendarStartDate(DateTime date) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('calendar_start_date', date.toIso8601String());
}

Future<DateTime?> getCalendarStartDate() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? dateString = prefs.getString('calendar_start_date');
  if (dateString != null) {
    return DateTime.parse(dateString);
  }
  return null;
}

Future<void> setCalendarEndDate(DateTime date) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('calendar_end_date', date.toIso8601String());
}

Future<DateTime?> getCalendarEndDate() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? dateString = prefs.getString('calendar_end_date');
  if (dateString != null) {
    return DateTime.parse(dateString);
  }
  return null;
}
