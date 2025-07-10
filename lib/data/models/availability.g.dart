// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvailabilityAdapter extends TypeAdapter<Availability> {
  @override
  final int typeId = 3;

  @override
  Availability read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Availability(
      fields[1] as String,
      fields[2] as String,
    ).._availabilityID = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Availability obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj._availabilityID)
      ..writeByte(1)
      ..write(obj._shiftID)
      ..writeByte(2)
      ..write(obj._assistantID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
