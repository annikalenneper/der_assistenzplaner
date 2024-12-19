
import 'dart:developer';
import 'package:der_assistenzplaner/views/shared/stepper.dart';
import 'package:flutter/material.dart';

/// data class for a single step in the stepper
class StepData {
  final String title;
  final String information;
  final Widget Function(Map<String, dynamic> inputs) contentBuilder;

  StepData({
    required this.title,
    this.information = '',
    required this.contentBuilder,
  });
}

/// returns a list of step data for adding a new assistant
List<StepData> addAssistantStepData(){
  final List<StepData> stepData = [];

  final nameInput = StepData(
    title: 'Wie soll deine neue Assistenzkraft heißen?', 
    contentBuilder: (inputs) {
      return TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name der Assistenzkraft',
        ),
        keyboardType: TextInputType.text,
        onChanged: (value) {
          inputs['name'] = value;
          log(inputs.toString());
        },
      );
    },
  );

  final hoursInput = StepData(
    title: 'Wie viele Stunden soll deine Assistenzkraft pro Monat arbeiten?', 
    contentBuilder: (inputs) {
      return TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Vertraglich vereinbarte Stunden',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          inputs['contractedHours'] = double.parse(value);
          log(inputs.toString());
        },
      );
    }
  );

  final assignTags = StepData(
    title: 'Welche Tags soll deine Assistenzkraft haben?', 
    contentBuilder: (inputs) {
      return Text('Hier werden später Tags angezeigt');
    }
  );

  stepData.add(nameInput);
  stepData.add(hoursInput);
  stepData.add(assignTags);
  return stepData;
}

/// returns a list of step data for adding a new shift
List<StepData> addShiftStepData(){
  final List<StepData> stepData = [];

  final startInput = StepData(
  title: 'Wann soll die Schicht beginnen?',
  contentBuilder: (inputs) {
    return StepperTimePicker(
      date: DateTime.now(), 
      onTimeSelected: (selectedTime) {
        inputs['start'] = selectedTime;
        log('Selected start time: ${inputs.toString()}');
        }
      );
    },
  );


  final endInput = StepData(
    title: 'Wann soll die Schicht enden?',
    contentBuilder: (inputs) {
    return StepperTimePicker(
      date: DateTime.now(), 
      onTimeSelected: (selectedTime) {
        inputs['end'] = selectedTime;
        log('Selected end time: ${inputs.toString()}');
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



