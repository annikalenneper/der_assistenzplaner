
import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AssistantRepository {

  //----------------- Fetch data -----------------

  Future<List<Assistant>> fetchAllAssistants() async {
    final assistantBox = await Hive.openBox<Assistant>('assistants');
    return assistantBox.values.toList();
  }

  Future<Map<String, Color>> fetchAssistantColorMap() async {
    final assistantBox = await Hive.openBox<Assistant>('assistants');
    List<Assistant> assistants = assistantBox.values.toList();
    Map<String, Color> assistantColorMap = {};
    for (final assistant in assistants) {
      final color = await SharedPreferencesHelper.loadValue(assistant.assistantID, type: Color);
      if (color != null) {
      assistantColorMap[assistant.assistantID] = color;
      } else {
      assistantColorMap[assistant.assistantID] = Colors.grey;
      }
    }
    return assistantColorMap;
  }

  //----------------- Manipulate Data -----------------

  Future<void> saveNewAssistant(Assistant newAssistant) async {
    final assistantBox = await Hive.openBox<Assistant>('assistants');
    await assistantBox.add(newAssistant);
  }

  Future<void> updateCurrentAssistant(Assistant currentAssistant) async {
    final assistantBox = await Hive.openBox<Assistant>('assistants');
    if (assistantBox.containsKey(currentAssistant.assistantID)) {
      await assistantBox.put(currentAssistant.assistantID, currentAssistant);
    } else {
      await assistantBox.add(currentAssistant);
    }
  }

  Future<void> deleteAssistant(String currentAssistantID) async {
    final assistantBox = await Hive.openBox<Assistant>('assistants');
    await assistantBox.delete((assistant) => assistant.assistantID == currentAssistantID);
  }

  Future<void> saveAssistantColor(String assistantID, Color color) async {
    await SharedPreferencesHelper.saveValue(assistantID, color);
  }

  Future<void> saveAssistantNote(String assistantID, Note note) async {
    final assistantBox = await Hive.openBox<Assistant>('assistants');
    final assistant = assistantBox.values.firstWhere((assistant) => assistant.assistantID == assistantID);
    assistant.notes.add(note);
    await assistantBox.put(assistantID, assistant);
  }
}