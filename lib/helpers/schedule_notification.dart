import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moments_diary/constants/logging_related.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification(
  int id,
  String content,
  DateTime toPublishAt,
) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (toPublishAt.isBefore(DateTime.now())) {
    miscLogger.warning(
      'Attempted to schedule a notification in the past: $toPublishAt',
    );
    return;
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Moments Reminder',
    content,
    tz.TZDateTime.from(toPublishAt, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> cancelNotification(int id) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.cancel(id);
}
