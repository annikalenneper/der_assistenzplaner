
import 'package:flutter/material.dart';

enum RowOrColumn { row, column }

class Settings extends StatefulWidget {
  final List<Widget> settings;
  final RowOrColumn alignment = RowOrColumn.row;
  final VoidCallback onSaved;

  Settings({super.key, required this.settings, alignment, required this.onSaved});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: widget.settings,
        ),
        ElevatedButton(
          onPressed: widget.onSaved,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

/// displays multiple dropDownMenus for corresponding settings
class SettingsBox extends StatelessWidget {
  final String title;
  final List<Widget> settings;

  const SettingsBox({super.key, required this.title, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(title),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: settings.map((setting) {
                  return Expanded(child: setting);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

