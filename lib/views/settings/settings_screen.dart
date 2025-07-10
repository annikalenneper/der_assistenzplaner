import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:der_assistenzplaner/views/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:provider/provider.dart';


final settingsIntroText = "Deine Auswahl legt fest, wie deine Schichten im Kalender eingetragen werden. \nDu kannst jederzeit einzelne Schichten im Kalender anpassen oder deine Einstellungen ändern.";

final frequencyTitle = "Frequenz";
final weekdayTitle = "Wochentage";
final timeTitle = "Schichtzeit";
final dueDateTitle = "Verfügbarkeiten";

//----------------- SettingsScreen -----------------

/// main view for the settings management
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        if (settingsModel.currentSetting != null) {
          return SettingsDetailContent(selectedSetting: settingsModel.currentSetting!);
        } else {
          return Center(
            child: Text(
              'Wähle eine Einstellung aus der Sidebar aus',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }
      },
    );
  }
}

//----------------- SettingsDetailContent -----------------

class SettingsDetailContent extends StatelessWidget {
  final String selectedSetting;

  const SettingsDetailContent({
    super.key,
    required this.selectedSetting,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        final controller = SettingsController(settings);
        
        return Column(
          children: [
            // Header-Container bleibt
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSettingContent(selectedSetting, settings, controller, context),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildSettingContent(String selectedSetting, SettingsModel settings, SettingsController controller, BuildContext context) {
    switch (selectedSetting) {
      case 'shift_planning':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Häufigkeit
            Settings(
              title: frequencyTitle,
              selectedValue: 'Deine Assistenzkräfte sind ${settings.formattedShiftFrequency} im Einsatz',
              openEditDialog: () => controller.editFrequency(context),
            ),
            SizedBox(height: 32),
            
            // 2. Wochentage
            Settings(
              title: weekdayTitle,
              selectedValue: 'Die Assistenz kommt an folgenden Tagen: ${(daysOfWeekToString(settings.weekdays))}',
              openEditDialog: () => controller.editWeekdays(context),
            ),
            SizedBox(height: 32),
            
            // 3. Schichtzeiten
            Settings(
              title: timeTitle,
              selectedValue: 'Schichten beginnen normalerweise um ${formatTimeOfDay(settings.shiftStart)} und enden um ${formatTimeOfDay(settings.shiftEnd)}',
              openEditDialog: () => controller.editShiftTimes(context),
            ),
          ],
        );
      case 'availability':
        return Settings(
          title: dueDateTitle, 
          selectedValue: 'Deine Assistenzkräfte können ihre Verfügbarkeiten vom ${settings.availabilitesStartDate}. bis zum ${settings.availabilitesDueDate}. des Monats einreichen.', 
          openEditDialog: () => controller.editAvailabilityDueDate(context),
        );
      default:
        return Center(child: Text('Unbekannte Einstellung'));
    }
  }
}

//----------------- SettingsSidebar -----------------

class SettingsSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Einstellungen',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Zusammengefasste Schichtplanung
                    SettingSidebarCard(
                      settingKey: 'shift_planning',
                      title: 'Schichtplanung',
                      subtitle: 'Häufigkeit, Wochentage und Zeiten für Schichten',
                      icon: Icons.calendar_today,
                      settingsModel: settingsModel,
                    ),
                    // Verfügbarkeiten bleibt separat
                    SettingSidebarCard(
                      settingKey: 'availability',
                      title: 'Verfügbarkeiten',
                      subtitle: 'Zeitraum für Verfügbarkeitsmeldungen',
                      icon: Icons.event_available,
                      settingsModel: settingsModel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//----------------- SettingSidebarCard -----------------

class SettingSidebarCard extends StatelessWidget {
  final String settingKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final SettingsModel settingsModel;

  const SettingSidebarCard({
    super.key,
    required this.settingKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.settingsModel,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = settingsModel.currentSetting == settingKey;

    return Card(
      elevation: isSelected ? 8 : 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer 
          : null,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        selected: isSelected,
        onTap: () {
          settingsModel.currentSetting = settingKey;
        },
      ),
    );
  }
}

//----------------- Settings Component -----------------

class Settings extends StatelessWidget {
  final String title;
  final String selectedValue;
  final VoidCallback openEditDialog;

  const Settings({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.openEditDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: openEditDialog,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Bearbeiten',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedValue,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ],
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

