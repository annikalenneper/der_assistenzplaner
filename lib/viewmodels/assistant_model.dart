import 'dart:developer';
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:flutter/material.dart';

class AssistantModel extends ChangeNotifier {
  final Assistant assistant;

  AssistantModel(this.assistant);

  String get name => assistant.name;
  double get contractedHours => assistant.contractedHours;
  double get actualHours => assistant.actualHours;

  ///add application specific logic 
  set name(String name) {
    assistant.name = name;
    log('AssistantModel: name set to $name');
    notifyListeners();
  }
  set contractedHours(double contractedHours) {
    assistant.contractedHours = contractedHours;
    log('AssistantModel: contractedHours set to $contractedHours');
    notifyListeners();
  } 
  set actualHours(double actualHours) {
    assistant.actualHours = actualHours;
    log('AssistantModel: actualHours set to $actualHours');
    notifyListeners();
  }
  
  void addNote(String title, String text) {
    assistant.addNote(title, text);
    log('AssistantModel: added note with title $title and text $text');
    notifyListeners();
  }

  ///TO-DO: listen to changes in workschedules and update actualHours and surchargeCounters accordingly
  void updateActualHours() {
    //TO-DO: Implement this method
    //for each scheduledShift assigned to this assistant -> (if shiftend < current date) add duration to var actualHours 
  }
  void updateSurchargeCounter() {
    //TO-DO: Implement this method
    //for each scheduledShift assigned to this assistant -> (if shiftend < current date) add surcharges to var surchargeCounter 
  }
  void updateFutureSurchargeCounter() {
    //TO-DO: Implement this method
    //for each scheduledShift assigned to this assistant -> (if shiftstart > current date) add surcharges to var futureSurchargeCounter 
  }
}