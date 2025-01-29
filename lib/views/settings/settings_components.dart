
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                Spacer(),     
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
