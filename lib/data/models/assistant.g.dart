// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssistantAdapter extends TypeAdapter<Assistant> {
  @override
  final int typeId = 0;

  @override
  Assistant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Assistant(
      fields[1] as String,
      fields[2] as double,
    )
      .._assistantID = fields[0] as String
      .._actualHours = fields[3] as double
      .._tags = (fields[7] as List).cast<Tag>();
  }

  @override
  void write(BinaryWriter writer, Assistant obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj._assistantID)
      ..writeByte(1)
      ..write(obj._name)
      ..writeByte(2)
      ..write(obj._contractedHours)
      ..writeByte(3)
      ..write(obj._actualHours)
      ..writeByte(4)
      ..write(obj._surchargeCounter)
      ..writeByte(5)
      ..write(obj._futureSurchargeCounter)
      ..writeByte(6)
      ..write(obj._notes)
      ..writeByte(7)
      ..write(obj._tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
