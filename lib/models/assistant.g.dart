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
      fields[0] as String,
      fields[1] as double,
    ).._actualHours = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, Assistant obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._contractedHours)
      ..writeByte(2)
      ..write(obj._actualHours)
      ..writeByte(3)
      ..write(obj._surchargeCounter)
      ..writeByte(4)
      ..write(obj._futureSurchargeCounter)
      ..writeByte(5)
      ..write(obj._notes)
      ..writeByte(6)
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
