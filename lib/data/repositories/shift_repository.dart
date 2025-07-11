import 'dart:developer';

import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:hive/hive.dart';


class ShiftRepository {
  const ShiftRepository();

  //----------------- Fetch data -----------------

  Future<Set<Shift>> fetchAllShifts() async {
    try {
      final shiftBox = await Hive.openBox<Shift>('shifts');
      log('shiftRepository: fetched all shifts');
      return shiftBox.values.toSet(); // return unmodifiable set
    } catch (e, stackTrace) {
      log('shiftRepository: Failed to fetch all shifts: $e', stackTrace: stackTrace);
      return <Shift>{}; // return empty set on failure
    }
  }


  //----------------- Manipulate data -----------------

  Future<void> saveShift(Shift newShift) async {
    try {
      final shiftBox = await Hive.openBox<Shift>('shifts');
      await shiftBox.put(newShift.shiftID, newShift); // save or update
      log('shiftRepository: saved or updated shift from ${newShift.start} - ${newShift.end}');
    } catch (e, stackTrace) {
      log('shiftRepository: Failed to save or update shift with ID ${newShift.shiftID}: $e', stackTrace: stackTrace);
    }
  }

  Future<void> deleteShift(String shiftID) async {
    try {
      final shiftBox = await Hive.openBox<Shift>('shifts');
      if (shiftBox.containsKey(shiftID)) {
        await shiftBox.delete(shiftID);
        log('ShiftRepository: Shift with ID $shiftID deleted');
      } else {
        log('ShiftRepository: Shift with ID $shiftID not found');
      }
    } catch (e, stackTrace) {
      log('ShiftRepository: Failed to delete shift with ID $shiftID: $e', stackTrace: stackTrace);
    }
  }
}
