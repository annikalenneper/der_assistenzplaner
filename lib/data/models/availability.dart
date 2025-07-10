import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'availability.g.dart';

//----------------- Availability -----------------

@HiveType(typeId: 3) 
class Availability extends HiveObject {
  @HiveField(0)
  String _availabilityID = Uuid().v4().toString();

  @HiveField(1)
  String _shiftID;

  @HiveField(2)
  String _assistantID;

  static bool isValidAvailability(String shiftID, String assistantID) {
    return shiftID.isNotEmpty && assistantID.isNotEmpty;
  }

  Availability(this._shiftID, this._assistantID) {
    if (!isValidAvailability(_shiftID, _assistantID)) {
      throw ArgumentError('Invalid Availability: shiftID and assistantID must not be empty.');
    }
  }

  @override
  String toString() {
    return 'Availability(shiftID: $_shiftID, assistantID: $_assistantID)';
  }

  String get availabilityID => _availabilityID;
  String get shiftID => _shiftID;
  String get assistantID => _assistantID;

  set shiftID(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Shift ID cannot be empty.');
    }
    _shiftID = value;
  }

  set assistantID(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Assistant ID cannot be empty.');
    }
    _assistantID = value;
  }

  Availability copyWith({
    String? shiftID,
    String? assistantID,
  }) {
    return Availability(
      shiftID ?? _shiftID,
      assistantID ?? _assistantID,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Availability &&
          runtimeType == other.runtimeType &&
          _shiftID == other._shiftID &&
          _assistantID == other._assistantID;

  @override
  int get hashCode => _shiftID.hashCode ^ _assistantID.hashCode;
}