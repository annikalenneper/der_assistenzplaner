import 'package:der_assistenzplaner/data/models/availability.dart';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:flutter/material.dart';


class AvailabilitiesModel extends ChangeNotifier{
  SettingsRepository settingsRepository = SettingsRepository();

  /// default values
  DateTime _defaultAvailabilitiesStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _defaultAvailabilityDueDate = DateTime(DateTime.now().year, DateTime.now().month, 15);
  Duration _minimumBetweenStartAndDueDate = Duration(days: 7);

  late DateTime availabilitesStartDate;
  late DateTime availabilitesDueDate;
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

  String get formattedAvailabilitiesStartDate => formatDateTime(availabilitesStartDate);
  String get formattedAvailabilitiesDueDate => formatDateTime(availabilitesDueDate);
  int get daysUntilAvailabilitiesDueDate => availabilitesDueDate.difference(DateTime.now()).inDays;


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
    availabilitesStartDate = await settingsRepository.getAvailabilitiesStartDate() ?? _defaultAvailabilitiesStartDate;
    availabilitesDueDate = await settingsRepository.getAvailabilitiesDueDate() ?? _defaultAvailabilityDueDate;
  }

  Future<void> _loadAvailabilities() async {
    /// TO-DO: implement loading availabilities from database
  }

}