import 'package:hive/hive.dart';

part 'taskoo_model.g.dart';

class TaskooModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  String time;

  @HiveField(5)
  String date;

  @HiveField(6)
  final bool isDone;

  TaskooModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.time,
    required this.date,
    this.isDone = false,
  });

  TaskooModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? time,
    String? date,
    bool? isDone,
  }) {
    return TaskooModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      time: time ?? this.time,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
    );
  }
}


