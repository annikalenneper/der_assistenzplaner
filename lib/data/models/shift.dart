import 'package:der_assistenzplaner/data/models/tag.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
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

    @override
    String toString() {
      final formattedStart = formatDateTime(start);
      final formattedEnd = formatDateTime(end);
      return '$formattedStart - $formattedEnd';
    }

    String get shiftID => _shiftID;  
    DateTime get start => _start;
    DateTime get end => _end;
    Duration get duration => _end.difference(_start);
    String? get assistantID => _assistantID;
    bool get isScheduled => _assistantID != '';
    List<Tag> get tags => [];

    String get formattedDuration {
      double hours = duration.inMinutes / 60.0;
      double quarterHour = (hours * 4).round() / 4.0;
      String hoursString = quarterHour.toStringAsFixed(2);
      hoursString = hoursString.replaceAll(RegExp(r'0+$'), '');
      hoursString = hoursString.replaceAll(RegExp(r'\.$'), '');
      return '$hoursString Stunden';
    }


    set start(DateTime start) => (start.isBefore(_end))
        ? _start = start
        : throw ArgumentError('Startzeitpunkt muss vor Endzeitpunkt liegen.');

    set end(DateTime end) => (end.isAfter(_start))
        ? _end = end
        : throw ArgumentError('Endzeitpunkt muss nach Startzeitpunkt liegen.');

  }

  //----------------- Availability -----------------

  class Availability {
    final Shift shift;
    final String assistantID;

    const Availability(this.shift, this.assistantID);
  }

