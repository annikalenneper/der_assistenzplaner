
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/shift_repository.dart';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';


class ShiftModel extends ChangeNotifier {
  ShiftRepository shiftRepository = ShiftRepository();
  Set<Shift> shifts = [] as Set<Shift>;
  Map<DateTime, Set<Shift>> mapOfShiftsByDay = {}; 
  Map<String, Set<Shift>> mapOfShiftsByAssistant = {}; 
  final MarkerCache markerCache = MarkerCache();

  Shift? currentShift;

  ShiftModel();

  //----------------- Getter methods -----------------

  DateTime get start => currentShift?.start ?? DateTime.now();
  DateTime get end => currentShift?.end ?? DateTime.now();
  Duration get duration => currentShift?.duration ?? Duration.zero;

  /// removing unscheduledShifts more efficient: only few unscheduledShifts in database
  Set<Shift> get scheduledShifts =>
      shifts.toSet()..removeWhere((shift) => !shift.isScheduled);

  Set<Shift> get unscheduledShifts => 
      shifts.where((shift) => !shift.isScheduled).toSet();


  //----------------- Setter methods -----------------

  //TO-DO: implement setter methods with checks for valid input


  //------------------ Filter Methods ------------------

  Set<Shift> getShiftsByDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return mapOfShiftsByDay[normalizedDay] ?? [] as Set<Shift>; 
  }

  Set<Shift> getShiftsByDateRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    Set<Shift> result = [] as Set<Shift>;
    DateTime currentDay = normalizedStart;
    while (currentDay.isBefore(normalizedEnd) || currentDay.isAtSameMomentAs(normalizedEnd)) {
      if (mapOfShiftsByDay.containsKey(currentDay)) {
        result.addAll(mapOfShiftsByDay[currentDay]!);
      }
      currentDay = currentDay.add(Duration(days: 1));
    }
    return result;
  }

  Set<Shift> getShiftsByAssistant(String assistantID) {
    if (mapOfShiftsByAssistant.containsKey(assistantID)) {
      return mapOfShiftsByAssistant[assistantID]!;
    }
    return [] as Set<Shift>;
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
        mapOfShiftsByDay.putIfAbsent(currentDay, () => [] as Set<Shift>);
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
        mapOfShiftsByAssistant.putIfAbsent(shift.assistantID!, () => [] as Set<Shift>);
        mapOfShiftsByAssistant[shift.assistantID!]!.add(shift);
      } else {
        log('ShiftModel: Shift with ID ${shift.shiftID} has no assistant assigned.');
      }
    }
    log('ShiftModel: Loaded mapOfShiftsByAssistant with ${mapOfShiftsByAssistant.length} assistants and their shifts.');
    notifyListeners();
  }

}
