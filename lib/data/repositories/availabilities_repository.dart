import 'dart:developer';
import 'package:der_assistenzplaner/data/models/availability.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AvailabilitiesRepository {
  static const String boxName = 'availabilities';
  
  /// get a reference to the availabilities box
  Box<Availability> get _availabilitiesBox => Hive.box<Availability>(boxName);

  /// fetch all availabilities from the box
  Future<Set<Availability>> fetchAllAvailabilities() async {
    final availabilities = _availabilitiesBox.values.toSet();
    log('AvailabilitiesRepository: Fetched ${availabilities.length} availabilities from database.');
    return availabilities;
  }

  /// save availability to the box
  Future<void> saveAvailability(Availability availability) async {
    await _availabilitiesBox.put(availability.availabilityID, availability);
    log('AvailabilitiesRepository: Saved availability ${availability.availabilityID} to database.');
  }

  /// delete availability from the box
  Future<void> deleteAvailability(String availabilityID) async {
    await _availabilitiesBox.delete(availabilityID);
    log('AvailabilitiesRepository: Deleted availability $availabilityID from database.');
  }

  /// get a specific availability by ID
  Future<Availability?> getAvailabilityById(String availabilityID) async {
    final availability = _availabilitiesBox.get(availabilityID);
    if (availability != null) {
      log('AvailabilitiesRepository: Found availability $availabilityID in database.');
    } else {
      log('AvailabilitiesRepository: Availability $availabilityID not found in database.');
    }
    return availability;
  }

  /// get all availabilities for a specific assistant
  Future<Set<Availability>> getAvailabilitiesByAssistant(String assistantID) async {
    final availabilities = _availabilitiesBox.values
        .where((availability) => availability.assistantID == assistantID)
        .toSet();
    log('AvailabilitiesRepository: Found ${availabilities.length} availabilities for assistant $assistantID.');
    return availabilities;
  }

  /// get all availabilities for a specific shift
  Future<Set<Availability>> getAvailabilitiesByShift(String shiftID) async {
    final availabilities = _availabilitiesBox.values
        .where((availability) => availability.shiftID == shiftID)
        .toSet();
    log('AvailabilitiesRepository: Found ${availabilities.length} availabilities for shift $shiftID.');
    return availabilities;
  }

  /// check if a specific availability exists
  Future<bool> availabilityExists(String availabilityID) async {
    final exists = _availabilitiesBox.containsKey(availabilityID);
    log('AvailabilitiesRepository: Availability $availabilityID exists: $exists.');
    return exists;
  }

  /// check if an assistant is available for a specific shift
  Future<bool> isAssistantAvailableForShift(String assistantID, String shiftID) async {
    final isAvailable = _availabilitiesBox.values.any((availability) =>
        availability.assistantID == assistantID && availability.shiftID == shiftID);
    log('AvailabilitiesRepository: Assistant $assistantID is available for shift $shiftID: $isAvailable.');
    return isAvailable;
  }

  /// get all assistant IDs that are available for a specific shift
  Future<Set<String>> getAvailableAssistantsForShift(String shiftID) async {
    final assistantIDs = _availabilitiesBox.values
        .where((availability) => availability.shiftID == shiftID)
        .map((availability) => availability.assistantID)
        .toSet();
    log('AvailabilitiesRepository: Found ${assistantIDs.length} available assistants for shift $shiftID.');
    return assistantIDs;
  }

  /// delete all availabilities for a specific shift (useful when a shift is deleted)
  Future<void> deleteAvailabilitiesForShift(String shiftID) async {
    final availabilitiesToDelete = _availabilitiesBox.values
        .where((availability) => availability.shiftID == shiftID)
        .toList();
    
    for (final availability in availabilitiesToDelete) {
      await _availabilitiesBox.delete(availability.availabilityID);
    }
    
    log('AvailabilitiesRepository: Deleted ${availabilitiesToDelete.length} availabilities for shift $shiftID.');
  }

  /// delete all availabilities for a specific assistant (useful when an assistant is deleted)
  Future<void> deleteAvailabilitiesForAssistant(String assistantID) async {
    final availabilitiesToDelete = _availabilitiesBox.values
        .where((availability) => availability.assistantID == assistantID)
        .toList();
    
    for (final availability in availabilitiesToDelete) {
      await _availabilitiesBox.delete(availability.availabilityID);
    }
    
    log('AvailabilitiesRepository: Deleted ${availabilitiesToDelete.length} availabilities for assistant $assistantID.');
  }

  /// clear all availabilities from the box
  Future<void> clearAllAvailabilities() async {
    await _availabilitiesBox.clear();
    log('AvailabilitiesRepository: Cleared all availabilities from database.');
  }

  /// get total count of availabilities
  Future<int> getAvailabilitiesCount() async {
    final count = _availabilitiesBox.length;
    log('AvailabilitiesRepository: Total availabilities count: $count.');
    return count;
  }
}