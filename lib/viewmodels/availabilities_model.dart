import 'dart:developer';
import 'package:der_assistenzplaner/data/models/availability.dart';
import 'package:der_assistenzplaner/data/repositories/availabilities_repository.dart';
import 'package:der_assistenzplaner/data/repositories/settings_repository.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class AvailabilitiesModel extends ChangeNotifier{
  SettingsRepository settingsRepository = SettingsRepository();
  AvailabilitiesRepository availabilitiesRepository = AvailabilitiesRepository();

  Duration _minimumBetweenStartAndDueDate = Duration(days: 7);

  late DateTime currentAvailabilitesStartDate;
  late DateTime currentAvailabilitesDueDate;
  late int availabilitiesCount;
  late Set<Availability> _availabilities;
  late Set<Availability> currentAvailabilities;
  late Set<Availability> pastAvailabilities;
  late Map<String, Set<Availability>> _mapOfAvailabilitiesByAssistant;
  late Map<String, Set<Availability>> _mapOfAvailabilitiesByShift;

  /// keys for SharedPreferences
  static const String keyAvailabilitiesDueDate = 'availabilitiesDueDate';
  static const String keyAvailabilitiesStartDate = 'availabilitiesStartDate';
  static const String keyAvailabilitiesCount = 'availabilitiesCount';
  static const String keyCurrentAvailabilities = 'currentAvailabilities';
  static const String keyPastAvailabilities = 'pastAvailabilities';

  //----------------- Getter methods -----------------

  Set<Availability> get availabilities => _availabilities;
  Map<String, Set<Availability>> get availabilitiesByAssistant => _mapOfAvailabilitiesByAssistant;
  Map<String, Set<Availability>> get availabilitiesByShift => _mapOfAvailabilitiesByShift;

  Availability? getAvailabilityById(String availabilityID) {
    try {
      return _availabilities.firstWhere((availability) => availability.availabilityID == availabilityID);
    } catch (e) {
      return null;
    }
  }

  Set<Availability> getAvailabilitiesByAssistant(String assistantID) {
    return _mapOfAvailabilitiesByAssistant[assistantID] ?? <Availability>{};
  }

  Set<Availability> getAvailabilitiesByShift(String shiftID) {
    return _mapOfAvailabilitiesByShift[shiftID] ?? <Availability>{};
  }

  //----------------- Formatted Values -----------------

  String get formattedAvailabilitiesStartDate => formatTime(currentAvailabilitesStartDate);
  String get formattedAvailabilitiesDueDate => formatTime(currentAvailabilitesDueDate);
  int get daysUntilAvailabilitiesDueDate => currentAvailabilitesDueDate.difference(DateTime.now()).inDays;

  //----------------- Setter methods -----------------

  set availabilitiesStartDate(DateTime value) {
    DateTime earliestPossibleStartDate = currentAvailabilitesStartDate.subtract(_minimumBetweenStartAndDueDate);

    (value.isBefore(earliestPossibleStartDate)) 
          ? currentAvailabilitesStartDate = value 
          : currentAvailabilitesStartDate = earliestPossibleStartDate;
    notifyListeners();
  }

  set availabilitiesDueDate(DateTime value) {
    DateTime latestPossibleDueDate = currentAvailabilitesStartDate.add(_minimumBetweenStartAndDueDate);

    (value.isAfter(latestPossibleDueDate)) 
          ? currentAvailabilitesDueDate = value 
          : currentAvailabilitesDueDate = latestPossibleDueDate;
    notifyListeners();
  }

  //----------------- Data methods -----------------

  /// initialize new availability without saving it
  Availability createAvailability(String shiftID, String assistantID) {
    return Availability(shiftID, assistantID);
  }

  /// save new availability or update existing in availabilitybox through availabilitiesRepository
  Future<void> saveAvailability(Availability newAvailability) async {
    await availabilitiesRepository.saveAvailability(newAvailability);
    _addAvailabilityToLocalStructure(newAvailability);
    await _updateAvailabilitiesCount();
    notifyListeners();
  }

  /// update availability in database and local structure
  Future<void> updateAvailability(Availability availabilityToUpdate, {String? newShiftID, String? newAssistantID}) async {
    final updatedAvailability = availabilityToUpdate.copyWith(
      shiftID: newShiftID,
      assistantID: newAssistantID,
    );
    await deleteAvailability(availabilityToUpdate.availabilityID);
    await saveAvailability(updatedAvailability);
    notifyListeners();
  }

  /// delete availability from database and local structure
  Future<void> deleteAvailability(String availabilityID) async {
    await availabilitiesRepository.deleteAvailability(availabilityID);
    _deleteAvailabilityFromLocalStructure(availabilityID);
    await _updateAvailabilitiesCount();
    notifyListeners();
  }

  /// check if assistant is available for a specific shift
  bool isAssistantAvailableForShift(String assistantID, String shiftID) {
    return _availabilities.any((availability) => 
        availability.assistantID == assistantID && availability.shiftID == shiftID);
  }

  /// get all assistants available for a specific shift
  Set<String> getAvailableAssistantsForShift(String shiftID) {
    return _availabilities
        .where((availability) => availability.shiftID == shiftID)
        .map((availability) => availability.assistantID)
        .toSet();
  }

  //----------------- Local Data Methods -----------------

  void _addAvailabilityToLocalStructure(Availability newAvailability) {
    _addToAvailabilities(newAvailability);
    _addToMapOfAvailabilitiesByAssistant(newAvailability);
    _addToMapOfAvailabilitiesByShift(newAvailability);
    log('AvailabilitiesModel: Added availability ${newAvailability.availabilityID} to local structure.');
  }

  void _deleteAvailabilityFromLocalStructure(String availabilityID) {
    final availabilityToDelete = _availabilities.firstWhere((availability) => availability.availabilityID == availabilityID);
    _availabilities.remove(availabilityToDelete);
    _deleteAvailabilityFromMapOfAvailabilitiesByAssistant(availabilityToDelete);
    _deleteAvailabilityFromMapOfAvailabilitiesByShift(availabilityToDelete);
    log('AvailabilitiesModel: Deleted availability from local structure');
  }

  //----------------- UI methods -----------------

  //----------------- Application specific internal methods --------------------

  Future<void> _deleteOutdatedAvailabilities() async {
    final now = DateTime.now();
    final outdatedAvailabilities = _availabilities.where((availability) {
      // Hier könntest du Logik hinzufügen, um zu bestimmen, welche Availabilities veraltet sind
      // Zum Beispiel basierend auf dem currentAvailabilitiesDueDate
      return false; // Placeholder
    }).toList();

    for (final availability in outdatedAvailabilities) {
      await deleteAvailability(availability.availabilityID);
    }
  }

  Future<void> _updateAvailabilitiesCount() async {
    availabilitiesCount = _availabilities.length;
    // Hier könntest du den Count auch in SharedPreferences speichern
    log('AvailabilitiesModel: Updated availabilities count to $availabilitiesCount');
  }

  //----------------- Initialization methods -----------------

  Future<void> init() async {
    await _loadAvailabilities();
    await _loadMapOfAvailabilitiesByAssistant();
    await _loadMapOfAvailabilitiesByShift();
    await _updateAvailabilitiesCount();

    /// get values from SharedPreferences using SettingsRepository
    currentAvailabilitesStartDate = await _loadCurrentAvailabilitiesStartDate();
    currentAvailabilitesDueDate = await _loadCurrentAvailabilitiesDueDate();
    
    log('AvailabilitiesModel: initialized with ${_availabilities.length} availabilities');
  }

  Future<void> _loadAvailabilities() async {
    _availabilities = await availabilitiesRepository.fetchAllAvailabilities();
  }

  Future<void> _loadMapOfAvailabilitiesByAssistant() async {
    _mapOfAvailabilitiesByAssistant = {};
    for (final availability in _availabilities) {
      _mapOfAvailabilitiesByAssistant.putIfAbsent(availability.assistantID, () => <Availability>{}).add(availability);
    }
    log('AvailabilitiesModel: Loaded mapOfAvailabilitiesByAssistant with ${_mapOfAvailabilitiesByAssistant.length} assistants.');
  }

  Future<void> _loadMapOfAvailabilitiesByShift() async {
    _mapOfAvailabilitiesByShift = {};
    for (final availability in _availabilities) {
      _mapOfAvailabilitiesByShift.putIfAbsent(availability.shiftID, () => <Availability>{}).add(availability);
    }
    log('AvailabilitiesModel: Loaded mapOfAvailabilitiesByShift with ${_mapOfAvailabilitiesByShift.length} shifts.');
  }

  Future<DateTime> _loadCurrentAvailabilitiesStartDate() async {
    int date = await settingsRepository.getAvailabilitiesStartDate() ?? 1;
    return DateTime(DateTime.now().year, DateTime.now().month, date);
  }

  Future<DateTime> _loadCurrentAvailabilitiesDueDate() async {
    int date = await settingsRepository.getAvailabilitiesDueDate() ?? 15;
    return DateTime(DateTime.now().year, DateTime.now().month, date);
  }

  //----------------- Helper Methods: Data Handling -----------------

  void _addToAvailabilities(Availability newAvailability) {
    _availabilities.add(newAvailability);
    log('AvailabilitiesModel: Added availability to availabilities set');
  }

  void _addToMapOfAvailabilitiesByAssistant(Availability newAvailability) {
    _mapOfAvailabilitiesByAssistant.putIfAbsent(newAvailability.assistantID, () => {}).add(newAvailability);
    log('AvailabilitiesModel: Added availability to mapOfAvailabilitiesByAssistant');
  }

  void _addToMapOfAvailabilitiesByShift(Availability newAvailability) {
    _mapOfAvailabilitiesByShift.putIfAbsent(newAvailability.shiftID, () => {}).add(newAvailability);
    log('AvailabilitiesModel: Added availability to mapOfAvailabilitiesByShift');
  }

  void _deleteAvailabilityFromMapOfAvailabilitiesByAssistant(Availability availability) {
    _mapOfAvailabilitiesByAssistant[availability.assistantID]?.remove(availability);
  }

  void _deleteAvailabilityFromMapOfAvailabilitiesByShift(Availability availability) {
    _mapOfAvailabilitiesByShift[availability.shiftID]?.remove(availability);
  }
}