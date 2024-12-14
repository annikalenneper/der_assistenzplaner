import 'package:flutter/material.dart';

class SettingsBox extends StatelessWidget {
  final String title;
  final Widget? settings;
  const SettingsBox({super.key, required this.title, this.settings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(title),
        )
      )
    );
  }
}