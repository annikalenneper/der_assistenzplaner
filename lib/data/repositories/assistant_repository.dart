import 'dart:developer';

import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AssistantRepository {
  const AssistantRepository();

  //----------------- Fetch data -----------------

  Future<List<Assistant>> fetchAllAssistants() async {
    try {
      final assistantBox = await Hive.openBox<Assistant>('assistants');
      final assistants = assistantBox.values.toList();
      if (assistants.isEmpty) {
        log('AssistantRepository: No assistants found in the database.');
      } else {
        log('AssistantRepository: Fetched all assistants.');
      }
      return assistants;
    } catch (e, stackTrace) {
      log('AssistantRepository: Error fetching assistants: $e', stackTrace: stackTrace);
      return []; // Return empty list on failure
    }
  }

  Future<Map<String, Color>> fetchAssistantColorMap() async {
    try {
      final assistantBox = await Hive.openBox<Assistant>('assistants');
      final assistants = assistantBox.values.toList();
      if (assistants.isEmpty) {
        log('AssistantRepository: No assistants found for fetching color map.');
        return {};
      }
      Map<String, Color> assistantColorMap = {};
      for (final assistant in assistants) {
        if (assistant.assistantID.isEmpty) {
          log('AssistantRepository: Skipped assistant with empty assistantID.');
          continue;
        }
        final color = await SharedPreferencesHelper.loadValue(assistant.assistantID, type: Color);
        if (color != null) {
          assistantColorMap[assistant.assistantID] = color;
          log('AssistantRepository: Color found for assistant ${assistant.name} with ID ${assistant.assistantID}');
        } else {
          assistantColorMap[assistant.assistantID] = Colors.grey;
          log('AssistantRepository: Default color assigned for assistant ${assistant.name} with ID ${assistant.assistantID}');
        }
      }
      return assistantColorMap;
    } catch (e, stackTrace) {
      log('AssistantRepository: Error fetching assistant color map: $e', stackTrace: stackTrace);
      return {}; // Return empty map on failure
    }
  }

  //----------------- Manipulate Data -----------------

  /// Saves or updates assistant in database with assistantID as key
  Future<void> saveAssistant(Assistant assistant) async {
    try {
      if (assistant.assistantID.isEmpty) {
        throw Exception('AssistantRepository: assistantID cannot be empty.');
      }
      final assistantBox = await Hive.openBox<Assistant>('assistants');
      await assistantBox.put(assistant.assistantID, assistant);
      log('AssistantRepository: ${assistant.name} saved or updated.');
    } catch (e, stackTrace) {
      log('AssistantRepository: Error saving assistant ${assistant.name}: $e', stackTrace: stackTrace);
    }
  }

  Future<void> deleteAssistant(String assistantID) async {
    try {
      if (assistantID.isEmpty) {
        throw Exception('AssistantRepository: assistantID cannot be empty.');
      }

      final assistantBox = await Hive.openBox<Assistant>('assistants');
      if (assistantBox.containsKey(assistantID)) {
        await assistantBox.delete(assistantID);
        log('AssistantRepository: Assistant with ID $assistantID deleted.');
      } else {
        log('AssistantRepository: Assistant with ID $assistantID not found.');
      }
    } catch (e, stackTrace) {
      log('AssistantRepository: Error deleting assistant with ID $assistantID: $e', stackTrace: stackTrace);
    }
  }

  Future<void> saveAssistantColor(String assistantID, Color color) async {
    try {
      if (assistantID.isEmpty) {
        throw Exception('AssistantRepository: assistantID cannot be empty.');
      }
      await SharedPreferencesHelper.saveValue(assistantID, color);
      log('AssistantRepository: Assigned color $color to assistant $assistantID.');
    } catch (e, stackTrace) {
      log('AssistantRepository: Error saving color for assistantID $assistantID: $e', stackTrace: stackTrace);
    }
  }
}
