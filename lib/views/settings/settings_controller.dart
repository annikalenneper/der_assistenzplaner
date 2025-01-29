
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';


///----------------- Setting Options -----------------

class SettingsController {
  final SettingsModel settingsmodel;

  const SettingsController(this.settingsmodel);

  ///----------------- Shift Frequency -----------------

  static const _frequencyOptions = {
    1 : 'Meine Schichten finden täglich rund um die Uhr statt (24h-Modell).',
    2 : 'Meine Schichten finden täglich statt, aber nicht durchgängig (weniger als 24h).',
    3 : 'Meine Schichten finden an bestimmten Wochentagen statt.',
    4 : 'Meine Schichten finden immer unterschiedlich statt (flexibel).',
  };

  Future<void> editFrequency(BuildContext context) async {
    final selectedOption = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Frequenz bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _generateFrequencyRadioTiles()
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                settingsmodel.saveShiftFrequency(settingsmodel.shiftFrequency);
                Navigator.pop(context);
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
    if (selectedOption != null) {
      _setFrequencyOptions(selectedOption);
    }
  }

  String getFrequencyOption(int key) => _frequencyOptions[key] ?? 'Etwas ist schiefgegangen';

  void _setFrequencyOptions(int option) {
    switch (option) {
      case 1 :
        settingsmodel.shiftFrequency = ShiftFrequency.daily;
        settingsmodel.shiftDuration24h = true;
      case 2 :
        settingsmodel.shiftFrequency = ShiftFrequency.daily;
        settingsmodel.shiftDuration24h = false;
      case 3 :
        settingsmodel.shiftFrequency = ShiftFrequency.recurring;
        settingsmodel.shiftDuration24h = false;
      case 4 :
        settingsmodel.shiftFrequency = ShiftFrequency.flexible;
        settingsmodel.shiftDuration24h = false;
    }
  }

  List<RadioListTile<int>> _generateFrequencyRadioTiles() {
    var selectedOption = settingsmodel.selectedFrequencyKey;
    return _frequencyOptions.entries.map((entry) {
      return RadioListTile<int>(
        title: Text(entry.value), 
        value: entry.key, 
        groupValue: selectedOption,
        onChanged: (val) => (val!=null) ? _setFrequencyOptions(val) : null,
      );
    }).toList();
  }



  ///----------------- Days of the Week -----------------
  
  void editWeekdays(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
          title: Text('Wochentage auswählen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _generateWeekdayOptions(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                settingsmodel.saveWeekdays(settingsmodel.weekdays);
                Navigator.pop(context);
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _generateWeekdayOptions() {
    final weekdayKeys = List<int>.generate(7, (index) => index + 1);
    return weekdayKeys.map((day){
      return Row(
        children:[ 
          Checkbox(
            value: settingsmodel.isWeekdaySelected(day), 
            onChanged: (val) => (val!) 
              ? settingsmodel.weekdays.add(day) 
              : settingsmodel.weekdays.remove(day)
          ),
          Text(dayOfWeekToString(day)),
        ]
      );
    }).toList();
  }


  ///----------------- Shift Times -----------------
  
  void editShiftTimes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Schichtzeiten bearbeiten'),
          content: ListBody(children:_generateShiftTimeOptions(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                settingsmodel.saveShiftTimes(settingsmodel.shiftStart, settingsmodel.shiftEnd);
                Navigator.pop(context);
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _generateShiftTimeOptions(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Startzeit'),
        subtitle: Text(settingsmodel.shiftStart.toString()),
        onTap: () => pickTime(
          context: context, 
          initialTime: settingsmodel.shiftStart, 
          onTimeSelected: (picked) => settingsmodel.shiftStart = picked
        ),
      ),
      ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Endzeit'),
        subtitle: Text(settingsmodel.shiftEnd.toString()),
        onTap: () => pickTime(
          context: context, 
          initialTime: settingsmodel.shiftEnd, 
          onTimeSelected: (picked) => settingsmodel.shiftEnd = picked
        ),
      ),
    ];
  }
}