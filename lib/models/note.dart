import 'package:isar/isar.dart';
part "note.g.dart";

@collection
class Note {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  late String content;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  late bool isReflection;
}
