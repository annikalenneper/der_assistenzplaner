import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';


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
      body: SingleChildScrollView(
        child: Column(
          children: 
            settingTiles.map((tile) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  tile,
                  Divider(),
                ],
              ),
            ))
          .toList(),
        ),
      ),
    );
  }
}


class ShiftSettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Text('Arbeitszeiten')
    );
  }
}

class TagSettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Text('Besondere Anforderungen')
    );
  }
}

class WorkscheduleSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Text('Dienstpläne')
    );
  }
}

class AvailabilitySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Text('Verfügbarkeiten')
    );
  }
}


class TagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Besondere Anforderungen')),
      body: TagView(false)
    );
  }
}

class TagView extends StatelessWidget {
  final bool selectable;
  TagView(this.selectable);

  @override
  Widget build(BuildContext context) {
    var tags = Provider.of<TagModel>(context).exampleTagsViewList();
    return Padding(
      padding: const EdgeInsets.all(80),
      child: GridView.count(
        crossAxisCount: 6,
        children: tags,        
      ),   
    );
  }
}