import 'package:der_assistenzplaner/data/models/availability.dart';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:flutter/material.dart';


class AvailabilitiesModel extends ChangeNotifier{
  SettingsRepository settingsRepository = SettingsRepository();

  Duration _minimumBetweenStartAndDueDate = Duration(days: 7);

  late DateTime currentAvailabilitesStartDate;
  late DateTime currentAvailabilitesDueDate;
  late int availabilitiesCount;
  late Set<Availability> currentAvailabilities;
  late Set<Availability> pastAvailabilities;

  /// keys for SharedPreferences
  static const String keyAvailabilitiesDueDate = 'availabilitiesDueDate';
  static const String keyAvailabilitiesStartDate = 'availabilitiesStartDate';
  static const String keyAvailabilitiesCount = 'availabilitiesCount';
  static const String keyCurrentAvailabilities = 'currentAvailabilities';
  static const String keyPastAvailabilities = 'pastAvailabilities';


  //----------------- Formatted Values -----------------

  String get formattedAvailabilitiesStartDate => formatDateAndTime(currentAvailabilitesStartDate);
  String get formattedAvailabilitiesDueDate => formatDateAndTime(currentAvailabilitesDueDate);
  int get daysUntilAvailabilitiesDueDate => currentAvailabilitesDueDate.difference(DateTime.now()).inDays;


  //----------------- Setter methods -----------------

  set availabilitiesStartDate(DateTime value) {
    DateTime earliestPossibleStartDate = currentAvailabilitesStartDate.subtract(_minimumBetweenStartAndDueDate);

    (value.isBefore(earliestPossibleStartDate)) 
          ? currentAvailabilitesStartDate = value 
          : currentAvailabilitesStartDate = earliestPossibleStartDate;
  }

  set availabilitiesDueDate(DateTime value) {
    DateTime latestPossibleDueDate = currentAvailabilitesStartDate.add(_minimumBetweenStartAndDueDate);

    (value.isAfter(latestPossibleDueDate)) 
          ? currentAvailabilitesDueDate = value 
          : currentAvailabilitesDueDate = latestPossibleDueDate;
  }

  //----------------- UI methods -----------------


  //----------------- Application specific internal methods --------------------

  Future<void> _deleteOutdatedAvailabilities() async {
    /// TO-DO: implement deleting outdated availabilities from database
  }

  Future<void> _updateAvailabilitiesCount() async {
    /// TO-DO: implement saving availabilities to database
  }





  //----------------- Initialization methods -----------------

  Future<void> init() async {
    await _loadAvailabilities();

    /// get values from SharedPreferences using SettingsRepository
    currentAvailabilitesStartDate = await _loadCurrentAvailabilitiesStartDate();
    currentAvailabilitesDueDate = await _loadCurrentAvailabilitiesDueDate();
  }

  Future<void> _loadAvailabilities() async {
    /// TO-DO: implement loading availabilities from database
  }

  Future<DateTime> _loadCurrentAvailabilitiesStartDate() async {
    int date = await settingsRepository.getAvailabilitiesStartDate() ?? 1;
    return DateTime(DateTime.now().year, DateTime.now().month, date);
  }

  Future<DateTime> _loadCurrentAvailabilitiesDueDate() async {
    int date = await settingsRepository.getAvailabilitiesDueDate() ?? 15;
    return DateTime(DateTime.now().year, DateTime.now().month, date);
  }

}