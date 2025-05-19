import 'package:isar/isar.dart';
part "reminder.g.dart";

@collection
class Reminder {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  late String content;
  late DateTime toPublishAt;
  DateTime createdAt = DateTime.now();
  late bool recurring;

  @override
  String toString() {
    return "($id) $content, $toPublishAt";
  }
}
