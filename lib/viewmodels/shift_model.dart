
import 'dart:developer';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:der_assistenzplaner/models/shift.dart';


/// handels shifts and scheduled shifts, saves them to database
/// used by WorkScheduleModel to generate work schedule and display shifts in calendar
class ShiftModel extends ChangeNotifier {
  late Box<Shift> _shiftBox;
  List<Shift> shifts = [];
  final MarkerCache markerCache = MarkerCache();

  Shift? currentShift;

  ShiftModel();

  //----------------- Getter methods -----------------

  DateTime get start => currentShift?.start ?? DateTime.now();
  DateTime get end => currentShift?.end ?? DateTime.now();
  Duration get duration => currentShift?.duration ?? Duration.zero;

  List<Shift> get scheduledShifts => shifts.where((shift) => shift.isScheduled).toList();
  List<Shift> get unscheduledShifts => shifts.where((shift) => !shift.isScheduled).toList();


  //------------------ Filter Methods ------------------

  List<Shift> getShiftsByDay(DateTime day) {
    return shifts.where((shift) =>
            shift.start.year == day.year &&
            shift.start.month == day.month &&
            shift.start.day == day.day)
        .toList();
  }

  List<Shift> getShiftsByDateRange(DateTime start, DateTime end) {
    return shifts
        .where((shift) =>
            (shift.start.isAfter(start) || shift.start.isAtSameMomentAs(start)) &&
            (shift.end.isBefore(end) || shift.end.isAtSameMomentAs(end)))
        .toList();
  }
  
  Map<String, List<Shift>> getMapOfShiftsByAssistants() {
    Map<String, List<Shift>> map = {};
    for (var shift in scheduledShifts) {
      if (shift.assistantID != '') {
        /// creates new key if current assistantID is no key yet
        map.putIfAbsent(shift.assistantID, () => []);
        /// inserts shift according to key
        map[shift.assistantID]!.add(shift);
      }
    }
    return map;
  }


  //----------------- Database Methods -----------------

  Future<void> initialize() async {
    _shiftBox = await Hive.openBox<Shift>('shiftBox');

    /// load inital data from database
    shifts = _shiftBox.values.toList();

    /// watch database changes
    _shiftBox.watch().listen((event) {
      shifts = _shiftBox.values.toList();
      notifyListeners();
      markerCache.clearCache();
      log('shiftModel: shifts list updated');
    });
  }

  /// save shift in shiftbox
  Future<void> saveShift(Shift newShift) async {
    await _shiftBox.add(newShift);
    log('shiftModel: saved shift to database');
  }

  /// update shift using key to find it in database
  Future<void> updateShift(Shift updatedShift) async {
    if (currentShift != null && currentShift!.key != null) {
      await _shiftBox.put(currentShift!.key, updatedShift);
      log('shiftModel: shift updated with key ${currentShift!.key}');
    } else {
      log('shiftModel: currentShift is null or has no key');
    }
  }
}
