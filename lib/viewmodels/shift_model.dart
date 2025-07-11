import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/shift_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';

enum ShiftDisplayOptions { scheduled, unscheduled, all, assistant }

class ShiftModel extends ChangeNotifier {
  final ShiftRepository shiftRepository = ShiftRepository();

  late Set<Shift> _shifts;
  late Map<String, Set<Shift>> _mapOfShiftsByAssistant;
  late Map<DateTime, List<Shift>> _mapOfShiftsByDay;

  ShiftDisplayOptions _selectedShiftDisplayOption = ShiftDisplayOptions.scheduled;
  String? _selectedAssistantID;
  
  ShiftModel();

  //----------------- Getter methods -----------------
  Map<DateTime, List<Shift>> get shiftsByDay => _mapOfShiftsByDay;
  Map<String, Set<Shift>> get mapOfShiftsByAssistant => _mapOfShiftsByAssistant;
  ShiftDisplayOptions get selectedShiftDisplayOption => _selectedShiftDisplayOption;
  Set<Shift> get scheduledShifts => _shifts.toSet()..removeWhere((shift) => !shift.isScheduled);
  Set<Shift> get unscheduledShifts => _shifts.where((shift) => !shift.isScheduled).toSet();

  bool isScheduled(String shiftID) =>
    getShiftById(shiftID)?.isScheduled ?? false;

  Shift? getShiftById(String shiftID) {
    try {
      return _shifts.firstWhere((shift) => shift.shiftID == shiftID);
    } catch (_) {
      return null;
    }
  }

  Set<Shift> getScheduledShiftsByDay(DateTime day) {
    final normalizedDay = normalizeDate(day);
    return _mapOfShiftsByDay[normalizedDay]
           ?.where((shift) => shift.isScheduled)
           .toSet() ?? {};
  }

  Set<Shift> getUnscheduledShiftsByDay(DateTime day) {
    final normalizedDay = normalizeDate(day);
    return _mapOfShiftsByDay[normalizedDay]
           ?.where((shift) => !shift.isScheduled)
           .toSet() ?? {};
  }

  //----------------- UI methods -----------------
  void updateDisplayOption(ShiftDisplayOptions? option, String? assistantID) {
    if (option != null) {
      _selectedShiftDisplayOption = option;
      _filterShiftsForDisplay(option);
      log('ShiftModel: Display option set to $_selectedShiftDisplayOption');
      notifyListeners();
    }
    if (assistantID != null) {
      _selectedShiftDisplayOption = ShiftDisplayOptions.assistant;
      _selectOrToggleAssistant(assistantID);
      _filterShiftsForDisplay(_selectedShiftDisplayOption);
      log('ShiftModel: Selected assistant set to $_selectedAssistantID');
      notifyListeners();
    }
  }

  void _filterShiftsForDisplay(ShiftDisplayOptions displayOption) {
    final filtered = _selectShiftsForDisplay(null, displayOption).toList();
    _mapOfShiftsByDay = _groupShiftsByDay(filtered);
    notifyListeners();
  }

  void _selectOrToggleAssistant(String assistantID) {
    _selectedAssistantID = _selectedAssistantID == assistantID
      ? null
      : assistantID;
  }

  Set<Shift> _selectShiftsForDisplay(context, ShiftDisplayOptions selected) {
    switch (selected) {
      case ShiftDisplayOptions.scheduled:
        return scheduledShifts;
      case ShiftDisplayOptions.unscheduled:
        return unscheduledShifts;
      case ShiftDisplayOptions.all:
        return _shifts;
      case ShiftDisplayOptions.assistant:
        return (_selectedAssistantID != null)
          ? _mapOfShiftsByAssistant[_selectedAssistantID!] ?? {}
          : _shifts;
    }
  }

  //----------------- Data Methods -----------------
  Shift createShift(DateTime start, DateTime end, String? assistantID) =>
    Shift(start, end, assistantID);

  Future<void> saveShift(Shift newShift) async {
    await shiftRepository.saveShift(newShift);
    _addShiftToLocalStructure(newShift);
    notifyListeners();
  }

  Future<void> updateShift(Shift shiftToUpdate, {DateTime? newStart, DateTime? newEnd, String? newAssistantID}) async {
    final updated = shiftToUpdate.copyWith(
      start: newStart,
      end: newEnd,
      assistantID: newAssistantID,
    );
    await deleteShift(shiftToUpdate.shiftID);
    await saveShift(updated);
    notifyListeners();
  }

