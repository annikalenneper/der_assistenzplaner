
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';


///----------------- Setting Options -----------------

class SettingsController {
  final SettingsModel settingsmodel;

  const SettingsController(this.settingsmodel);

  static const _frequencyOptions = {
    1 : 'Schichten finden täglich rund um die Uhr statt (24h-Modell)',
    2 : 'Schichten finden täglich statt, aber nicht durchgängig (weniger als 24h)',
    3 : 'Schichten finden an bestimmten Wochentagen statt',
    4 : 'Schichten finden immer unterschiedlich statt (flexibel)',
  };

  static const _availabilityDueDateOptions = {
    1 : 'Zum Monatsbeginn (1. des Vormonats)',
    2 : 'Zur Monatsmitte (15. des Vormonats)',
    3 : 'Zum Monatsende: (21. des Vormonats)',
  };

  ///----------------- Shift Frequency -----------------

 Future<void> editFrequency(BuildContext context) async {
  int tempFrequencyKey = settingsmodel.selectedFrequencyKey; // Temporäre Variable

  await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Frequenz bearbeiten'),
        content: StatefulBuilder( // Ermöglicht UI-Updates innerhalb des Dialogs
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: _frequencyOptions.entries.map((option) {
                return RadioListTile<int>(
                  title: Text(option.value),
                  value: option.key,
                  groupValue: tempFrequencyKey,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        tempFrequencyKey = val; // UI sofort aktualisieren
                      });
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Änderungen verwerfen
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              settingsmodel.saveShiftFrequencyByKey(tempFrequencyKey); // Speichern mit neuer Methode
              Navigator.pop(context);
            },
            child: Text('Speichern'),
          ),
        ],
      );
    },
  );
}




  ///----------------- Days of the Week -----------------
  
  void editWeekdays(BuildContext context) {
    List<int> tempWeekdays = List.from(settingsmodel.weekdays); 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
          title: Text('Wochentage auswählen'),
          content: StatefulBuilder( 
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List<int>.generate(7, (index) => index + 1).map((day) {
                  return Row(
                    children: [
                      Checkbox(
                        value: tempWeekdays.contains(day), 
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              insertSorted(tempWeekdays, day, (a, b) => a.compareTo(b));
                            } else {
                              tempWeekdays.remove(day);
                            }
                          });
                        },
                      ),
                      Text(dayOfWeekToString(day)),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                settingsmodel.saveWeekdays(tempWeekdays.toSet()); 
                Navigator.pop(context);
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }



  ///----------------- Shift Times -----------------
  
  void editShiftTimes(BuildContext context) {
    TimeOfDay tempStartTime = settingsmodel.shiftStart;
    TimeOfDay tempEndTime = settingsmodel.shiftEnd;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Schichtzeiten bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Startzeit'),
                    subtitle: Text('${formatTimeOfDay(tempStartTime)} Uhr'),
                    onTap: () => pickTime(
                      context: context, 
                      initialTime: tempStartTime, 
                      onTimeSelected: (picked) {
                        setState(() {
                          tempStartTime = picked; 
                        });
                      },
                    ),
                  );
                },
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Endzeit'),
                    subtitle: Text('${formatTimeOfDay(tempEndTime)} Uhr'),
                    onTap: () => pickTime(
                      context: context, 
                      initialTime: tempEndTime, 
                      onTimeSelected: (picked) {
                        setState(() {
                          tempEndTime = picked; 
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                settingsmodel.saveShiftTimes(tempStartTime, tempEndTime); 
                Navigator.pop(context);
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }



  ///----------------- Availabilities -----------------
  
  Future<void> editAvailabilityDueDate(BuildContext context) async {
    int tempAvailabilityDueDate = settingsmodel.availabilitesDueDate; 

    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bis wann sollen deine Assistenzkräfte ihre Verfügbarkeiten spätestens einreichen?'),
          content: StatefulBuilder( 
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _availabilityDueDateOptions.entries.map((option) {
                  return RadioListTile<int>(
                    title: Text(option.value),
                    value: option.key,
                    groupValue: tempAvailabilityDueDate,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempAvailabilityDueDate = val; 
                        });
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                settingsmodel.saveAvailabilitiesDueDate(tempAvailabilityDueDate); 
                Navigator.pop(context);
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }
}