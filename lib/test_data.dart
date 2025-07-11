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

/// Erstellt Verfügbarkeiten assistentenweise mit 8-12 zufälligen Angaben pro Assistenz
Future<void> addTestAvailabilities(context) async {
  final assistantModel = Provider.of<AssistantModel>(context, listen: false);
  final shiftModel = Provider.of<ShiftModel>(context, listen: false);
  final availabilitiesModel = Provider.of<AvailabilitiesModel>(context, listen: false);
  
  final random = Random();
  final unscheduledShifts = shiftModel.unscheduledShifts.toList();
  final assistants = assistantModel.assistants.toList();
  
  if (unscheduledShifts.isEmpty) {
    print('Keine unbesetzten Schichten gefunden für Verfügbarkeiten');
    return;
  }
  
  if (assistants.isEmpty) {
    print('Keine Assistenten gefunden für Verfügbarkeiten');
    return;
  }
  
  print('Starte assistentenweise Erstellung von Verfügbarkeiten für ${assistants.length} Assistenten...');
  
  // Für jeden Assistenten
  for (int assistantIndex = 0; assistantIndex < assistants.length; assistantIndex++) {
    final assistant = assistants[assistantIndex];
    
    // Zufällige Anzahl von Verfügbarkeiten für diesen Assistenten (8-12)
    final availabilityCount = random.nextInt(5) + 8; // 8-12
    
    print('📋 ${assistant.name} gibt ${availabilityCount} Verfügbarkeiten ein...');
    
    // Mische die Schichten für zufällige Auswahl
    final shuffledShifts = List<Shift>.from(unscheduledShifts)..shuffle();
    
    // Sammle Verfügbarkeiten für diesen Assistenten
    final availabilitiesForThisAssistant = <dynamic>[];
    
    // Erstelle die gewünschte Anzahl von Verfügbarkeiten
    for (int i = 0; i < min(availabilityCount, shuffledShifts.length); i++) {
      final shift = shuffledShifts[i];
      
      final availability = availabilitiesModel.createAvailability(
        shift.shiftID, 
        assistant.assistantID
      );
      
      availabilitiesForThisAssistant.add(availability);
      
      // Kurze Verzögerung zwischen einzelnen Eingaben (50-150ms)
      await Future.delayed(Duration(milliseconds: random.nextInt(100) + 50));
      
      // Zwischenstatus für realistische Simulation
      if ((i + 1) % 3 == 0) {
        print('   ... ${i + 1}/${availabilityCount} eingegeben');
      }
    }
    
    // Alle Verfügbarkeiten für diesen Assistenten auf einmal speichern
    print('💾 Speichere ${availabilitiesForThisAssistant.length} Verfügbarkeiten für ${assistant.name}...');
    
    for (final availability in availabilitiesForThisAssistant) {
      await availabilitiesModel.saveAvailability(availability);
      
      // Sehr kurze Pause zwischen Speichervorgängen (20-50ms)
      await Future.delayed(Duration(milliseconds: random.nextInt(30) + 20));
    }
    
    print('✅ ${assistant.name} fertig (${availabilitiesForThisAssistant.length} Verfügbarkeiten gespeichert)');
    
    // Pause zwischen Assistenten (300-800ms)
    if (assistantIndex < assistants.length - 1) {
      final pauseMs = random.nextInt(500) + 300;
      print('⏳ Warte ${pauseMs}ms bis zum nächsten Assistenten...\n');
      await Future.delayed(Duration(milliseconds: pauseMs));
    }
  }
  
  print('🎉 Alle Verfügbarkeiten für ${assistants.length} Assistenten erstellt!');
}

