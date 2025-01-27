
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


  /// initialize new shift without saving it
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

  /// split shift at given time and save both old and new shift
  Future<void> splitShift(Shift shift, DateTime splitTime) async{
    if (splitTime.isBefore(shift.start) || splitTime.isAfter(shift.end)) {
      throw ArgumentError('Split time must be between start and end of shift.');
    }
    final newShift = Shift(splitTime, shift.end, shift.assistantID);
    shift.end = splitTime;
    await saveShift(shift);
    await saveShift(newShift);
  } 


  //----------------- Local Data Methods -----------------

  void _addShiftToLocalStructure(Shift newShift) {
    _addToShifts(newShift);
    _addToMapOfShiftsByDay(newShift);
    _addToMapOfShiftsByAssistant(newShift);
    log('ShiftModel: Added shift to local structure and updated shiftsByDay.');
  }

  void _deleteShiftFromLocalStructure(String shiftID) {
    final shiftToDelete = shifts.firstWhere((shift) => shift.shiftID == shiftID);
    shifts.remove(shiftToDelete);
    _deleteShiftFromMapOfShiftsByDay(shiftID);
    _deleteShiftFromMapOfShiftsByAssistant(shiftToDelete);
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




  //----------------- Helper Methods -----------------

  void _addToShifts(Shift newShift) {
    shifts.add(newShift);
    log('ShiftModel: Added shift to shifts list');
  }

  void _addToMapOfShiftsByDay(Shift newShift) {
    final normalizedStart = normalizeDate(newShift.start);
    final normalizedEnd = normalizeDate(newShift.end);
    DateTime currentDay = normalizedStart;

    while (!currentDay.isAfter(normalizedEnd)) {
      _mapOfShiftsByDay.putIfAbsent(currentDay, () => []).add(newShift);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    log('ShiftModel: Added shift to mapOfShiftsByDay');
  }

  void _addToMapOfShiftsByAssistant(Shift newShift) {
    if (newShift.assistantID != null) {
      _mapOfShiftsByAssistant.putIfAbsent(newShift.assistantID!, () => {}).add(newShift);
      log('ShiftModel: Added shift to mapOfShiftsByAssistant');
    } else {
      log('ShiftModel: Shift does not have an assistantID and was not added to mapOfShiftsByAssistant');
    }
  }

  void _deleteShiftFromMapOfShiftsByDay(String shiftID) {
    _mapOfShiftsByDay.forEach((day, shiftList) {
      shiftList.removeWhere((shift) => shift.shiftID == shiftID);
    });
  }

  void _deleteShiftFromMapOfShiftsByAssistant(Shift shift) {
    if (shift.assistantID != null && shift.assistantID!.isNotEmpty) {
      _mapOfShiftsByAssistant[shift.assistantID!]?.remove(shift);
    }
  }

}
