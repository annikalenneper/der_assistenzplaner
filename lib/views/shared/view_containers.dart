import 'package:der_assistenzplaner/views/shared/user_input_widgets.dart';
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

/// generic pop up window 
class PopUpBox extends StatelessWidget {
  final Widget view;
  const PopUpBox({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        child: view
      ),
    );
  }
}
