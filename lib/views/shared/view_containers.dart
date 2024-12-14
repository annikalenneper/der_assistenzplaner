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


class PopUpBox extends StatelessWidget {
  final Widget view;
  const PopUpBox({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: view
      ),
    );
  }
}
