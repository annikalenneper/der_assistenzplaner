
import 'dart:developer';
import 'package:der_assistenzplaner/styles.dart';
import 'package:der_assistenzplaner/views/shared/user_input_widgets.dart';
import 'package:flutter/material.dart';

/// data class for a single step in the stepper
class StepData {
  final String title;
  final String information;
  final String inputKey;
  final Widget Function(Map<String, dynamic> inputs) contentBuilder;

  StepData({
    required this.title, 
    this.information = '', 
    required this.inputKey,
    required this.contentBuilder});
}

/// returns a list of step data for adding a new assistant
List<StepData> addAssistantStepData(){
  final List<StepData> stepData = [];

  final nameInput = StepData(
    title: 'Wie soll deine neue Assistenzkraft heißen?', 
    inputKey: 'name',
    contentBuilder: (saveInput) {
      return TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name der Assistenzkraft',
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bitte geben Sie einen Namen ein';
          }
          return null;
        },
        onSaved: (value) {
          saveInput('name', value);
        },
      );
    },
  );

  final hoursInput = StepData(
    title: 'Wie viele Stunden soll deine Assistenzkraft pro Monat arbeiten?', 
    inputKey: 'contractedHours',
    contentBuilder: (saveInput) {
      return TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Vertraglich vereinbarte Stunden',
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bitte geben Sie die Stunden ein';
          }
          if (double.tryParse(value) == null) {
            return 'Bitte geben Sie eine gültige Zahl ein';
          }
          return null;
        },
        onSaved: (value) {
          saveInput('contractedHours', double.parse(value!));
        },
      );
    }
  );

  final assignColor = StepData(
    title: 'Welche Farbe möchtest du deiner Assistenzkraft zuordnen?',
    inputKey: 'color',
    contentBuilder: (saveInput) {
      String selectedColor = ModernBusinessTheme.assistantColors[0]['color']; 

      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              DropDownColorPicker(
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
              // Verstecktes FormField zum Speichern der ausgewählten Farbe
              FormField<String>(
                initialValue: selectedColor,
                builder: (FormFieldState<String> state) {
                  return Container(
                    height: 0,
                    width: 0,
                    child: null,
                  );
                },
                onSaved: (value) {
                  saveInput('color', selectedColor);
                },
              ),
            ],
          );
        },
      );
    },
  );

  stepData.add(nameInput);
  stepData.add(hoursInput);
  stepData.add(assignColor);
  return stepData;
}


/// returns a list of step data for adding a new shift
List<StepData> addShiftStepData(selectedDay){
  final List<StepData> stepData = [];

  final startInput = StepData(
    title: 'Wann soll die Schicht beginnen?',
    contentBuilder: (inputs) {
      return CustomTimePicker(
        initialTime: TimeOfDay.now(),
        onTimeChanged: (selectedTime) {
          var shiftStart = DateTime(
            selectedDay.year, 
            selectedDay.month, 
            selectedDay.day, 
            selectedTime.hour, 
            selectedTime.minute);
          inputs['start'] = shiftStart;
        }  
      );
    },
  );

  final endInput = StepData(
    title: 'Wann soll die Schicht enden?',
    contentBuilder: (inputs) {
      return CustomTimePicker(
        initialTime: TimeOfDay.now(),
        onTimeChanged: (selectedTime) {
          inputs['end'] = DateTime(selectedDay, selectedTime.hour, selectedTime.minute);
        } 
      );
    },
  );

  final assignTags = StepData(
    title: 'Gibt es besondere Anforderungen für diese Schicht?', 
    contentBuilder: (inputs) {
      return Text('Hier werden später Tags angezeigt');
    }
  );

  stepData.add(startInput);
  stepData.add(endInput);
  return stepData;
}



