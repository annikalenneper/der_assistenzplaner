
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/data/shared-preferences/shared_preferences_helper.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';

enum ShiftFrequency { daily, recurring, flexible }

class SettingsModel extends ChangeNotifier {
  SettingsRepository settingsRepository = SettingsRepository();

  /// default values
  TimeOfDay _defaultShiftStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _defaultShiftEnd = const TimeOfDay(hour: 16, minute: 0);

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
  static const String keySelectedWeekdays = 'selectedWeekdays';
  static const String keyShiftSettings = 'shiftFrequency';


  //----------------- Formatted Values -----------------


  String get formattedCustomShiftStart => formatTimeOfDay(customShiftStart);
  String get formattedCustomShiftEnd => formatTimeOfDay(customShiftEnd);
  String get formattedShiftFrequency => shiftFrequency.name.toString();
  
  bool isWeekdaySelected(int day) => selectedWeekdays.contains(day);


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

  void updateCustomShiftStart(TimeOfDay time) {
    customShiftStart = time;
    _saveToPreferences(keyCustomShiftStart, time);
    log("settings_model: customShiftStart set to $time");
    notifyListeners();
  }

  bool updateCustomShiftEnd(TimeOfDay time) {
    if (time.isBefore(customShiftStart)) {
      log("settings_model: customShiftEnd $time is before customShiftStart $customShiftStart");
      return false;
    } else {
      customShiftEnd = time;
      _saveToPreferences(keyCustomShiftEnd, time);
      log("settings_model: customShiftEnd set to $time");
      notifyListeners();
      return true;
    }
  }

  /// open time picker from shared input widgets for shift start and end
  void openShiftStartPicker(BuildContext context) async {
    pickTime(
      context: context, 
      initialTime: customShiftStart, 
      onTimeSelected: (pickedTime) => updateCustomShiftStart(pickedTime)
    );
  }

  void openShiftEndPicker(BuildContext context) async {
    pickTime(
      context: context, 
      initialTime: customShiftEnd, 
      onTimeSelected: (pickedTime) => updateCustomShiftEnd(pickedTime)
    );
  }

  /// returns title for shift frequency selection in settings screen
  String getShiftFrequencyTitle(ShiftFrequency frequency) {
    switch (frequency) {
      case ShiftFrequency.daily:
        return 'Meine Assistenz findet täglich statt';
      case ShiftFrequency.recurring:
        return 'Ich habe regelmäßige Schichten (z.B. 4x pro Woche)';
      case ShiftFrequency.flexible:
        return 'Meine Schichten sind flexibel';
    }
  }

  //----------------- Save to Database -----------------

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

    /// load settings from SharedPreferences using the repository
    allShiftsAre24hShifts = await SharedPreferencesHelper.loadValue(key24hShift, bool) ?? false;
    customShiftStart = await SharedPreferencesHelper.loadValue(keyCustomShiftStart, TimeOfDay) ?? _defaultShiftStart;
    customShiftEnd = await SharedPreferencesHelper.loadValue(keyCustomShiftEnd, TimeOfDay) ?? _defaultShiftEnd;
    shiftFrequency = await settingsRepository.getShiftFrequency();
    selectedWeekdays = await settingsRepository.getSelectedWeekdays();    

  }
}

