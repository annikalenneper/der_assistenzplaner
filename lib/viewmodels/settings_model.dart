
import 'dart:developer';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/data/shared-preferences/shared_preferences_helper.dart';
import 'package:der_assistenzplaner/views/shared/user_input_widgets.dart';
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

