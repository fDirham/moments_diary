import 'package:intl/intl.dart';

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
