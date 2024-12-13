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
      fields[0] as DateTime,
      fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Shift obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj._start)
      ..writeByte(1)
      ..write(obj._end);
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

class ScheduledShiftAdapter extends TypeAdapter<ScheduledShift> {
  @override
  final int typeId = 2;

  @override
  ScheduledShift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduledShift(
      fields[0] as DateTime, // start
      fields[1] as DateTime, // end
      fields[2] as String,   // assistantID
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledShift obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj._assistantID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledShiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

