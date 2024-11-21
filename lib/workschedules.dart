

import 'package:der_assistenzplaner/assistents.dart';
import 'package:flutter/material.dart';

class Workschedule {
  DateTimeRange? period;
  final List<ScheduledShift> workschedule = List.empty();

  void createWorkschedule(){
    //TO-DO: Implement this method
  }
}

class Shift {
  DateTime? start;
  DateTime? end;

  Shift({this.start, this.end});

}

class ScheduledShift extends Shift {
  var tagConflictPrio1 = false;
  var tagConflictPrio2 = false;
  var availabilityConflict1 = false;
  var availabilityConflict2 = false;

}

class Availability {
  final Shift shift;
  final Assistent assistent;

  const Availability(this.shift, this.assistent);
}

