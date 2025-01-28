import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';


const shiftFrequencySettingsTitle = Text('Wie regelmäßig findet deine Assistanz statt?');

List<Widget> shiftFrequencySettings() {
  ShiftFrequency selectedShiftFrequency;
  return ShiftFrequency.values.map((frequency) {
    return RadioListTile<ShiftFrequency>(
      title: Text(frequency.toString()),
      value: frequency, groupValue: null,
      onChanged: (val) => (val != null) ? selectedShiftFrequency = val : null,
    );
  }).toList();
}

//final SettingsBox shiftFrequencySettings(shiftFrequencySettingsTitle);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(40),
                  children: [
                
                    Text('Wie regelmäßig findet deine Assistanz statt?', style: Theme.of(context).textTheme.titleLarge),
                    Row(
                      /// create radio buttons for each frequency
                      children: ShiftFrequency.values.map((frequency) {
                        return Flexible(
                          child: RadioListTile<ShiftFrequency>(
                            title: Text(settings.getShiftFrequencyTitle(frequency)),
                            value: frequency,
                            groupValue: settings.shiftFrequency,
                            onChanged: (val) => settings.updateShiftFrequency(val!),
                          ),
                        );
                      }).toList(),
                    ),
                
                    Text('An welchen Tagen findet deine Assistanz statt?', style: Theme.of(context).textTheme.titleLarge),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      /// generate checkboxes for each day of the week (int 1-7)
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        return Row(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            Checkbox(
                              value: settings.isWeekdaySelected(day),
                              onChanged: (val) => settings.toggleWeekday(day),
                            ),
                            Text(dayOfWeekToString(day), style: Theme.of(context).textTheme.bodyLarge,), 
                          ],
                        );
                      }),
                    ),
                
                    Text('Findet deine Assistenz rund um die Uhr statt? (24-Stunden-Schichten)', style: Theme.of(context).textTheme.titleLarge,),
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [true, false].map((is24h) {
                              return Flexible(
                                child: RadioListTile<bool>(
                                  title: Text(is24h ? 'Ja' : 'Nein'),
                                  value: is24h,
                                  groupValue: settings.allShiftsAre24hShifts,
                                  onChanged: (val) => settings.toggle24hShift(val),
                                ),
                              );
                            }).toList(),
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
                            subtitle: Text(''),
                            onTap: () => settings.openShiftStartPicker(context),
                          ),
                        ),
                
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.access_time),
                            title: const Text('Endzeit'),
                            subtitle: Text(''),
                            onTap: () => settings.openShiftEndPicker(context),
                          ),
                        ),
                
                        Spacer()
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), 
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

