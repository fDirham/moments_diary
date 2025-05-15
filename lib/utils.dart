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
