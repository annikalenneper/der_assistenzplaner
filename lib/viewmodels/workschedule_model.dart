import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:flutter/material.dart';

class WorkscheduleModel extends ChangeNotifier {
  final Workschedule _workschedule;

  WorkscheduleModel(this._workschedule);

  DateTime getStart() {
    return _workschedule.start;
  }

  DateTime getEnd() {
    return _workschedule.end;
  }

  void addShift(ScheduledShift shift) {
    _workschedule.addShift(shift);
    notifyListeners(); 
  }

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return _workschedule.getScheduledShiftsByDay(day);
  }
}
