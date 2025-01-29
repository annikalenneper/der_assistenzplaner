
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsInfo extends StatefulWidget {
  final String title;
  final String info;
  final String selectedValue;

  const SettingsInfo({
    super.key, 
    required this.title, 
    required this.info, 
    required this.selectedValue, 
  });

   
  @override
  State<StatefulWidget> createState() => SettingsInfoState();
}

class SettingsInfoState extends State<SettingsInfo> {
  SettingsInfoState();

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
                Text(widget.title),
                SizedBox(width: 60),
                Text(widget.info),     
                Spacer(),     
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => {},
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
