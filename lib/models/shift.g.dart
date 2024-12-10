// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftAdapter extends TypeAdapter<Shift> {
  @override
  final int typeId = 1; // Gleiche typeId für gemeinsame Box

  @override
  Shift read(BinaryReader reader) {
    final type = reader.readByte(); // Lese den Typcode
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Typunterscheidung
    if (type == 0) {
      return Shift(
        fields[0] as DateTime,
        fields[1] as DateTime,
      );
    } else if (type == 1) {
      return ScheduledShift(
        fields[0] as DateTime,
        fields[1] as DateTime,
        fields[2] as String,
      );
    } else {
      throw HiveError('Unknown type');
    }
  }

  @override
  void write(BinaryWriter writer, Shift obj) {
    if (obj is ScheduledShift) {
      writer.writeByte(1); // ScheduledShift Typ
      writer.writeByte(3); // Anzahl Felder
      writer.writeByte(0);
      writer.write(obj.start);
      writer.writeByte(1);
      writer.write(obj.end);
      writer.writeByte(2);
      writer.write(obj.assistantID);
    } else {
      writer.writeByte(0); // Shift Typ
      writer.writeByte(2); // Anzahl Felder
      writer.writeByte(0);
      writer.write(obj.start);
      writer.writeByte(1);
      writer.write(obj.end);
    }
  }
}
