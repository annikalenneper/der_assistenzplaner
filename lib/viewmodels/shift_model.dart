
import 'dart:developer';
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

/// handels shifts and scheduled shifts, saves them to database
/// used by WorkScheduleModel to generate work schedule and display shifts in calendar
class ShiftModel extends ChangeNotifier {
  late Box<Shift> _shiftBox;
  late Box<ScheduledShift> _scheduledShiftBox;
  List<ScheduledShift> scheduledShifts = [];
  List<Shift> upcomingShifts = [];
  List<ScheduledShift> scheduledAndUpcomingShifts = []; // TO-DO combine scheduled and unscheduled shifts
  Map<String, List<ScheduledShift>> shiftsByAssistantsMap = {};
  Shift? currentShift;

  Map<String, List<ScheduledShift>> getMapOfShiftsByAssistants() {
    Map<String, List<ScheduledShift>> map = {};
    for (var shift in scheduledShifts) {
      if (!map.containsKey(shift.assistantID)) {
        map[shift.assistantID] = [];
      }
      map[shift.assistantID]!.add(shift);
    }
    return map;
  }
    
  ShiftModel();

  //----------------- Getter methods -----------------

  DateTime get start => currentShift?.start ?? DateTime.now();
  DateTime get end => currentShift?.end ?? DateTime.now();
  Duration get duration => currentShift?.duration ?? Duration.zero;
  String get assistantID {
    if (currentShift != null && currentShift is ScheduledShift){
      return (currentShift as ScheduledShift).assistantID;
    } else {
      return '';
    }
  }  


  //TO-DO: implement method to get assistant by ID

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

  //-------------




  /// get assistant assigned to shift by ID (move to AssistantModel? -> shift as parameter?)
  Assistant getAssignedAssistant(context) {
    final assistants = Provider.of<AssistantModel>(context, listen: false).assistants;
    return assistants.firstWhere((assistant) => 
      assistant.assistantID == (currentShift as ScheduledShift).assistantID);
  }


  //----------------- Database methods -----------------

  /// initialize box for shift objects 
  Future<void> initialize() async {
    _shiftBox = await Hive.openBox<Shift>('shiftBox');
    _scheduledShiftBox = await Hive.openBox<ScheduledShift>('scheduledShiftBox');
  
  /// listen to changes in database and update shifts lists and map accordingly
    _shiftBox.watch().listen((event) {
      ///TO-DO: update scheduledAndUpcomingShifts 
      notifyListeners(); 
      log('shiftModel: shifts list updated');
    });
    _scheduledShiftBox.watch().listen((event) {
      scheduledShifts = _scheduledShiftBox.values.toList();
      shiftsByAssistantsMap = getMapOfShiftsByAssistants();
      notifyListeners(); 
      log('shiftModel: scheduled shifts list updated');
    });

    scheduledShifts = _scheduledShiftBox.values.toList();
    shiftsByAssistantsMap = getMapOfShiftsByAssistants();
  }

    /// read shifts from shiftboxes 
  List<ScheduledShift> getAllScheduledShifts() => _scheduledShiftBox.values.toList();

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return _scheduledShiftBox.values.where(
      (shift) => shift.start.day == day.day).toList();
  }

  List<ScheduledShift> getScheduledShiftsByDayRange(DateTime start, DateTime end) {
  return _scheduledShiftBox.values.where(
          (shift) => shift.start.day >= start.day && shift.end.day <= end.day).toList();
  }

  List<Shift> getUnscheduledShiftsByDayRange(DateTime start, DateTime end) {
  return _shiftBox.values.where(
          (shift) => shift.start.day >= start.day && shift.end.day <= end.day).toList();
  }


  /// save current shift to shiftbox, only needed for flexible/individual shifts
  Future<void> saveCurrentShiftAsShift() async {
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

