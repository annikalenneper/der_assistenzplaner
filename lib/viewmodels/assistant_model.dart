import 'dart:developer';
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/models/tag.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssistantModel extends ChangeNotifier {
  late Box<Assistant> _assistantBox;
  late List<Assistant> assistants = getAllAssistants();
  Assistant? currentAssistant;
  
  AssistantModel();

  //----------------- Getter methods -----------------

  String get name => currentAssistant?.name ?? '';
  double get contractedHours => currentAssistant?.contractedHours ?? 0.0;
  double get actualHours => currentAssistant?.actualHours ?? 0.0;
  double get deviation => currentAssistant?.deviation ?? 0.0;
  List<double> get surchargeCounter => currentAssistant?.surchargeCounter ?? [];
  List<double> get futureSurchargeCounter => currentAssistant?.futureSurchargeCounter ?? [];
  List<Note> get notes => currentAssistant?.notes ?? [];
  List<Tag> get tags => currentAssistant?.tags ?? [];

  //----------------- Setter methods -----------------

  set assistant(Assistant assistant) {
    currentAssistant = assistant;
    log('AssistantModel: currentAssistant set to $assistant');
    notifyListeners();
  }

  set name(String name) {
    currentAssistant?.name = name;
    log('AssistantModel: name set to $name');
    notifyListeners();
  }
  set contractedHours(double contractedHours) {
    currentAssistant?.contractedHours = contractedHours;
    log('AssistantModel: contractedHours set to $contractedHours');
    notifyListeners();
  } 
  set actualHours(double actualHours) {
    currentAssistant?.actualHours = actualHours;
    log('AssistantModel: actualHours set to $actualHours');
    notifyListeners();
  }

  //----------------- User interaction methods -----------------
  
  void addNote(String title, String text) {
    currentAssistant?.addNote(title, text);
    log('AssistantModel: added note with title $title and text $text');
    notifyListeners();
  }
  
  void assignTag(Tag tag) {
    currentAssistant?.assignTag(tag);
    log('AssistantModel: assigned tag $tag');
    notifyListeners();
  }

  //----------------- Application specific methods -----------------

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

  //----------------- Database methods -----------------

  /// initialize box for assistant objects and keep assistants list synchronized with database
  Future<void> initialize() async {
  _assistantBox = await Hive.openBox<Assistant>('assistantBox');
  
  assistants = getAllAssistants();
  
  /// listen to changes in database and update assistants list accordingly
  _assistantBox.watch().listen((event) {
    assistants = getAllAssistants();
    notifyListeners(); 
    log('AssistantModel: assistants list updated');
  });
}


  Future<void> saveCurrentAssistant() async {
    if (currentAssistant == null) {
      log('AssistantModel: currentAssistant is null');
      return;
    } 
    if (assistants.contains(currentAssistant)) {
      log('AssistantModel: currentAssistant already exists in database');
      return;
    } 
    await _assistantBox.add(currentAssistant!);
    notifyListeners(); 
  }

  Future<void> updateAssistant(int index, Assistant updatedAssistant) async {
    await _assistantBox.putAt(index, updatedAssistant); 
    notifyListeners(); 
  }

  List<Assistant> getAllAssistants() {
    return _assistantBox.values.toList();
  }

  Future<void> deleteAssistant(int index) async {
    await _assistantBox.deleteAt(index);
    notifyListeners(); 
  }
}