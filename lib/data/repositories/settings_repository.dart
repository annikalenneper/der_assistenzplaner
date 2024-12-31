
import 'dart:developer';
import 'package:der_assistenzplaner/data/models/tag.dart';
import 'package:der_assistenzplaner/utils/shared_preferences_helper.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';

class SettingsRepository {
  const SettingsRepository();

  //----------------- Get Data -----------------

  Future<DateTime?> getAvailabilitiesDueDate() async {
    try {
      final dueDate = await SharedPreferencesHelper.loadValue('availabilitiesDueDate', DateTime);
      if (dueDate != null) {
        log('SettingsRepository: Fetched availabilities due date.');
        return dueDate;
      } else {
        log('SettingsRepository: No availabilities due date found.');
        return null;
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching availabilities due date: $e', stackTrace: stackTrace);
      return null; // return null on failure, check in model
    }
  }

  Future<DateTime?> getAvailabilitiesStartDate() async {
    try {
      final startDate = await SharedPreferencesHelper.loadValue('availabilitiesStartDate', DateTime);
      if (startDate != null) {
        log('SettingsRepository: Fetched availabilities start date.');
        return startDate as DateTime;
      } else {
        log('SettingsRepository: No availabilities start date found.');
        return null;
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching availabilities start date: $e', stackTrace: stackTrace);
      return null; // return null on failure, check in model
    }
  }

  Future<ShiftFrequency> getShiftFrequency() async {
    try {
      final shiftFrequency = await SharedPreferencesHelper.loadValue('shiftFrequency', String);
      if (shiftFrequency != null) {
        final found = ShiftFrequency.values.firstWhere(
          (e) => e.name == shiftFrequency,
          orElse: () => ShiftFrequency.daily,
        );
        log('SettingsRepository: Fetched shift frequency.');
        return found;
      } else {
        log('SettingsRepository: No shift frequency found.');
        return ShiftFrequency.daily;
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching shift frequency: $e', stackTrace: stackTrace);
      return ShiftFrequency.daily; // return daily on failure
    }
  }

  Future<Set<int>> getSelectedWeekdays() async {
    try {
      final selectedWeekdays = await SharedPreferencesHelper.loadValue('selectedWeekdays', Set<int>);  
      if (selectedWeekdays is Set<int>) {
        log('SettingsRepository: Fetched selected weekdays: $selectedWeekdays');
        return selectedWeekdays;
      } else {
        log('SettingsRepository: No selected weekdays found. Returning an empty set.');
        return {}; // return empty set if no weekdays selected
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching selected weekdays: $e', stackTrace: stackTrace);
      return {}; // return empty set on failure
    }
  }

  Future<DateTime> getDefaultShiftStart() async {
    try {
      final defaultShiftStart = await SharedPreferencesHelper.loadValue('defaultShiftStart', DateTime);
      if (defaultShiftStart != null) {
        log('SettingsRepository: Fetched default shift start.');
        return defaultShiftStart;
      } else {
        log('SettingsRepository: No default shift start found.');
        return DateTime.now();
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching default shift start: $e', stackTrace: stackTrace);
      return DateTime.now(); // return current time on failure
    }
  }

  Future<DateTime> getDefaultShiftEnd() async {
    try {
      final defaultShiftEnd = await SharedPreferencesHelper.loadValue('defaultShiftEnd', DateTime);
      if (defaultShiftEnd != null) {
        log('SettingsRepository: Fetched default shift end.');
        return defaultShiftEnd;
      } else {
        log('SettingsRepository: No default shift end found.');
        return DateTime.now();
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching default shift end: $e', stackTrace: stackTrace);
      return DateTime.now(); // return current time on failure
    }
  }

  Future<List<Tag>> getPersonalTags () async {
    try {
      final personalTags = await SharedPreferencesHelper.loadValue('personalTags', List<Tag>);
      if (personalTags is List<Tag>) {
        log('SettingsRepository: Fetched personal tags.');
        return personalTags;
      } else {
        log('SettingsRepository: No personal tags found. Returning an empty list.');
        return []; // return empty list if no tags found
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching personal tags: $e', stackTrace: stackTrace);
      return []; // return empty list on failure
    }
  }

  Future<Map<String, List<Tag>>> getShiftTags() async {
    try {
      final shiftTags = await SharedPreferencesHelper.loadValue('shiftTags', Map<String, List<Tag>>);
      if (shiftTags is Map<String, List<Tag>>) {
        log('SettingsRepository: Fetched shift tags.');
        return shiftTags;
      } else {
        log('SettingsRepository: No shift tags found. Returning an empty map.');
        return {}; // return empty map if no tags found
      }
    } catch (e, stackTrace) {
      log('SettingsRepository: Error fetching shift tags: $e', stackTrace: stackTrace);
      return {}; // return empty map on failure
    }
  }

}