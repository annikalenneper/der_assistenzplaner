import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:der_assistenzplaner/views/settings/settings_controller.dart';
import 'package:der_assistenzplaner/views/settings/settings_components.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),

      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {

          final settingsIntroText = "Deine Auswahl legt fest, wie deine Schichten im Kalender eingetragen werden. \nKeine Sorge, du kannst jederzeit einzelne Schichten im Kalender anpassen oder deine Einstellungen ändern.";

          final frequencyTitle = "Frequenz";
          final weekdayTitle = "Wochentage";
          final timeTitle = "Schichtzeit";

          final controller = SettingsController(settings);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(40),
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    settingsIntroText, 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                
                      Settings(
                        title: frequencyTitle,
                        selectedValue: controller.getFrequencyOption(
                          settings.selectedFrequencyKey),
                        openEditDialog: () => controller.editFrequency(context),
                      ),
                
                      Divider(),
                
                      Settings(
                        title: weekdayTitle,
                        selectedValue: 'Die Assistenz kommt an folgenden Tagen: ${(daysOfWeekToString(settings.weekdays))}',
                        openEditDialog: () => controller.editWeekdays(context),
                      ),
                
                      Divider(),
                
                      Settings(
                        title: timeTitle,
                        selectedValue: 'Schichten beginnen normalerweise um ${formatTimeOfDay(settings.shiftStart)} und enden um ${formatTimeOfDay(settings.shiftEnd)}',
                        openEditDialog: () => controller.editShiftTimes(context),
                      ),

                      SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            ],   
          );
        },
      ),
    );
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

