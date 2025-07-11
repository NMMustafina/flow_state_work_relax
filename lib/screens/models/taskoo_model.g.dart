// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taskoo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskooModelAdapter extends TypeAdapter<TaskooModel> {
  @override
  final int typeId = 0;

  @override
  TaskooModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskooModel(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String?,
      time: fields[4] as String,
      date: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TaskooModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskooModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
