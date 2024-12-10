import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/test_data.dart';

class WorkscheduleModel extends ChangeNotifier {
  Workschedule workschedule = createTestWorkSchedule();

  WorkscheduleModel();

  get start => workschedule.start;
  get end => workschedule.end;
  get shifts => workschedule.scheduledShifts;

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return workschedule.getScheduledShiftsByDay(day);
  }

  void addShift(ScheduledShift shift) {
    workschedule.addShift(shift);
    notifyListeners(); 
  }

  /// needs no database, scheduledShifts will be stored in database
}
