
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:der_assistenzplaner/views/settings/settings_viewcontainer.dart';
import 'package:flutter/material.dart';


///----------------- Setting Titles -----------------

const frequencyTitle = 'Wie regelmäßig findet deine Assistanz statt?';
const daysOfWeekTitle = 'An welchen Tagen findet deine Assistanz statt?';
const shiftTimesTitle = 'Wann beginnt und endet eine Schicht normalerweise?';


///----------------- Setting Options -----------------

const frequencyOptions = [
  'Meine Schichten finden täglich rund um die Uhr statt (24h-Modell)',
  'Meine Schichten finden täglich statt',
  'Meine Schichten finden an bestimmten Wochentagen statt',
  'Meine Schichten finden immer unterschiedlich statt (flexibel)',
];


const daysOfWeekOptions = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

List<RadioListTile> _generateFrequencyOptions() {
  return frequencyOptions.map((option) {
    return RadioListTile(
      title: Text(option),
      value: option,
      groupValue: option,
      onChanged: (val) => val,
    );
  }).toList();
}