/// Alternative Version mit längeren Wartezeiten für Demo-Zwecke
Future<void> addTestAvailabilitiesSlowDemo(context) async {
  final assistantModel = Provider.of<AssistantModel>(context, listen: false);
  final shiftModel = Provider.of<ShiftModel>(context, listen: false);
  final availabilitiesModel = Provider.of<AvailabilitiesModel>(context, listen: false);
  
  final random = Random();
  final unscheduledShifts = shiftModel.unscheduledShifts.toList();
  final assistants = assistantModel.assistants.toList();
  
  if (unscheduledShifts.isEmpty || assistants.isEmpty) {
    print('Keine Daten für Verfügbarkeiten vorhanden');
    return;
  }
  
  print('🎬 Demo: Langsame assistentenweise Erstellung von Verfügbarkeiten...');
  
  for (int assistantIndex = 0; assistantIndex < assistants.length; assistantIndex++) {
    final assistant = assistants[assistantIndex];
    final availabilityCount = random.nextInt(5) + 8; // 8-12
    
    print('📋 ${assistant.name} beginnt mit der Eingabe von ${availabilityCount} Verfügbarkeiten...');
    
    final shuffledShifts = List<Shift>.from(unscheduledShifts)..shuffle();
    final availabilitiesForThisAssistant = <dynamic>[];
    
    // Eingabe-Phase mit längeren Verzögerungen
    for (int i = 0; i < min(availabilityCount, shuffledShifts.length); i++) {
      final shift = shuffledShifts[i];
      
      final availability = availabilitiesModel.createAvailability(
        shift.shiftID, 
        assistant.assistantID
      );
      
      availabilitiesForThisAssistant.add(availability);
      
      print('   📝 ${assistant.name}: Verfügbarkeit ${i + 1}/${availabilityCount} für ${shift.start.day}.${shift.start.month}');
      
      // Längere Verzögerung für Demo (200-500ms)
      await Future.delayed(Duration(milliseconds: random.nextInt(300) + 200));
    }
    
    // "Absenden"-Phase
    print('📤 ${assistant.name} sendet ${availabilitiesForThisAssistant.length} Verfügbarkeiten ab...');
    await Future.delayed(Duration(milliseconds: 500)); // Kurze "Absende"-Pause
    
    // Speichern
    for (final availability in availabilitiesForThisAssistant) {
      await availabilitiesModel.saveAvailability(availability);
      await Future.delayed(Duration(milliseconds: 50));
    }
    
    print('✅ ${assistant.name} fertig! (${availabilitiesForThisAssistant.length} Verfügbarkeiten)');
    
    // Längere Pause zwischen Assistenten für Demo (1-3 Sekunden)
    if (assistantIndex < assistants.length - 1) {
      final pauseSec = random.nextInt(2) + 1;
      print('⏳ Nächster Assistent in ${pauseSec} Sekunden...\n');
      await Future.delayed(Duration(seconds: pauseSec));
    }
  }
  
  print('🎉 Demo abgeschlossen: Alle ${assistants.length} Assistenten haben ihre Verfügbarkeiten eingereicht!');
}

/// Hilfsmethode: Erstellt Verfügbarkeiten nur für bestimmte Assistenten (für Partial-Tests)
Future<void> addTestAvailabilitiesForSpecificAssistants(
  context, 
  List<String> assistantNames
) async {
  final assistantModel = Provider.of<AssistantModel>(context, listen: false);
  final shiftModel = Provider.of<ShiftModel>(context, listen: false);
  final availabilitiesModel = Provider.of<AvailabilitiesModel>(context, listen: false);
  
  final random = Random();
  final unscheduledShifts = shiftModel.unscheduledShifts.toList();
  
  // Filtere nur die gewünschten Assistenten
  final selectedAssistants = assistantModel.assistants
      .where((assistant) => assistantNames.contains(assistant.name))
      .toList();
  
  if (selectedAssistants.isEmpty) {
    print('Keine der angegebenen Assistenten gefunden: $assistantNames');
    return;
  }
  
  print('Erstelle Verfügbarkeiten nur für: ${selectedAssistants.map((a) => a.name).join(', ')}');
  
  for (final assistant in selectedAssistants) {
    final availabilityCount = random.nextInt(5) + 8;
    final shuffledShifts = List<Shift>.from(unscheduledShifts)..shuffle();
    
    print('📋 ${assistant.name}: ${availabilityCount} Verfügbarkeiten...');
    
    for (int i = 0; i < min(availabilityCount, shuffledShifts.length); i++) {
      final availability = availabilitiesModel.createAvailability(
        shuffledShifts[i].shiftID, 
        assistant.assistantID
      );
      
      await availabilitiesModel.saveAvailability(availability);
      await Future.delayed(Duration(milliseconds: random.nextInt(100) + 50));
    }
    
    print('✅ ${assistant.name} fertig');
    await Future.delayed(Duration(milliseconds: random.nextInt(500) + 300));
  }
}