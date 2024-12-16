import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/test_data.dart';


/// WorkscheduleModel holds list of scheduled shifts and notes
/// will also be used for generating work schedule and export functions
/// needs no database, uses scheduledShifts from scheduledShiftBox (hive database)
class WorkscheduleModel extends ChangeNotifier {
  Workschedule workschedule = createTestWorkSchedule();

  WorkscheduleModel();

  get start => workschedule.start;
  get end => workschedule.end;

  /// workschedule = list of scheduled shifts
  List<ScheduledShift> getWorkschedule(DateTime start, DateTime end, ShiftModel shiftModel) => 
    shiftModel.getScheduledShiftsByDayRange(start, end) as List<ScheduledShift>;
  

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return workschedule.getScheduledShiftsByDay(day);
  }

}
