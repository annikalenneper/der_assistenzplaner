import 'package:der_assistenzplaner/models/assistant.dart';

//----------------- Shift -----------------

class Shift {
  DateTime start;
  DateTime end;

  Shift(this.start, this.end);
  
  Duration get duration => end.difference(start);
}




//----------------- ScheduledShift -----------------

class ScheduledShift extends Shift {
  final Assistant assistant;

  /// TO-DO: implement getter/setter-methods for conflicts
  var tagConflictPrio1 = false;
  var tagConflictPrio2 = false;
  var availabilityConflict1 = false;
  var availabilityConflict2 = false;

  ScheduledShift(super.start, super.end, this.assistant);
}

class Availability {
  final Shift shift;
  final Assistant assistant;

  const Availability(this.shift, this.assistant);
}

