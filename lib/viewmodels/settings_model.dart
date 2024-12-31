
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

enum ShiftFrequency { daily, recurring, flexible }

class SettingsModel extends ChangeNotifier {
  SettingsRepository settingsRepository = SettingsRepository();

  late DateTime _availabilitesStartDate;
  late DateTime _availabilitesDueDate;
  late bool _allShiftsAre24hShifts = false;
  late TimeOfDay _customShiftStart;
  late TimeOfDay _customShiftEnd;
  late ShiftFrequency _shiftFrequency;
  late Set<int> selectedWeekdays;

  /// keys for SharedPreferences 
  static const String key24hShift = 'is24hShift';
  static const String keyCustomShiftStart = 'customShiftStart';
  static const String keyCustomShiftEnd = 'customShiftEnd';
  static const String keyAvailabilitiesDueDate = 'availabilitiesDueDate';
  static const String keyAvailabilitiesStartDate = 'availabilitiesStartDate';
  static const String keySelectedWeekdays = 'selectedWeekdays';
  static const String keyShiftSettings = 'shiftFrequency';

  /// load settings from SharedPreferences
  SettingsModel() {
    _loadFromPrefs();
  }

  DateTime get availabilitiesStartDate => _availabilitesStartDate;
  DateTime get availabilitiesDueDate => _availabilitesDueDate;
  bool get allShiftsAre24hShifts => _allShiftsAre24hShifts;
  TimeOfDay get customShiftStart => _customShiftStart;
  TimeOfDay get customShiftEnd => _customShiftEnd;
  ShiftFrequency get shiftFrequency => _shiftFrequency;

  bool isWeekdaySelected(int day) => selectedWeekdays.contains(day);


  //----------------- Setter methods -----------------

  /// saving values to SharedPreferences directly from setters and without using the repository (no boilerplate code)

  set allShiftsAre24hShifts(bool value) {
    _allShiftsAre24hShifts = value;
    SharedPreferencesHelper.saveValue(key24hShift, value);
    log("settings_model: is24hShift set to $value");
    notifyListeners();
  }

  set customShiftStart(TimeOfDay value) {
    _customShiftStart = value;
    SharedPreferencesHelper.saveValue(keyCustomShiftStart, value);
    log("settings_model: customShiftStart set to $value");
    notifyListeners();
  }

  set customShiftEnd(TimeOfDay value) {
    _customShiftEnd = value;
    SharedPreferencesHelper.saveValue(keyCustomShiftEnd, value);
    log("settings_model: customShiftEnd set to $value");
    notifyListeners();
  }

  set shiftFrequency(ShiftFrequency value) {
    _shiftFrequency = value;
    SharedPreferencesHelper.saveValue(keyShiftSettings, value.name);
    log("settings_model: shiftSettings set to $value");
    notifyListeners();
  }


  //----------------- UI methods -----------------

  void toggle24hShift() {
    allShiftsAre24hShifts = !allShiftsAre24hShifts;
  }
  
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


  //------------------ load settings from SharedPreferences ------------------	

  Future<void> _loadFromPrefs() async {
    /// default values
    DateTime defaultAvailabilityStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime defaultAvailabilityDueDate = DateTime(DateTime.now().year, DateTime.now().month, 15);
    TimeOfDay defaultShiftStart = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay defaultShiftEnd = const TimeOfDay(hour: 16, minute: 0);

    /// load settings from SharedPreferences using the repository
    _availabilitesStartDate = await settingsRepository.getAvailabilitiesStartDate() ?? defaultAvailabilityStartDate;
    _availabilitesDueDate = await settingsRepository.getAvailabilitiesDueDate() ?? defaultAvailabilityDueDate;
    _allShiftsAre24hShifts = await SharedPreferencesHelper.loadValue(key24hShift, bool) ?? false;
    _customShiftStart = await SharedPreferencesHelper.loadValue(keyCustomShiftStart, TimeOfDay) ?? defaultShiftStart;
    _customShiftEnd = await SharedPreferencesHelper.loadValue(keyCustomShiftEnd, TimeOfDay) ?? defaultShiftEnd;
    _shiftFrequency = await settingsRepository.getShiftFrequency();
    selectedWeekdays = await settingsRepository.getSelectedWeekdays();    

  }
}

