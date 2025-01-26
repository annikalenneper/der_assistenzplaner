
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/shift_repository.dart';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';

enum ShiftDisplayOptions {scheduled, unscheduled, all, assistant}

class ShiftModel extends ChangeNotifier {
  ShiftRepository shiftRepository = ShiftRepository();

  late Set<Shift> shifts;
  late Map<String, Set<Shift>> _mapOfShiftsByAssistant; 
  late Map<DateTime, List<Shift>> _mapOfShiftsByDay;

  ShiftDisplayOptions _selectedShiftDisplayOption = ShiftDisplayOptions.scheduled;
  String? _selectedAssistantID;
  final MarkerCache markerCache = MarkerCache();

  Shift? _currentShift;

  ShiftModel();

  //----------------- Getter methods -----------------

  Shift? get currentShift => _currentShift;
  DateTime get start => _currentShift?.start ?? DateTime.now();
  DateTime get end => _currentShift?.end ?? DateTime.now();
  Duration get duration => _currentShift?.duration ?? Duration.zero;
  Map<DateTime, List<Shift>> get shiftsByDay => _mapOfShiftsByDay;

  /// removing unscheduledShifts more efficient: only few unscheduledShifts in database
  Set<Shift> get scheduledShifts =>
      shifts.toSet()..removeWhere((shift) => !shift.isScheduled);

  Set<Shift> get unscheduledShifts => 
      shifts.where((shift) => !shift.isScheduled).toSet();


  //----------------- Setter methods -----------------

  set currentShift(Shift? shift) {
    _currentShift = shift;
    notifyListeners();
  }

  set start(DateTime start) =>
      (start.isBefore(end)) 
      ? currentShift?.start = start 
      : currentShift?.start = end;

  set end(DateTime end) =>
      (end.isAfter(start)) 
      ? currentShift?.end = end 
      : currentShift?.end = start;

    

  //----------------- UI methods -----------------
  
  /// update display option with either enum ShiftDisplayOptions or assistantID
  void updateDisplayOption(ShiftDisplayOptions? option, String? assistantID) {
    if (option != null) {
      _selectedShiftDisplayOption = option;
      _updateShiftsByDay(option);
      log('ShiftModel: Display option set to $_selectedShiftDisplayOption');
      notifyListeners();
    } 
    if (assistantID != null) {
      _selectedShiftDisplayOption = ShiftDisplayOptions.assistant;
      _selectedAssistantID = assistantID;
      _updateShiftsByDay(_selectedShiftDisplayOption);
      log('ShiftModel: Selected assistant set to $_selectedAssistantID');
      notifyListeners();
    } 
  }

  void _updateShiftsByDay(ShiftDisplayOptions displayOption) {
    final filteredShifts = getShiftsForDisplay(null, displayOption).toList();
    _mapOfShiftsByDay = _groupShiftsByDay(filteredShifts);
    notifyListeners();
  }

  Set<Shift> getShiftsForDisplay (context, ShiftDisplayOptions selected) {
    switch (selected) {
      case ShiftDisplayOptions.scheduled:
        return scheduledShifts;
      case ShiftDisplayOptions.unscheduled:
        return unscheduledShifts;
      case ShiftDisplayOptions.all:
        return shifts;
      case ShiftDisplayOptions.assistant:
        return _mapOfShiftsByAssistant[_selectedAssistantID] ?? <Shift>{};
    }
  }

  
  

  //------------------ Filter Methods ------------------


  Set<Shift> getShiftsByDateRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    Set<Shift> result = [] as Set<Shift>;
    DateTime currentDay = normalizedStart;
    while (currentDay.isBefore(normalizedEnd) || currentDay.isAtSameMomentAs(normalizedEnd)) {
      for (final shift in shifts) {
        if (shift.start.isBefore(currentDay) && shift.end.isAfter(currentDay)) {
          result.add(shift);
        }
      }
      currentDay = currentDay.add(Duration(days: 1));
    }
    return result;
  }

  Map<DateTime, List<Shift>> _groupShiftsByDay(List<Shift> shifts) {
    final Map<DateTime, List<Shift>> shiftsByDay = {};

    for (final shift in shifts) {
      final normalizedStart = normalizeDate(shift.start);
      final normalizedEnd = normalizeDate(shift.end);
      DateTime currentDay = normalizedStart;

      /// add shift to each day it spans, including start and end day
      while (!currentDay.isAfter(normalizedEnd)) {
        shiftsByDay.putIfAbsent(currentDay, () => []).add(shift);
        currentDay = currentDay.add(const Duration(days: 1));
      }
    }

    log('ShiftModel: Grouped ${shifts.length} shifts into ${shiftsByDay.length} days.');
    return shiftsByDay;
  }



  //----------------- Data Methods -----------------


  Shift createShift(DateTime start, DateTime end, String? assistantID) {
    return Shift(start, end, assistantID);
  }

  /// save new shift or update existing in shiftbox through shiftRepository
  Future<void> saveShift(Shift newShift) async {
    await shiftRepository.saveShift(newShift);
    _addShiftToLocalStructure(newShift);
    notifyListeners();
  }

  /// delete shift from database
  Future<void> deleteShift(String shiftID) async {
    await shiftRepository.deleteShift(shiftID);
    _deleteShiftFromLocalStructure(shiftID);
    notifyListeners();
  }


  //----------------- Helper Methods -----------------

  void _addShiftToLocalStructure(Shift newShift) {
    if(shifts.contains(newShift)) {
      log('ShiftModel: Shift already exists in local structure');
      return;
    } 
    else {
        shifts.add(newShift);
        log('ShiftModel: Added shift to local structure');
    }
  }

  void _deleteShiftFromLocalStructure(String shiftID) {
    final shiftToDelete = shifts.firstWhere((shift) => shift.shiftID == shiftID);
    shifts.remove(shiftToDelete);
    log('ShiftModel: Deleted shift from local structure');
  }


  //----------------- Initialization Methods -----------------
  
  Future<void> init() async {
    /// load data from database on initialization
    await _loadShifts();
    await _loadMapOfShiftsByAssistants();
    await _loadShiftsByDay();
    log('shiftModel: initialized with ${shifts.length} shifts');
  }

  Future<void> _loadShifts() async {
    shifts = await shiftRepository.fetchAllShifts();
  }

  Future<void> _loadMapOfShiftsByAssistants() async {
    _mapOfShiftsByAssistant = {}; 
    for (final shift in shifts) {
      if (shift.assistantID != null && shift.assistantID!.isNotEmpty) {
        _mapOfShiftsByAssistant.putIfAbsent(shift.assistantID!, () => <Shift>{}).add(shift);
      } else {
        log('ShiftModel: Shift with ID ${shift.shiftID} has no assistant assigned.');
      }
    }
    log('ShiftModel: Loaded mapOfShiftsByAssistant with ${_mapOfShiftsByAssistant.length} assistants and their shifts.');
    notifyListeners();
  }


  Future<void> _loadShiftsByDay() async {
    _mapOfShiftsByDay = _groupShiftsByDay(shifts.toList());
    log('ShiftModel: Loaded mapOfShiftsByDay with ${_mapOfShiftsByDay.length} days and their shifts.');
    notifyListeners();
  }

}