  Future<void> deleteShift(String shiftID) async {
    await shiftRepository.deleteShift(shiftID);
    _deleteShiftFromLocalStructure(shiftID);
    notifyListeners();
  }

  Future<void> deleteAllShifts() async {
    final copy = List<Shift>.from(_shifts);
    for (final s in copy) {
      await shiftRepository.deleteShift(s.shiftID);
    }
    _shifts.clear();
    _mapOfShiftsByDay.clear();
    _mapOfShiftsByAssistant.clear();
    log('ShiftModel: Deleted all shifts');
    notifyListeners();
  }

  Future<void> splitShift(Shift shift, DateTime splitTime) async {
    if (splitTime.isBefore(shift.start) || splitTime.isAfter(shift.end)) {
      throw ArgumentError('Split time outside shift');
    }
    if (splitTime.isAtSameMomentAs(shift.start) || splitTime.isAtSameMomentAs(shift.end)) {
      throw ArgumentError('Split time equals start/end');
    }
    final newShift = createShift(splitTime, shift.end, shift.assistantID);
    shift.end = splitTime;
    await updateShift(shift);
    await saveShift(newShift);
  }

  //----------------- Local Data Methods -----------------
  void _addShiftToLocalStructure(Shift newShift) {
    _shifts.add(newShift);
    _addToMapOfShiftsByDay(newShift);
    _addToMapOfShiftsByAssistant(newShift);
    log('ShiftModel: Added shift locally');
  }

  void _deleteShiftFromLocalStructure(String shiftID) {
    final toDel = _shifts.firstWhere((s) => s.shiftID == shiftID);
    _shifts.remove(toDel);
    _deleteShiftFromMapOfShiftsByDay(shiftID);
    _deleteShiftFromMapOfShiftsByAssistant(toDel);
    log('ShiftModel: Deleted shift locally');
  }

  //----------------- Initialization Methods -----------------
  Future<void> init() async {
    await _loadShifts();
    await _loadMapOfShiftsByAssistants();
    await _loadShiftsByDay();
    log('ShiftModel: initialized with ${_shifts.length} shifts');
  }

  Future<void> _loadShifts() async {
    _shifts = await shiftRepository.fetchAllShifts();
  }

  Future<void> _loadMapOfShiftsByAssistants() async {
    _mapOfShiftsByAssistant = {};
    for (var s in _shifts) {
      if (s.assistantID != null && s.assistantID!.isNotEmpty) {
        _mapOfShiftsByAssistant.putIfAbsent(s.assistantID!, () => {}).add(s);
      } else {
        log('ShiftModel: Unassigned shift ${s.shiftID}');
      }
    }
    log('ShiftModel: Loaded shiftsByAssistant');
    notifyListeners();
  }

  Future<void> _loadShiftsByDay() async {
    _mapOfShiftsByDay = _groupShiftsByDay(_shifts.toList());
    log('ShiftModel: Loaded shiftsByDay');
    notifyListeners();
  }

  //----------------- Helper Methods -----------------
  Map<DateTime, List<Shift>> _groupShiftsByDay(List<Shift> shifts) {
    final Map<DateTime, List<Shift>> result = {};
    for (var shift in shifts) {
      final startDay = normalizeDate(shift.start);
      final endDay = normalizeDate(shift.end);
      var day = startDay;
      while (!day.isAfter(endDay)) {
        result.putIfAbsent(day, () => []).add(shift);
        day = day.add(const Duration(days: 1));
      }
    }
    return result;
  }

  void _addToMapOfShiftsByDay(Shift shift) {
    final startDay = normalizeDate(shift.start);
    final endDay = normalizeDate(shift.end);
    var day = startDay;
    while (!day.isAfter(endDay)) {
      _mapOfShiftsByDay.putIfAbsent(day, () => []).add(shift);
      day = day.add(const Duration(days: 1));
    }
  }

  void _addToMapOfShiftsByAssistant(Shift shift) {
    if (shift.assistantID != null && shift.assistantID!.isNotEmpty) {
      _mapOfShiftsByAssistant.putIfAbsent(shift.assistantID!, () => {}).add(shift);
    }
  }

  void _deleteShiftFromMapOfShiftsByDay(String shiftID) {
    _mapOfShiftsByDay.forEach((day, list) {
      list.removeWhere((s) => s.shiftID == shiftID);
    });
  }

  void _deleteShiftFromMapOfShiftsByAssistant(Shift shift) {
    if (shift.assistantID != null && shift.assistantID!.isNotEmpty) {
      _mapOfShiftsByAssistant[shift.assistantID!]?.remove(shift);
    }
  }
}
