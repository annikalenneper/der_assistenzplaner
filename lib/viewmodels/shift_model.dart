


import 'dart:developer';

import 'package:der_assistenzplaner/models/shift.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class ShiftModel extends ChangeNotifier {
  late Box<Shift> _shiftBox;
  Shift? currentshift;



    //----------------- Database methods -----------------

  /// initialize box for shift objects 
  Future<void> initialize() async {
    _shiftBox = await Hive.openBox<Shift>('shiftBox');
  
  /// listen to changes in database and update shifts list accordingly
    _shiftBox.watch().listen((event) {
      notifyListeners(); 
      log('shiftModel: shifts list updated');
    });
  }

  Future<void> saveCurrentshift() async {
    if (currentshift == null) {
      log('shiftModel: currentshift is null');
      return;
    } 
    await _shiftBox.add(currentshift!);
    notifyListeners(); 
  }

  Future<void> updateshift(int index, Shift updatedshift) async {
    await _shiftBox.putAt(index, updatedshift); 
    notifyListeners(); 
  }

  List<Shift> getAllshifts() {
    return _shiftBox.values.toList();
  }

  Future<void> deleteshift() async {
    if (currentshift != null) {
      await _shiftBox.delete(currentshift!.key);
      notifyListeners();
    } else {
      log('shiftModel: currentshift is null');
    }
    notifyListeners(); 
  }
}

