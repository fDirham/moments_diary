import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MonthlyActivityDoc {
  Map<int, DailyActivity> dailyActivities;
  int year;
  int month;
  DateTime get date => DateTime(year, month);

  MonthlyActivityDoc({
    this.dailyActivities = const {},
    required this.year,
    required this.month,
  });

  static Future<MonthlyActivityDoc> readFromDisk(int year, int month) async {
    final Directory userDir = await getApplicationDocumentsDirectory();
    final Directory monthlyDir = Directory(
      '${userDir.path}/monthly_activities',
    );
    final fileName = 'activity_$year-$month.json';
    final File file = File('${monthlyDir.path}/$fileName');

    Map<int, DailyActivity> newDailyActivities = {};
    if (await file.exists()) {
      final contents = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(contents);

      newDailyActivities = (json['dailyActivities'] as Map<String, dynamic>)
          .map(
            (dayStr, rawDA) =>
                MapEntry(int.parse(dayStr), DailyActivity.fromJson(rawDA)),
          );
    }

    return MonthlyActivityDoc(
      dailyActivities: newDailyActivities,
      year: year,
      month: month,
    );
  }

  Future<void> saveToDisk() async {
    final Directory userDir = await getApplicationDocumentsDirectory();
    final Directory monthlyDir = Directory(
      '${userDir.path}/monthly_activities',
    );
    if (!await monthlyDir.exists()) {
      await monthlyDir.create(recursive: true);
    }
    final fileName = 'activity_$year-$month.json';
    final File file = File('${monthlyDir.path}/$fileName');

    // convert dailyActivities to json
    final Map<String, dynamic> json = {
      'dailyActivities': dailyActivities.map(
        (day, dailyActivity) => MapEntry('$day', dailyActivity.toJson()),
      ),
    };

    // write to file
    await file.writeAsString(jsonEncode(json));
  }

  void addNoteForDay(int day, bool isReflection) {
    // Get daily activity for the day
    DailyActivity dailyActivity =
        dailyActivities[day] ?? DailyActivity(day: day);

    dailyActivity.numNotes++;
    if (isReflection) {
      dailyActivity.hasReflection = true;
    }

    dailyActivities[day] = dailyActivity;
  }

  void removeNoteForDay(int day, bool isReflection) {
    // Get daily activity for the day
    DailyActivity dailyActivity =
        dailyActivities[day] ?? DailyActivity(day: day);

    if (dailyActivity.numNotes > 0) {
      dailyActivity.numNotes--;
    }

    // Might cause a bug if we have multiple reflections
    if (isReflection) {
      dailyActivity.hasReflection = false;
    }

    dailyActivities[day] = dailyActivity;
  }

  DateTime getDailyActivityDate(DailyActivity dailyActivity) {
    return DateTime(year, month, dailyActivity.day);
  }
}

class DailyActivity {
  int numNotes;
  int day;
  bool hasReflection;

  DailyActivity({
    this.numNotes = 0,
    this.hasReflection = false,
    required this.day,
  });

  Map<String, dynamic> toJson() {
    return {'numNotes': numNotes, 'hasReflection': hasReflection, "day": day};
  }

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      numNotes: json['numNotes'] as int,
      hasReflection: json['hasReflection'] as bool,
      day: json['day'] as int,
    );
  }
}
