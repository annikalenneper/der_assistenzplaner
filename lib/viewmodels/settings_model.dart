
import 'dart:developer';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

enum ShiftFrequency { daily, recurring, flexible }

class SettingsModel extends ChangeNotifier {
  bool _is24hShift = false;
  TimeOfDay _defaultShiftStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _defaultShiftEnd = const TimeOfDay(hour: 16, minute: 0);
  ShiftFrequency _shiftFrequency = ShiftFrequency.daily;
  Set<int> selectedWeekdays = {};
  

  /// keys for SharedPreferences 
  static const String keyIs24hShift = 'is24hShift';
  static const String keyDefaultShiftStart = 'defaultShiftStart';
  static const String keyDefaultShiftEnd = 'defaultShiftEnd';
  static const String keyShiftSettings = 'shiftFrequency';

  /// load settings from SharedPreferences
  SettingsModel() {
    _loadFromPrefs();
  }

  bool get is24hShift => _is24hShift;
  TimeOfDay get defaultShiftStart => _defaultShiftStart;
  TimeOfDay get defaultShiftEnd => _defaultShiftEnd;
  ShiftFrequency get shiftFrequency => _shiftFrequency;

  bool isWeekdaySelected(int day) => selectedWeekdays.contains(day);

  void toggleWeekday(int day) {
    if (selectedWeekdays.contains(day)) {
      selectedWeekdays.remove(day);
      log("settings_model: removed ${dayOfWeekToString(day)} from selectedWeekdays");
    } else {
      selectedWeekdays.add(day);
      log("settings_model: added ${dayOfWeekToString(day)} to selectedWeekdays");
    }
    notifyListeners();
  }

//----------------- Setter methods -----------------

  set is24hShift(bool value) {
    _is24hShift = value;
    SharedPreferencesHelper.saveValue(keyIs24hShift, value);
    log("settings_model: is24hShift set to $value");
    notifyListeners();
  }

  set defaultShiftStart(TimeOfDay value) {
    _defaultShiftStart = value;
    SharedPreferencesHelper.saveValue(keyDefaultShiftStart, value);
    log("settings_model: defaultShiftStart set to $value");
    notifyListeners();
  }

  set defaultShiftEnd(TimeOfDay value) {
    _defaultShiftEnd = value;
    SharedPreferencesHelper.saveValue(keyDefaultShiftEnd, value);
    log("settings_model: defaultShiftEnd set to $value");
    notifyListeners();
  }

  set shiftFrequency(ShiftFrequency value) {
    _shiftFrequency = value;
    SharedPreferencesHelper.saveValue(keyShiftSettings, value.name);
    log("settings_model: shiftSettings set to $value");
    notifyListeners();
  }

//------------------ load settings from SharedPreferences ------------------	

  Future<void> _loadFromPrefs() async {

    final loadedIs24h = await SharedPreferencesHelper.loadValue(keyIs24hShift, type: bool);
    if (loadedIs24h is bool) {
      _is24hShift = loadedIs24h;
    }

    final loadedStartTime = await SharedPreferencesHelper.loadValue(keyDefaultShiftStart, type: TimeOfDay);
    if (loadedStartTime is TimeOfDay) {
      _defaultShiftStart = loadedStartTime;
    }

    final loadedEndTime = await SharedPreferencesHelper.loadValue(keyDefaultShiftEnd, type: TimeOfDay);
    if (loadedEndTime is TimeOfDay) {
      _defaultShiftEnd = loadedEndTime;
    }

    final loadedShiftStettings = await SharedPreferencesHelper.loadValue(keyShiftSettings, type: String);
    if (loadedShiftStettings is String) {
      final found = ShiftFrequency.values.firstWhere(
        (e) => e.name == loadedShiftStettings,
        orElse: () => ShiftFrequency.daily,
      );
      _shiftFrequency = found;
    }

    notifyListeners();
  }
}
