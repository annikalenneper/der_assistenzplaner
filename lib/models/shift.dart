import 'package:der_assistenzplaner/models/tag.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'shift.g.dart'; 

//----------------- Shift -----------------

@HiveType(typeId: 1)
  class Shift extends HiveObject {
    @HiveField(0)
    String _shiftID = Uuid().v4().toString();

    @HiveField(1)
    DateTime _start;

    @HiveField(2)
    DateTime _end;

    @HiveField(3)
    String? _assistantID;

    Shift(this._start, this._end, this._assistantID); 
      
    DateTime get start => _start;
    DateTime get end => _end;
    Duration get duration => _end.difference(_start);
    String get assistantID => _assistantID ?? '';
    bool get isScheduled => _assistantID != '';
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

  //----------------- Availability -----------------

  class Availability {
    final Shift shift;
    final String assistantID;

    const Availability(this.shift, this.assistantID);
  }

