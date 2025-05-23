import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moments_diary/constants/logging_related.dart';
import 'package:moments_diary/method_channels/schedule_recurring_ios_notif_mc.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification(
  int id,
  String content,
  DateTime toPublishAt,
  bool daily,
) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (toPublishAt.isBefore(DateTime.now())) {
    miscLogger.warning(
      'Attempted to schedule a notification in the past: $toPublishAt',
    );
    return;
  }

  if (daily) {
    await scheduleRecurringIOSNotifMC(
      "Moments Reminder",
      content,
      toPublishAt.hour,
      toPublishAt.minute,
      id,
    );
  } else {
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
}

Future<void> cancelNotification(int id) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.cancel(id);
  await cancelRecurringIOSNotifMC(id);
}
