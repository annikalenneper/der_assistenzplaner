import 'dart:core';
import 'dart:math';

import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<String> names = [
  'Anna',
  'Bernd',
  'Clara',
  'Ahmed',
  'Eva',
  'Fritz',
  'Gina',
  'Hanna',
  'Ingo',
];

List<Color> colors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
  Colors.amber,
  Colors.teal,
  Colors.indigo,
];

Future<void> addTestAssistants(context) async {
  final assistantModel = Provider.of<AssistantModel>(context, listen: false);
  for (int i = 1; i <= 9; i++) {
    final newAssistant = assistantModel.createAssistant(names[i - 1], 80.0);
    await assistantModel.saveAssistant(newAssistant);
    assistantModel.assignColor(newAssistant.assistantID, colors[i - 1]);
  }
}

Future<void> addCurrentMonthShifts(context) async {
  final shiftModel = Provider.of<ShiftModel>(context, listen: false);
  final now = DateTime.now();
  final int year = now.year;
  final int month = now.month;
  final int daysInMonth = DateTime(year, month + 1, 0).day;
  
  for (int day = 1; day <= daysInMonth; day++) {
    DateTime shiftStart = DateTime(year, month, day, 8, 0);
    DateTime shiftEnd = DateTime(year, month, day, 16, 0);
    Shift newShift = shiftModel.createShift(shiftStart, shiftEnd, null);
    await shiftModel.saveShift(newShift);
  }
}

/// Erstellt zufällige Verfügbarkeiten für die Assistenten und Schichten im aktuellen Monat
Future<void> addTestAvailabilities(context) async {
  final assistantModel = Provider.of<AssistantModel>(context, listen: false);
  final shiftModel = Provider.of<ShiftModel>(context, listen: false);
  final availabilitiesModel = Provider.of<AvailabilitiesModel>(context, listen: false);
  
  // Zufallsgenerator
  final random = Random();
  
  // Alle unbesetzten Schichten holen (fokussiere auf unbesetzte Schichten für Verfügbarkeiten)
  final unscheduledShifts = shiftModel.unscheduledShifts.toList();
  
  // Alle Assistenten holen
  final assistants = assistantModel.assistants.toList();
  
  // Überprüfen, ob Daten zum Erstellen von Verfügbarkeiten vorhanden sind
  if (unscheduledShifts.isEmpty) {
    print('Keine unbesetzten Schichten gefunden für Verfügbarkeiten');
    return;
  }
  
  if (assistants.isEmpty) {
    print('Keine Assistenten gefunden für Verfügbarkeiten');
    return;
  }
  
  // Zähler für erstellte Verfügbarkeiten
  int createdAvailabilities = 0;
  
  // Für jede unbesetzte Schicht
  for (final shift in unscheduledShifts) {
    // Bestimme zufällig, wie viele Assistenten für diese Schicht verfügbar sind (1-3)
    int availableAssistantsCount = random.nextInt(3) + 1; 
    
    // Mische die Assistenten-Liste für zufällige Auswahl
    assistants.shuffle();
    
    // Wähle die ersten 'availableAssistantsCount' Assistenten aus
    for (int i = 0; i < min(availableAssistantsCount, assistants.length); i++) {
      final assistant = assistants[i];
      
      // Erstelle eine Verfügbarkeit für diese Kombination
      final availability = availabilitiesModel.createAvailability(
        shift.shiftID, 
        assistant.assistantID
      );
      
      // Speichere die Verfügbarkeit
      await availabilitiesModel.saveAvailability(availability);
      createdAvailabilities++;
    }
  }
  
  print('Test-Verfügbarkeiten erstellt: $createdAvailabilities');
}