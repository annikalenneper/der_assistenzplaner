import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:flutter/material.dart';

class WorkscheduleModel extends ChangeNotifier {
  final Workschedule _workschedule;

  WorkscheduleModel(this._workschedule);

  get start => _workschedule.start;
  get end => _workschedule.end;
  get shifts => _workschedule.scheduledShifts;

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return _workschedule.getScheduledShiftsByDay(day);
  }

  void addShift(ScheduledShift shift) {
    _workschedule.addShift(shift);
    notifyListeners(); 
  }
}
