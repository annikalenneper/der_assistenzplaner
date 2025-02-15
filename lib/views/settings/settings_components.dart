
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


final settingsIntroText = "Deine Auswahl legt fest, wie deine Schichten im Kalender eingetragen werden. \nDu kannst jederzeit einzelne Schichten im Kalender anpassen oder deine Einstellungen ändern.";

final frequencyTitle = "Frequenz";
final weekdayTitle = "Wochentage";
final timeTitle = "Schichtzeit";
final dueDateTitle = "Verfügbarkeiten";



class Settings extends StatefulWidget {
  final String title;
  final String selectedValue;
  final void Function() openEditDialog;

  const Settings({
    super.key, 
    required this.title, 
    required this.selectedValue, 
    required this.openEditDialog,
  });

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  SettingsState();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: TextStyle(fontSize: 20)),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: widget.openEditDialog,
                      ),
                      SizedBox(width: 5),
                      Text(widget.selectedValue),             
                    ]
                  )
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SettingsBox extends StatelessWidget {
  final String category;
  final List<Settings> children;

  const SettingsBox({super.key, required this.category, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView(
        children: [
          Text(category, style: TextStyle(fontSize: 24)),
          Column(
            children: children,
          ),
        ],
      ),
    );
  }
}
