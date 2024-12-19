// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftAdapter extends TypeAdapter<Shift> {
  @override
  final int typeId = 1;

  @override
  Shift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shift(
      fields[1] as DateTime,
      fields[2] as DateTime,
      fields[3] as String?,
    ).._shiftID = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Shift obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj._shiftID)
      ..writeByte(1)
      ..write(obj._start)
      ..writeByte(2)
      ..write(obj._end)
      ..writeByte(3)
      ..write(obj._assistantID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
