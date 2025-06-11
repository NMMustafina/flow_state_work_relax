import 'package:hive/hive.dart';

part 'creative_idea_model.g.dart';

@HiveType(typeId: 2)
class CreativeIdeaModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String timestamp;

  CreativeIdeaModel({
    required this.id,
    required this.text,
    required this.timestamp,
  });
}
