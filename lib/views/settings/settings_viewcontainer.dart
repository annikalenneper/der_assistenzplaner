
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SettingsInfo extends StatelessWidget {
  final String title;
  final String info;
  final String selectedValue;

  const SettingsInfo({super.key, required this.title, required this.info, required this.selectedValue});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Text('Platzhalter')
            ),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  Text(info),
                ],
              ),
            ),
            Text(selectedValue),
          ],
        );
      },
    );
  }
}


class SettingsSelection extends StatelessWidget {
  final List<Widget> settings;
  final VoidCallback onButtonClick;

  const SettingsSelection({super.key, required this.settings, required this.onButtonClick});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: settings.map((setting) {
                  return Expanded(child: setting);
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: onButtonClick,
                child: const Text('Speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

