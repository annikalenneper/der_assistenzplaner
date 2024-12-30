import 'dart:developer';
import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/data/repositories/assistant_repository.dart';
import 'package:der_assistenzplaner/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/tag.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssistantModel extends ChangeNotifier {
  late Box<Assistant> _assistantBox;
  AssistantRepository assistantRepository = AssistantRepository();
  List<Assistant> assistants = [];
  Map<String, Assistant> assistantMap = {}; /// effizienter Zugriff auf Assistenten per ID (O(1) statt O(n))
  Map<String, Color> assistantColorMap = {}; 
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
  


  ///TO-DO: implement removeTag(Tag tag) method


  //----------------- Data Manipulation Methods -----------------


  Future<void> saveNewAssistant(Assistant newAssistant) async {
    await assistantRepository.saveNewAssistant(newAssistant);
    log('Assistant saved to database: $newAssistant');
    notifyListeners(); 
  }

  Future<void> assignColor(String assistentID, Color color) async {
    assistantColorMap[assistentID] = color;
    await assistantRepository.saveAssistantColor(assistentID, color);
    log('AssistantModel: assigned color $color to assistant $assistentID');
    notifyListeners();
  }
  
  void addNote(String title, String text) {
    if (currentAssistant == null) {
      log('currentAssistant is null');
    } else {
      currentAssistant!.notes.add(Note(title, text));
      assistantRepository.saveAssistantNote(currentAssistant!.assistantID, currentAssistant!.notes.last);
    }
  } 
    

  void removeNotebyIndex(int index) {
    if (currentAssistant == null) {
      log('currentAssistant is null');
    } else if (index < 0 || index >= currentAssistant!.notes.length) {
      log('Index $index out of bounds for notes list.');
    } else {
      currentAssistant!.notes.removeAt(index);
    } 
  }

  void assignTag(Tag tag) {
    if (currentAssistant == null) {
      log('currentAssistant is null');
    } else if (currentAssistant!.tags.contains(tag)) {
      log('Tag $tag bereits zugeordnet.');
    } else {
      currentAssistant!.tags.add(tag);
    }
  } 

  Future<void> deleteAssistant() async {
    if (currentAssistant != null) {
      await assistantRepository.deleteAssistant(currentAssistant!.assistantID);
      notifyListeners();
    } else {
      log('AssistantModel: currentAssistant is null');
    }
  }

  //----------------- Initializaton Methods -----------------

  Future<void> initialize() async {
    _loadAssistants();
    _loadAssistantColors();
    assistantMap = {
      for (var assistant in assistants) assistant.assistantID: assistant
    };
    log('AssistantModel: initialized');
  }

  Future<void> _loadAssistants() async {
    assistants = await assistantRepository.fetchAllAssistants();
    log('AssistantModel: assistants lists loaded: $assistants');
    notifyListeners();
  }
  
  Future<void> _loadAssistantColors() async {
    assistantColorMap = await assistantRepository.fetchAssistantColorMap();
    log('AssistantModel: assistantColorMap geladen: $assistantColorMap');
    notifyListeners();
  }

}