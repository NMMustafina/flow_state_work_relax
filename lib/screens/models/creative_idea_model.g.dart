// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creative_idea_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreativeIdeaModelAdapter extends TypeAdapter<CreativeIdeaModel> {
  @override
  final int typeId = 2;

  @override
  CreativeIdeaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreativeIdeaModel(
      id: fields[0] as String,
      text: fields[1] as String,
      timestamp: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CreativeIdeaModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreativeIdeaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
