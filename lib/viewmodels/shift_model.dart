
import 'dart:developer';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class ShiftModel extends ChangeNotifier {
  late Box<Shift> _shiftBox;
  late Box<ScheduledShift> _scheduledShiftBox;
  Shift? currentShift;

  ShiftModel();

  //----------------- Getter methods -----------------

  DateTime get start => currentShift?.start ?? DateTime.now();
  DateTime get end => currentShift?.end ?? DateTime.now();
  Duration get duration => currentShift?.duration ?? Duration.zero;

  //----------------- Setter methods -----------------

  set shift(Shift shift) {
    currentShift = shift;
    log('shiftModel: currentshift set to $shift');
    notifyListeners();
  }

  set start(DateTime start) {
    currentShift?.start = start;
    log('shiftModel: start set to $start');
    notifyListeners();
  }

  set end(DateTime end) {
    currentShift?.end = end;
    log('shiftModel: end set to $end');
    notifyListeners();
  }

  //----------------- Database methods -----------------

  /// initialize box for shift objects 
  Future<void> initialize() async {
    _shiftBox = await Hive.openBox<Shift>('shiftBox');
  
  /// listen to changes in database and update shifts list accordingly
    _shiftBox.watch().listen((event) {
      notifyListeners(); 
      log('shiftModel: shifts list updated');
    });
  }

  /// save current shift to shiftbox, only needed for flexible/individual shifts
  Future<void> saveCurrentShift() async {
    if (currentShift == null) {
      log('shiftModel: currentshift is null');
      return;
    } 
    await _shiftBox.add(currentShift!);
    notifyListeners(); 
  }

  /// save current shift to scheduledshiftbox and assign assistant via ID
  Future<void> saveCurrentShiftAsScheduledShift(assistantID) async {
    if (currentShift == null) {
      log('shiftModel: currentshift is null');
      return;
    } 
    await _scheduledShiftBox.add(ScheduledShift(currentShift!.start, currentShift!.end, assistantID));
    notifyListeners(); 
  }

  /// update shift at corresponding hive box depending on type
  Future<void> updateShift(Shift updatedShift) async {
    if (currentShift != null){
      if (updatedShift is ScheduledShift) {
        await _scheduledShiftBox.putAt(currentShift!.key, updatedShift);
        } else {
          await _shiftBox.putAt(currentShift!.key, updatedShift);
        }
        log('shiftModel: shift updated in database at index ${currentShift!.key}');
        notifyListeners(); 
    }
    else {
      log('shiftModel: currentshift is null');
    }      
  }

  /// get shifts from shiftboxes 
  List<Shift> getUnscheduledShiftsByDayRange(DateTime start, DateTime end) {
  return _shiftBox.values.where(
          (shift) => shift.start.day >= start.day && shift.end.day <= end.day).toList();
  }
  List<Shift> getScheduledShiftsByDayRange(DateTime start, DateTime end) {
  return _scheduledShiftBox.values.where(
          (shift) => shift.start.day >= start.day && shift.end.day <= end.day).toList();
  }

  /// delete current shift from corresponding hive box, depending on type
  Future<void> deleteShift() async {
    if (currentShift != null) {
      if (currentShift! is ScheduledShift) {
        await _scheduledShiftBox.delete(currentShift!.key);
      } else {
        await _shiftBox.delete(currentShift!.key);
      }
      log('shiftModel: shift deleted from database at index ${currentShift!.key}');
      notifyListeners();
    } else {
      log('shiftModel: currentshift is null');
    }
    notifyListeners(); 
  }
}

