import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/shared/view_containers.dart';


///SettingsScreen
class SettingsScreen extends StatelessWidget {

  final List<Widget> settingTiles = [
    ShiftSettingsTile(),
    TagSettingsTile(),
    WorkscheduleSettings(),
    AvailabilitySettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Einstellungen')),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              for (int i = 0; i < settingTiles.length; i++) 
                Column(
                  children: [
                    settingTiles[i],
                    /// no divider after last tile
                    if (i < settingTiles.length - 1) Divider(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//-----------------SettingsTiles-----------------

class ShiftSettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsBox(title: "Arbeitszeiten");
  }
}

class TagSettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsBox(title: "Besondere Anforderungen");
  }
}

class WorkscheduleSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsBox(title: "Dienstplan");
  }
}

class AvailabilitySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsBox(title: "Verfügbarkeiten");
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