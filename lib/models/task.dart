import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  int priority;
  @HiveField(4)
  bool isCompleted;
  @HiveField(5)
  DateTime date;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 1,
    this.isCompleted = false,
    required this.date,
  });
}
