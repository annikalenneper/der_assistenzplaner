import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


enum ShiftDisplayOptions {scheduled, unscheduled, all, assistant}

/// used for displaying shifts in calendar generating work schedule and export functions
/// needs no database, uses lists from scheduledShiftModel
class WorkscheduleModel extends ChangeNotifier {
  var _selectedDisplayOption = ShiftDisplayOptions.scheduled;
  String? selectedAssistantID;

  void updateDisplayOption(ShiftDisplayOptions option, String? assistantID) {
    _selectedDisplayOption = option;
    selectedAssistantID = assistantID;
    notifyListeners();
  }

  ShiftDisplayOptions get selectedDisplayOption => _selectedDisplayOption;

  /// returns list of scheduled shifts, depending on selected display option
  /// hand over function to calendar event loader to display selected shifts
  List<Shift> selectDisplayedShifts (context, ShiftDisplayOptions selected) {
    late ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
    switch (selected) {
      case ShiftDisplayOptions.scheduled:
        return shiftModel.scheduledShifts;
      case ShiftDisplayOptions.unscheduled:
        return shiftModel.unscheduledShifts;
      case ShiftDisplayOptions.all:
        return shiftModel.shifts;
      case ShiftDisplayOptions.assistant:
        return shiftModel.getMapOfShiftsByAssistants()[selectedAssistantID] ?? [];
    }
  }
}
