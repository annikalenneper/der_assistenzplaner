import 'dart:developer';
import 'package:der_assistenzplaner/data/models/availability.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AvailabilitiesRepository {
  const AvailabilitiesRepository();
  static const String boxName = 'availabilities';
  
  /// Dynamisches Öffnen der Box bei jeder Operation, wie bei ShiftRepository
  Future<Box<Availability>> _getBox() async {
    return await Hive.openBox<Availability>(boxName);
  }

  /// fetch all availabilities from the box
  Future<Set<Availability>> fetchAllAvailabilities() async {
    try {
      final box = await _getBox();
      final availabilities = box.values.toSet();
      log('AvailabilitiesRepository: Fetched ${availabilities.length} availabilities from database.');
      return availabilities;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to fetch availabilities: $e', stackTrace: stackTrace);
      return <Availability>{}; // Leeres Set zurückgeben im Fehlerfall
    }
  }

  /// save availability to the box
  Future<void> saveAvailability(Availability availability) async {
    try {
      final box = await _getBox();
      await box.put(availability.availabilityID, availability);
      log('AvailabilitiesRepository: Saved availability ${availability.availabilityID} to database.');
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to save availability: $e', stackTrace: stackTrace);
    }
  }

  /// delete availability from the box
  Future<void> deleteAvailability(String availabilityID) async {
    try {
      final box = await _getBox();
      await box.delete(availabilityID);
      log('AvailabilitiesRepository: Deleted availability $availabilityID from database.');
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to delete availability: $e', stackTrace: stackTrace);
    }
  }

  /// get a specific availability by ID
  Future<Availability?> getAvailabilityById(String availabilityID) async {
    try {
      final box = await _getBox();
      final availability = box.get(availabilityID);
      if (availability != null) {
        log('AvailabilitiesRepository: Found availability $availabilityID in database.');
      } else {
        log('AvailabilitiesRepository: Availability $availabilityID not found in database.');
      }
      return availability;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to get availability: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// get all availabilities for a specific assistant
  Future<Set<Availability>> getAvailabilitiesByAssistant(String assistantID) async {
    try {
      final box = await _getBox();
      final availabilities = box.values
          .where((availability) => availability.assistantID == assistantID)
          .toSet();
      log('AvailabilitiesRepository: Found ${availabilities.length} availabilities for assistant $assistantID.');
      return availabilities;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to get availabilities by assistant: $e', stackTrace: stackTrace);
      return <Availability>{};
    }
  }

  /// get all availabilities for a specific shift
  Future<Set<Availability>> getAvailabilitiesByShift(String shiftID) async {
    try {
      final box = await _getBox();
      final availabilities = box.values
          .where((availability) => availability.shiftID == shiftID)
          .toSet();
      log('AvailabilitiesRepository: Found ${availabilities.length} availabilities for shift $shiftID.');
      return availabilities;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to get availabilities by shift: $e', stackTrace: stackTrace);
      return <Availability>{};
    }
  }

  /// check if a specific availability exists
  Future<bool> availabilityExists(String availabilityID) async {
    try {
      final box = await _getBox();
      final exists = box.containsKey(availabilityID);
      log('AvailabilitiesRepository: Availability $availabilityID exists: $exists.');
      return exists;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to check if availability exists: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// check if an assistant is available for a specific shift
  Future<bool> isAssistantAvailableForShift(String assistantID, String shiftID) async {
    try {
      final box = await _getBox();
      final isAvailable = box.values.any((availability) =>
          availability.assistantID == assistantID && availability.shiftID == shiftID);
      log('AvailabilitiesRepository: Assistant $assistantID is available for shift $shiftID: $isAvailable.');
      return isAvailable;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to check assistant availability: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// get all assistant IDs that are available for a specific shift
  Future<Set<String>> getAvailableAssistantsForShift(String shiftID) async {
    try {
      final box = await _getBox();
      final assistantIDs = box.values
          .where((availability) => availability.shiftID == shiftID)
          .map((availability) => availability.assistantID)
          .toSet();
      log('AvailabilitiesRepository: Found ${assistantIDs.length} available assistants for shift $shiftID.');
      return assistantIDs;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to get available assistants: $e', stackTrace: stackTrace);
      return <String>{};
    }
  }

  /// delete all availabilities for a specific shift (useful when a shift is deleted)
  Future<void> deleteAvailabilitiesForShift(String shiftID) async {
    try {
      final box = await _getBox();
      final availabilitiesToDelete = box.values
          .where((availability) => availability.shiftID == shiftID)
          .toList();
      
      for (final availability in availabilitiesToDelete) {
        await box.delete(availability.availabilityID);
      }
      
      log('AvailabilitiesRepository: Deleted ${availabilitiesToDelete.length} availabilities for shift $shiftID.');
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to delete availabilities for shift: $e', stackTrace: stackTrace);
    }
  }

  /// delete all availabilities for a specific assistant (useful when an assistant is deleted)
  Future<void> deleteAvailabilitiesForAssistant(String assistantID) async {
    try {
      final box = await _getBox();
      final availabilitiesToDelete = box.values
          .where((availability) => availability.assistantID == assistantID)
          .toList();
      
      for (final availability in availabilitiesToDelete) {
        await box.delete(availability.availabilityID);
      }
      
      log('AvailabilitiesRepository: Deleted ${availabilitiesToDelete.length} availabilities for assistant $assistantID.');
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to delete availabilities for assistant: $e', stackTrace: stackTrace);
    }
  }

  /// clear all availabilities from the box
  Future<void> clearAllAvailabilities() async {
    try {
      final box = await _getBox();
      await box.clear();
      log('AvailabilitiesRepository: Cleared all availabilities from database.');
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to clear all availabilities: $e', stackTrace: stackTrace);
    }
  }

  /// get total count of availabilities
  Future<int> getAvailabilitiesCount() async {
    try {
      final box = await _getBox();
      final count = box.length;
      log('AvailabilitiesRepository: Total availabilities count: $count.');
      return count;
    } catch (e, stackTrace) {
      log('AvailabilitiesRepository: Failed to get availabilities count: $e', stackTrace: stackTrace);
      return 0;
    }
  }
}