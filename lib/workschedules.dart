

import 'package:der_assistenzplaner/assistents.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Workschedule {
  final List<ScheduledShift> workschedule = List.empty();
  final DateTime start = DateTime.now();
  final DateTime end = DateTime.now();

  Workschedule(start, end);
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

/// dynamically displays workschedule based on selected workschedule
class WorkScheduleView extends StatefulWidget {
  final Workschedule workschedule;

  WorkScheduleView({required this.workschedule});

  @override
  WorkScheduleViewState createState() => WorkScheduleViewState();
}

class WorkScheduleViewState extends State<WorkScheduleView> {
  @override
  Widget build(BuildContext context) {
    final start = widget.workschedule.start;
    final end = widget.workschedule.end;
    final TableCalendar calendar = TableCalendar(firstDay: start, lastDay: end, focusedDay: DateTime.now());
    return calendar;
  }
}


