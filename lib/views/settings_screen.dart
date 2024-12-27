import 'dart:developer';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';




class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final settingsModel = Provider.of<SettingsModel>(context, listen: false);
    final currentTime = isStart
        ? settingsModel.defaultShiftStart
        : settingsModel.defaultShiftEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null) {
      if (isStart) {
        settingsModel.defaultShiftStart = picked;
      } else {
        settingsModel.defaultShiftEnd = picked;
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
              // 1) Umschalten: 24h Shift
              SwitchListTile(
                title: const Text('24h-Schicht?'),
                value: settings.is24hShift,
                onChanged: (val) => settings.is24hShift = val,
              ),

              // 2) ShiftSettings (enum) via Radio
              RadioListTile<ShiftSettings>(
                title: const Text('Täglich (daily)'),
                value: ShiftSettings.daily,
                groupValue: settings.shiftSettings,
                onChanged: (val) {
                  if (val != null) settings.shiftSettings = val;
                },
              ),
              RadioListTile<ShiftSettings>(
                title: const Text('Wöchentlich (recurring)'),
                value: ShiftSettings.recurring,
                groupValue: settings.shiftSettings,
                onChanged: (val) {
                  if (val != null) settings.shiftSettings = val;
                },
              ),
              RadioListTile<ShiftSettings>(
                title: const Text('Flexibel (flexible)'),
                value: ShiftSettings.flexible,
                groupValue: settings.shiftSettings,
                onChanged: (val) {
                  if (val != null) settings.shiftSettings = val;
                },
              ),

              // 3) Zeitwahl
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Startzeit'),
                subtitle: Text(
                  settings.defaultShiftStart.format(context),
                ),
                onTap: () => _pickTime(context, true),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Endzeit'),
                subtitle: Text(
                  settings.defaultShiftEnd.format(context),
                ),
                onTap: () => _pickTime(context, false),
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

