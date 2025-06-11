import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 1)
class ActivityModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String moodTag;

  @HiveField(3)
  final String time;

  @HiveField(4)
  final String date;

  @HiveField(5)
  final String? textThoughts;

  @HiveField(6)
  final List<String> audioPaths;

  @HiveField(7)
  final String category;

  ActivityModel({
    required this.id,
    required this.name,
    required this.moodTag,
    required this.time,
    required this.date,
    this.textThoughts,
    this.audioPaths = const [],
    required this.category,
  });

  bool get hasVoice => audioPaths.isNotEmpty;
  bool get hasText => (textThoughts?.trim().isNotEmpty ?? false);
}
