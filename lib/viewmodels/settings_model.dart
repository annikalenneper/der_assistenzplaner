
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/data/shared-preferences/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

enum ShiftFrequency { daily, recurring, flexible }

class SettingsModel extends ChangeNotifier {
  SettingsRepository settingsRepository = SettingsRepository();

  late ShiftFrequency shiftFrequency;
  late bool shiftDuration24h;
  late Set<int> weekdays;

  late TimeOfDay shiftStart;
  late TimeOfDay shiftEnd;

  Duration get shiftDuration => calculateTimeOfDayDuration(shiftStart, shiftEnd);

  late int availabilitesStartDate;
  late int availabilitesDueDate;

  /// keys for SharedPreferences 
  static const String keyFrequency = 'shiftFrequency';
  static const String key24hShift = 'is24hShift';
  static const String keyWeekdays = 'weekdays';
  static const String keyShiftStart = 'shiftStart';
  static const String keyShiftEnd = 'shiftEnd';
  static const String keyAvailabilitiesStartDate = 'availabilitiesStartDate';
  static const String keyAvailabilitiesDueDate = 'availabilitiesDueDate';

  int get selectedFrequencyKey {
    switch (shiftFrequency) {
      case ShiftFrequency.daily:
        return shiftDuration24h ? 1 : 2;
      case ShiftFrequency.recurring:
        return 3;
      case ShiftFrequency.flexible:
        return 4;
    }
  }

  bool isWeekdaySelected(int day) => weekdays.contains(day);

  //----------------- Formatting methods -----------------

  String get formattedShiftFrequency {
     switch (shiftFrequency) {
      case ShiftFrequency.daily:
        return 'täglich';
      case ShiftFrequency.recurring:
        return 'an bestimmten Wochentagen';
      case ShiftFrequency.flexible:
        return 'zu unterschiedlichen Zeiten';
     }
  }

  //----------------- Data Methods -----------------

  /// only save settings to SharedPreferences if user confirms 
  void saveAllSettings() {
    _saveToPreferences(key24hShift, shiftDuration24h);
    _saveToPreferences(keyFrequency, shiftFrequency.name);
    _saveToPreferences(keyShiftStart, shiftStart);
    _saveToPreferences(keyShiftEnd, shiftEnd);
    _saveToPreferences(keyWeekdays, weekdays.toSet());
    _saveToPreferences(keyAvailabilitiesStartDate, availabilitesStartDate);
    _saveToPreferences(keyAvailabilitiesDueDate, availabilitesDueDate);
    notifyListeners();
  }

  void saveIf24hShift(value) {
    shiftDuration24h = value;
    _saveToPreferences(key24hShift, value);
    log("settings_model: is24hShift set to $value");
    notifyListeners();
  }

  void saveShiftFrequencyByKey(int frequencyKey) {
    final frequencyData = _keyToFrequency(frequencyKey);
    shiftFrequency = frequencyData.$1;
    shiftDuration24h = frequencyData.$2;
    _saveToPreferences(keyFrequency, shiftFrequency.name);
    _saveToPreferences(key24hShift, shiftDuration24h);
    log("settings_model: shiftFrequency set to $shiftFrequency (24h: $shiftDuration24h)");
    notifyListeners();
  }


  (ShiftFrequency, bool) _keyToFrequency(int key) {
    switch (key) {
      case 1:
        return (ShiftFrequency.daily, true);
      case 2:
        return (ShiftFrequency.daily, false);
      case 3:
        return (ShiftFrequency.recurring, false);
      case 4:
        return (ShiftFrequency.flexible, false);
      default:
        throw Exception("Ungültiger Frequenz-Key: $key");
    }
  }

  
  void saveWeekdays(Set<int> selectedWeekdays) {
    weekdays = selectedWeekdays;
    _saveToPreferences(keyWeekdays, selectedWeekdays.toSet());
    notifyListeners();
  }

  void saveShiftTimes(TimeOfDay start, TimeOfDay end) {
    _saveShiftStart(start);
    _saveShiftEnd(end);
  }

  void _saveShiftStart(TimeOfDay time) {
    shiftStart = time;
    _saveToPreferences(keyShiftStart, time);
    log("settings_model: customShiftStart set to $time");
    notifyListeners();
  }

  void _saveShiftEnd(TimeOfDay time) {
    shiftEnd = time;
    _saveToPreferences(keyShiftEnd, time);
    log("settings_model: customShiftEnd set to $time");
    notifyListeners();
  }

  void saveAvailabilitiesStartDate(int startDate) {
    availabilitesStartDate = startDate;
    _saveToPreferences(keyAvailabilitiesStartDate, startDate);
    log("settings_model: availabilitiesStartDate set to $startDate");
    notifyListeners();
  }

  void saveAvailabilitiesDueDate(int dueDate) {
    availabilitesDueDate = dueDate;
    _saveToPreferences(keyAvailabilitiesDueDate, dueDate);
    log("settings_model: availabilitiesDueDate set to $dueDate");
    notifyListeners();
  }


  //----------------- Shared Preferences -----------------

  void _saveToPreferences(String key, dynamic value) {
    SharedPreferencesHelper.saveValue(key, value);
  }


  //------------------ Initialization Methods ------------------	

  Future<void> init() async {
    await _loadFromPrefs();
    log("settings_model: initialized with preferences");
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    TimeOfDay defaultShiftStart = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay defaultShiftEnd = const TimeOfDay(hour: 16, minute: 0);
    
    /// load settings from SharedPreferences using the repository
    shiftDuration24h = await SharedPreferencesHelper.loadValue(key24hShift, bool) ?? false;
    shiftStart = await SharedPreferencesHelper.loadValue(keyShiftStart, TimeOfDay) ?? defaultShiftStart;
    shiftEnd = await SharedPreferencesHelper.loadValue(keyShiftEnd, TimeOfDay) ?? defaultShiftEnd;
    shiftFrequency = await settingsRepository.getShiftFrequency();
    weekdays = await settingsRepository.getSelectedWeekdays();  
    availabilitesStartDate = await SharedPreferencesHelper.loadValue(keyAvailabilitiesStartDate, int) ?? 1;
    availabilitesDueDate = await SharedPreferencesHelper.loadValue(keyAvailabilitiesDueDate, int) ?? 15;  

  }
}

