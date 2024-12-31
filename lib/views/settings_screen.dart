import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// set time in settings model when user picks one
  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final settingsModel = Provider.of<SettingsModel>(context, listen: false);
    final currentTime = isStart? settingsModel.customShiftStart : settingsModel.customShiftEnd;
    final picked = await showTimePicker(context: context, initialTime: currentTime);
    if (picked != null) {
      if (isStart) {
        settingsModel.customShiftStart = picked;
      } else {
        settingsModel.customShiftEnd = picked;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              Text('Wie regelmäßig findet deine Assistanz statt?', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ShiftFrequency>(
                      title: const Text('Meine Assistenz findet täglich statt'),
                      value: ShiftFrequency.daily,
                      groupValue: settings.shiftFrequency,
                      onChanged: (val) => settings.updateShiftFrequency(val!),
                    ),
                  ),            
                  Expanded(
                    child: RadioListTile<ShiftFrequency>(
                      title: const Text('Ich habe regelmäßige Schichten (z.B. 4x pro Woche)'),
                      value: ShiftFrequency.recurring,
                      groupValue: settings.shiftFrequency,
                      onChanged: (val) => settings.updateShiftFrequency(val!)
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ShiftFrequency>(
                      title: const Text('Meine Schichten sind flexibel'),
                      value: ShiftFrequency.flexible,
                      groupValue: settings.shiftFrequency,
                      onChanged: (val) => settings.updateShiftFrequency(val!)
                    ),
                  ),
                ],
              ),

              Text('An welchen Tagen findet deine Assistanz statt?', style: Theme.of(context).textTheme.titleLarge),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                children: List.generate(7, (index) {
                  /// index 0 = Monday, index 6 = Sunday
                  final day = index + 1;
                  return Row(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Checkbox(
                        value: settings.isWeekdaySelected(day),
                        onChanged: (bool? val) {
                          if (val == true) {
                            settings.toggleWeekday(day);
                          } else {
                            settings.deselectWeekday(day);
                          }
                        },
                      ),
                      Text(dayOfWeekToString(day), style: Theme.of(context).textTheme.bodyLarge,), 
                    ],
                  );
                }),
              ),
              

              Text('Findet deine Assistenz rund um die Uhr statt? (24-Stunden-Schichten)', style: Theme.of(context).textTheme.titleLarge,),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Ja'),
                      value: true,
                      groupValue: settings.allShiftsAre24hShifts,
                      onChanged: (val) {
                        if (val != null) settings.allShiftsAre24hShifts = val;
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Nein'),
                      value: false,
                      groupValue: settings.allShiftsAre24hShifts,
                      onChanged: (val) {
                        if (val != null) settings.allShiftsAre24hShifts = val;
                      },
                    ),
                  ),
                  Spacer()
                ],
              ),

              Text('Wann beginnt und endet eine Schicht normalerweise?', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Startzeit'),
                      subtitle: Text(
                        settings.customShiftStart.format(context),
                      ),
                      onTap: () => _pickTime(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Endzeit'),
                      subtitle: Text(
                        settings.customShiftEnd.format(context),
                      ),
                      onTap: () => _pickTime(context, false),
                    ),
                  ),
                  Spacer()
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}


//-----------------Tags-----------------

class TagGridView extends StatelessWidget {
  TagGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = Provider.of<TagModel>(context).exampleTagsViewList();
    return GridView.count(
        crossAxisCount: 7,
        children: tags,        
    );
  }
}

