
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/data/shared-preferences/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

enum ShiftFrequency { daily, recurring, flexible }

class SettingsModel extends ChangeNotifier {
  SettingsRepository settingsRepository = SettingsRepository();

  Duration _minimumBetweenStartAndDueDate = Duration(days: 7);

  late DateTime availabilitesStartDate;
  late DateTime availabilitesDueDate;
  late bool allShiftsAre24hShifts;
  late TimeOfDay customShiftStart;
  late TimeOfDay customShiftEnd;
  late ShiftFrequency shiftFrequency;
  late Set<int> selectedWeekdays;

  Duration get customShiftDuration => calculateTimeOfDayDuration(customShiftStart, customShiftEnd);

  /// keys for SharedPreferences 
  static const String key24hShift = 'is24hShift';
  static const String keyCustomShiftStart = 'customShiftStart';
  static const String keyCustomShiftEnd = 'customShiftEnd';
  static const String keyAvailabilitiesDueDate = 'availabilitiesDueDate';
  static const String keyAvailabilitiesStartDate = 'availabilitiesStartDate';
  static const String keySelectedWeekdays = 'selectedWeekdays';
  static const String keyShiftSettings = 'shiftFrequency';


  //----------------- Formatted Values -----------------

  String get formattedAvailabilitiesStartDate => formatDateTime(availabilitesStartDate);
  String get formattedAvailabilitiesDueDate => formatDateTime(availabilitesDueDate);
  String get formattedCustomShiftStart => formatTimeOfDay(customShiftStart);
  String get formattedCustomShiftEnd => formatTimeOfDay(customShiftEnd);
  String get formattedShiftFrequency => shiftFrequency.name.toString();
  
  bool isWeekdaySelected(int day) => selectedWeekdays.contains(day);


  //----------------- Setter methods -----------------

  set availabilitiesStartDate(DateTime value) {
    DateTime earliestPossibleStartDate = availabilitesDueDate.subtract(_minimumBetweenStartAndDueDate);

    (value.isBefore(earliestPossibleStartDate)) 
          ? availabilitesStartDate = value 
          : availabilitesStartDate = earliestPossibleStartDate;
  }

  set availabilitiesDueDate(DateTime value) {
    DateTime latestPossibleDueDate = availabilitesStartDate.add(_minimumBetweenStartAndDueDate);

    (value.isAfter(latestPossibleDueDate)) 
          ? availabilitesDueDate = value 
          : availabilitesDueDate = latestPossibleDueDate;
  }


  //----------------- UI methods -----------------

  void toggle24hShift(value) {
    allShiftsAre24hShifts = value;
    _saveToPreferences(key24hShift, value);
    log("settings_model: is24hShift set to $value");
    notifyListeners();
  }

  void updateShiftFrequency(ShiftFrequency frequency) {
    shiftFrequency = frequency;
    _saveToPreferences(keyShiftSettings, frequency.name);
    log("settings_model: shiftFrequency set to $frequency");
    notifyListeners();
  }
  
  void toggleWeekday(int day) {
    if (selectedWeekdays.contains(day)) {
      selectedWeekdays.remove(day);
      log("settings_model: removed ${dayOfWeekToString(day)} from selectedWeekdays");
    } else {
      selectedWeekdays.add(day);
      log("settings_model: added ${dayOfWeekToString(day)} to selectedWeekdays");
    }
    _saveToPreferences(keySelectedWeekdays, selectedWeekdays.toSet());
    notifyListeners();
  }

  void deselectWeekday(int day) {
    if (selectedWeekdays.contains(day)) {
      selectedWeekdays.remove(day);
      _saveToPreferences(keySelectedWeekdays, selectedWeekdays.toSet());
      log("settings_model: removed ${dayOfWeekToString(day)} from selectedWeekdays");
      notifyListeners();
    }
  }

  //----------------- Save to Database -----------------

  void _saveToPreferences(String key, dynamic value) {
    SharedPreferencesHelper.saveValue(key, value);
  }


  //------------------ Initialization Methods ------------------	

  Future<void> initialize() async {
    await _loadFromPrefs();
    log("settings_model: initialized with preferences");
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    /// default values
    DateTime defaultAvailabilitiesStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime defaultAvailabilityDueDate = DateTime(DateTime.now().year, DateTime.now().month, 15);
    TimeOfDay defaultShiftStart = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay defaultShiftEnd = const TimeOfDay(hour: 16, minute: 0);

    /// load settings from SharedPreferences using the repository
    availabilitesStartDate = await settingsRepository.getAvailabilitiesStartDate() ?? defaultAvailabilitiesStartDate;
    availabilitesDueDate = await settingsRepository.getAvailabilitiesDueDate() ?? defaultAvailabilityDueDate;
    allShiftsAre24hShifts = await SharedPreferencesHelper.loadValue(key24hShift, bool) ?? false;
    customShiftStart = await SharedPreferencesHelper.loadValue(keyCustomShiftStart, TimeOfDay) ?? defaultShiftStart;
    customShiftEnd = await SharedPreferencesHelper.loadValue(keyCustomShiftEnd, TimeOfDay) ?? defaultShiftEnd;
    shiftFrequency = await settingsRepository.getShiftFrequency();
    selectedWeekdays = await settingsRepository.getSelectedWeekdays();    

  }
}

