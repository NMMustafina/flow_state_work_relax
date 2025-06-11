// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 1;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      id: fields[0] as String,
      name: fields[1] as String,
      moodTag: fields[2] as String,
      time: fields[3] as String,
      date: fields[4] as String,
      textThoughts: fields[5] as String?,
      audioPaths: (fields[6] as List).cast<String>(),
      category: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.moodTag)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.textThoughts)
      ..writeByte(6)
      ..write(obj.audioPaths)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
