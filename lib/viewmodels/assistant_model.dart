import 'dart:developer';
import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/data/repositories/assistant_repository.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/tag.dart';

class AssistantModel extends ChangeNotifier {
  AssistantRepository assistantRepository = AssistantRepository();
  Map<String, Assistant> assistantMap = {}; /// efficient lookup per ID (O(1) instead of O(n))
  Map<String, Color> assistantColorMap = {}; 
  Assistant? currentAssistant;
  
  AssistantModel();

  //----------------- Getter methods -----------------

  Set<Assistant> get assistants => assistantMap.values.toSet();

  String get assistantID => currentAssistant?.assistantID ?? '';
  String get name => currentAssistant?.name ?? '';
  double get contractedHours => currentAssistant?.contractedHours ?? 0.0;
  double get actualHours => currentAssistant?.actualHours ?? 0.0;
  double get deviation => currentAssistant?.deviation ?? 0.0;
  List<Tag> get tags => currentAssistant?.tags ?? [];

  Color? getAssistantColorByID(assistantID) => assistantColorMap['assistantID'];


  //----------------- Setter methods -----------------

  //TO-DO: implement checks for valid input

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

  set tags(List<Tag> tags) {
    currentAssistant?.tags = tags;
    log('AssistantModel: tags set to $tags');
    notifyListeners();
  }
  
  set actualHours(double actualHours) {
    currentAssistant?.actualHours = actualHours;
    log('AssistantModel: actualHours set to $actualHours');
    notifyListeners();
  }

  //----------------- UI methods -----------------
  
  void selectAssistant(String assistantID) {
    if (assistantMap.containsKey(assistantID)) {
      currentAssistant = assistantMap[assistantID];
      log('AssistantModel: selected assistant $currentAssistant');
      notifyListeners();
    } else {
      log('AssistantModel: selectAssistant: assistantID $assistantID not found');
    }
  }

  void deselectAssistant() {
    currentAssistant = null;
    log('AssistantModel: deselected assistant');
    notifyListeners();
  }


  //----------------- Data Manipulation Methods -----------------

  Assistant createAssistant(String name, double contractedHours) {
    return Assistant(name, contractedHours);
  }

  Future<void> saveAssistant(Assistant assistant) async {
    await assistantRepository.saveAssistant(assistant);
    _addAssistantToLocalStructures(assistant);
    notifyListeners(); 
  }

  /// color assignment saved in SharedPreferences, independent from assistant object
  Future<void> assignColor(String assistentID, Color color) async {
    assistantColorMap[assistentID] = color;
    await assistantRepository.saveAssistantColor(assistentID, color);
    notifyListeners();
  }

  Future<void> assignTag(String assistantID, Tag tag) async {
    if (assistantMap.containsKey(assistantID)) {
    assistantMap[assistantID]!.tags.add(tag);
    await assistantRepository.saveAssistant(assistantMap[assistantID]!);
    notifyListeners();
    } else {
      log('AssistantModel: assignTag: assistantID $assistantID not found');
    }
  } 

  Future<void> deleteAssistant(String assistantID) async {
    await assistantRepository.deleteAssistant(assistantID);
    deselectAssistant();
    _removeAssistantFromLocalStructures(assistantID);
    notifyListeners();
  }

  Future<void> deleteAllAssistants() async {
    // Kopie der aktuellen Werte, um ConcurrentModificationError zu vermeiden
    for (var assistant in List<Assistant>.from(assistantMap.values)) {
      await assistantRepository.deleteAssistant(assistant.assistantID);
      _removeAssistantFromLocalStructures(assistant.assistantID);
    }
    assistantMap.clear();
    assistantColorMap.clear();
    deselectAssistant();
    log('AssistantModel: all assistants deleted');
    notifyListeners();
    
  }


  //----------------- Helper Methods -----------------

  void _addAssistantToLocalStructures(Assistant assistant) {
    assistantMap[assistant.assistantID] = assistant;
    log('AssistantModel: _addAssistantToLocalStructures: assistant $assistant added');
  }

  void _removeAssistantFromLocalStructures(String assistantID) {
    if (assistantMap.containsKey(assistantID)) {
      assistantMap.remove(assistantID);
    } else {
      log('AssistantModel: _removeAssistantFromLocalStructures: assistantID $assistantID not found');
    }
  }
  

  //----------------- Initializaton Methods -----------------

  /// loads all assistants from database, creates a map of assistantID to color and assigns it to assistantMap property
  Future<void> init() async {
    final assistants = await _loadAssistants();
    _loadAssistantColors();
    assistantMap = {
      for (var assistant in assistants) assistant.assistantID: assistant
    };
    log('AssistantModel: initialized');
  }

  Future<Set<Assistant>> _loadAssistants() async {
    return await assistantRepository.fetchAllAssistants();
  }
  
  Future<void> _loadAssistantColors() async {
    assistantColorMap = await assistantRepository.fetchAssistantColorMap();
    log('AssistantModel: assistantColorMap geladen: $assistantColorMap');
  }

}