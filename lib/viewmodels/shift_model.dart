
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/shift_repository.dart';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';


/// handels shifts and scheduled shifts, saves them to database
/// used by WorkScheduleModel to generate work schedule and display shifts in calendar
class ShiftModel extends ChangeNotifier {
  ShiftRepository shiftRepository = ShiftRepository();
  List<Shift> shifts = [];
  Map<DateTime, List<Shift>> mapOfShiftsByDay = {}; 
  Map<String, List<Shift>> mapOfShiftsByAssistant = {}; 
  final MarkerCache markerCache = MarkerCache();

  Shift? currentShift;

  ShiftModel();

  //----------------- Getter methods -----------------

  DateTime get start => currentShift?.start ?? DateTime.now();
  DateTime get end => currentShift?.end ?? DateTime.now();
  Duration get duration => currentShift?.duration ?? Duration.zero;

  /// removing unscheduledShifts is more efficient, because only few unscheduledShifts will be saved in database
  List<Shift> get scheduledShifts =>
      shifts.toList()..removeWhere((shift) => !shift.isScheduled);

  List<Shift> get unscheduledShifts => 
      shifts.where((shift) => !shift.isScheduled).toList();


  //----------------- Setter methods -----------------

  //TO-DO: implement setter methods with checks for valid input


  //------------------ Filter Methods ------------------

  List<Shift> getShiftsByDay(DateTime day) {
    return shifts.where((shift) =>
            shift.start.year == day.year &&
            shift.start.month == day.month &&
            shift.start.day == day.day)
        .toList();
  }

  List<Shift> getShiftsByDateRange(DateTime start, DateTime end) {
    return shifts.where((shift) =>
            (shift.start.isAfter(start) || shift.start.isAtSameMomentAs(start)) &&
            (shift.end.isBefore(end) || shift.end.isAtSameMomentAs(end)))
        .toList();
  }
  

  //----------------- Data Manipulation Methods -----------------
  
  /// save new shift or update existing in shiftbox through shiftRepository
  Future<void> saveShift(Shift newShift) async {
    await shiftRepository.saveShift(newShift);
    notifyListeners();
  }

  /// delete shift from database
  Future<void> deleteShift(String shiftID) async {
    shiftRepository.deleteShift(shiftID);
    notifyListeners();
  }


  //----------------- Initialization Methods -----------------
  
  Future<void> initialize() async {
    /// load data from database on initialization
    _loadShifts();
    _loadMapOfShiftsByAssistants();
    _loadMapOfShiftsByDay();
    log('shiftModel: initialized with ${shifts.length} shifts');
  }

  Future<void> _loadShifts() async {
    shifts = await shiftRepository.fetchAllShifts();
  }

  Future<void> _loadMapOfShiftsByDay() async {
    mapOfShiftsByDay.clear();
    for (final shift in shifts) {
      /// add shift to every day it is scheduled
      DateTime currentDay = DateTime(shift.start.year, shift.start.month, shift.start.day);
      /// loop through days until end of shift
      while (currentDay.isBefore(shift.end) || currentDay.isAtSameMomentAs(shift.end)) {
        mapOfShiftsByDay.putIfAbsent(currentDay, () => []);
        mapOfShiftsByDay[currentDay]!.add(shift);
        currentDay = currentDay.add(Duration(days: 1));
      }
    }
    log('ShiftModel: Loaded mapOfShiftsByDay with ${mapOfShiftsByDay.length} days and their shifts.');
    notifyListeners();
  }


  Future<void> _loadMapOfShiftsByAssistants() async {
    mapOfShiftsByAssistant.clear();
    for (final shift in shifts) {
      if (shift.assistantID != null) {
        mapOfShiftsByAssistant.putIfAbsent(shift.assistantID!, () => []);
        mapOfShiftsByAssistant[shift.assistantID!]!.add(shift);
      } else {
        log('ShiftModel: Shift with ID ${shift.shiftID} has no assistant assigned.');
      }
    }
    log('ShiftModel: Loaded mapOfShiftsByAssistant with ${mapOfShiftsByAssistant.length} assistants and their shifts.');
    notifyListeners();
  }

}
