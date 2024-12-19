import 'package:der_assistenzplaner/models/tag.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'shift.g.dart'; 

//----------------- Shift -----------------

@HiveType(typeId: 1)
  class Shift extends HiveObject {
    @HiveField(0)
    String _shiftID;

    @HiveField(1)
    DateTime _start;

    @HiveField(2)
    DateTime _end;

    Shift(this._start, this._end) 
      : _shiftID = Uuid().v4().toString();

    DateTime get start => _start;
    DateTime get end => _end;
    Duration get duration => _end.difference(_start);
    List<Tag> get tags => [];

    set start(DateTime start) => (start.isBefore(_end))
        ? _start = start
        /// don't allow start time after end time in UI (should be handled by controller)
        : throw ArgumentError('Startzeitpunkt muss vor Endzeitpunkt liegen.');

    set end(DateTime end) => (end.isAfter(_start))
        ? _end = end
        /// don't allow end time before start time in UI (should be handled by controller)
        : throw ArgumentError('Endzeitpunkt muss nach Startzeitpunkt liegen.');

  }

  //----------------- ScheduledShift -----------------

@HiveType(typeId: 2)
  class ScheduledShift extends Shift {
    @HiveField(3)
    String _assistantID;

    ScheduledShift(super.start, super.end, this._assistantID);

    String get assistantID => _assistantID;

    set assistantID(String assistantID) => _assistantID = assistantID;

    /// override == operator to compare ScheduledShifts by start, end and assistant
    @override
    bool operator == (Object other) {
      if (identical(this, other)) return true;
      if (other is! ScheduledShift) return false;
      return _start == other._start &&
          _end == other._end &&
          _assistantID == other._assistantID;
    }

    @override
    int get hashCode => Object.hash(_start, _end, _assistantID);
  }


  //----------------- Availability -----------------

  class Availability {
    final Shift shift;
    final String assistantID;

    const Availability(this.shift, this.assistantID);
  }

