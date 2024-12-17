import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/test_data.dart';
import 'package:provider/provider.dart';


enum DisplayShifts {scheduled, upcoming, scheduledAndUpcoming, assistant}

/// used for displaying shifts in calendar generating work schedule and export functions
/// needs no database, uses lists from scheduledShiftModel
class WorkscheduleModel extends ChangeNotifier {
  Workschedule workschedule = createTestWorkSchedule();

  WorkscheduleModel();

  get start => workschedule.start;
  get end => workschedule.end;

  //test data, remove later
  List<ScheduledShift> get scheduledShifts => workschedule.scheduledShifts;

  /// returns list of scheduled shifts, depending on selected display option
  /// hand over function to calendar event loader to display selected shifts
  List<ScheduledShift> selectDisplayedShifts (context, DisplayShifts selected, {String? assistantID}) {
    late ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
    switch (selected) {
      case DisplayShifts.scheduled:
        return shiftModel.scheduledShifts;
      case DisplayShifts.upcoming:
        return shiftModel.upcomingShifts as List<ScheduledShift>;
      case DisplayShifts.scheduledAndUpcoming:
        return shiftModel.scheduledAndUpcomingShifts;
      case DisplayShifts.assistant:
        return shiftModel.shiftsByAssistantsMap[assistantID] ?? [];
    }
  }


}
