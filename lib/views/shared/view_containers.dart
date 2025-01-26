
import 'package:flutter/material.dart';


/// displays multiple dropDownMenus for corresponding settings
class SettingsBox extends StatelessWidget {
  final String title;
  final List<Widget> settings;

  const SettingsBox({super.key, required this.title, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
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

