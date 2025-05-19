import 'package:flutter/services.dart';

Future<void> scheduleRecurringIOSNotifMC(
  String title,
  String body,
  int hour,
  int minute,
  int id,
) async {
  const platform = MethodChannel('com.fbdco.moments.diary.mc/recurring_notif');

  Map data = {
    "title": title,
    "body": body,
    "hour": hour,
    "minute": minute,
    "id": id,
  };

  try {
    // here also you can name your method anything you like
    await platform.invokeMethod('schedule', data);
  } on PlatformException catch (e) {
    throw "Failed to get battery level: '${e.message}'.";
  }
}

Future<void> cancelRecurringIOSNotifMC(int id) async {
  const platform = MethodChannel('com.fbdco.moments.diary.mc/recurring_notif');

  Map data = {"id": id};

  try {
    // here also you can name your method anything you like
    await platform.invokeMethod('cancel', data);
  } on PlatformException catch (e) {
    throw "Failed to get battery level: '${e.message}'.";
  }
}
