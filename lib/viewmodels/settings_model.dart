
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/data/shared-preferences/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

enum ShiftFrequency { daily, recurring, flexible }

class SettingsModel extends ChangeNotifier {
  SettingsRepository settingsRepository = SettingsRepository();

  late bool _shiftDuration24h;
  late TimeOfDay _shiftStart;
  late TimeOfDay _shiftEnd;
  late ShiftFrequency _shiftFrequency;
  late Set<int> _weekdays;

  Duration get shiftDuration => calculateTimeOfDayDuration(_shiftStart, _shiftEnd);

  /// keys for SharedPreferences 
  static const String keyFrequency = 'shiftFrequency';
  static const String key24hShift = 'is24hShift';
  static const String keyShiftStart = 'customShiftStart';
  static const String keyShiftEnd = 'customShiftEnd';
  static const String keyWeekdays = 'weekdays';
 

  //----------------- Getter Methods -----------------

  ShiftFrequency get shiftFrequency => _shiftFrequency;
  Set<int> get selectedWeekdays => _weekdays;
  bool get is24hShift => _shiftDuration24h;
  TimeOfDay get shiftStart => _shiftStart;
  TimeOfDay get shiftEnd => _shiftEnd;


  //----------------- Data Methods -----------------

  void saveIf24hShift(value) {
    _shiftDuration24h = value;
    _saveToPreferences(key24hShift, value);
    log("settings_model: is24hShift set to $value");
    notifyListeners();
  }

  void saveShiftFrequency(ShiftFrequency frequency) {
    _shiftFrequency = frequency;
    _saveToPreferences(keyFrequency, frequency.name);
    log("settings_model: shiftFrequency set to $frequency");
    notifyListeners();
  }
  
  void saveWeekdays(Set<int> selectedWeekdays) {
    _weekdays = selectedWeekdays;
    _saveToPreferences(keyWeekdays, selectedWeekdays.toSet());
    notifyListeners();
  }

  void saveShiftStart(TimeOfDay time) {
    _shiftStart = time;
    _saveToPreferences(keyShiftStart, time);
    log("settings_model: customShiftStart set to $time");
    notifyListeners();
  }

  void saveShiftEnd(TimeOfDay time) {
    _shiftEnd = time;
    _saveToPreferences(keyShiftEnd, time);
    log("settings_model: customShiftEnd set to $time");
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
    _shiftDuration24h = await SharedPreferencesHelper.loadValue(key24hShift, bool) ?? false;
    _shiftStart = await SharedPreferencesHelper.loadValue(keyShiftStart, TimeOfDay) ?? defaultShiftStart;
    _shiftEnd = await SharedPreferencesHelper.loadValue(keyShiftEnd, TimeOfDay) ?? defaultShiftEnd;
    _shiftFrequency = await settingsRepository.getShiftFrequency();
    _weekdays = await settingsRepository.getSelectedWeekdays();    

  }
}

