import 'dart:ui';
import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/data/models/availability.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/styles/styles.dart';
import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/settings_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/settings/settings_screen.dart';
import 'package:der_assistenzplaner/views/planner/planner_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/views/assistant/assistant_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:der_assistenzplaner/test_data.dart'; // Import hinzugefügt



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  /// initialize Hive database
  await Hive.initFlutter();
  Hive.registerAdapter(AssistantAdapter());
  Hive.registerAdapter(ShiftAdapter());
  Hive.registerAdapter(AvailabilityAdapter());

  /// initialize models 
  final assistantModel = AssistantModel();
  final shiftModel = ShiftModel();
  final settingsModel = SettingsModel();
  final availabilitiesModel = AvailabilitiesModel();

  /// load data
  await assistantModel.init();
  await shiftModel.init();
  await settingsModel.init();
  await availabilitiesModel.init();

  /// initialize date formatting and make providers available before running the app
  initializeDateFormatting().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => shiftModel,
          ),
          ChangeNotifierProvider(
            create: (_) => assistantModel,
          ),
          ChangeNotifierProvider(
            create: (_) => settingsModel,
          ),
          ChangeNotifierProvider(
            create: (_) => availabilitiesModel,
          ),
        ],   
        child: MyApp(),
      ),
    );
  });
}

/// stateless widget holds stateful home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Der Assistenzplaner',
      theme: ModernBusinessTheme.themeData,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('de', 'DE'),
      ],
      home: HomeScreen(),
      routes: {
        '/assistantTab': (context) => HomeScreen(initialTabIndex: 1),
      },
    );
  }
}

/// home screen with tab bar as main navigation
class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  HomeScreen({this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showTeamSidebar = false;
  bool _showSettingsSidebar = false;

  final List<Widget> _pages = [
    CalendarView(),
    AssistantPage(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _showTeamSidebar = _selectedIndex == 1;
    _showSettingsSidebar = _selectedIndex == 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              // Haupt NavigationRail
              Expanded(
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                      _showTeamSidebar = index == 1;
                      _showSettingsSidebar = index == 2;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Kalender'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.group),
                      selectedIcon: Icon(Icons.group),
                      label: Text('Team'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Einstellungen'),
                    ),
                  ],
                ),
              ),
              // Testdaten Buttons
              Container(
                width: 80,
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Divider(),
                    // Button für Assistenten
                    IconButton(
                      tooltip: 'Testassistenten hinzufügen',
                      onPressed: () async {
                        await addTestAssistants(context);
                      },
                      icon: Icon(Icons.person_add),
                      iconSize: 20,
                    ),
                    // Button für Schichten
                    IconButton(
                      tooltip: 'Testschichten hinzufügen',
                      onPressed: () async {
                        await addCurrentMonthShifts(context);
                      },
                      icon: Icon(Icons.schedule),
                      iconSize: 20,
                    ),
                    // Button für Verfügbarkeiten
                    IconButton(
                      tooltip: 'Testverfügbarkeiten hinzufügen',
                      onPressed: () async {
                        await addTestAvailabilities(context);
                      },
                      icon: Icon(Icons.av_timer),
                      iconSize: 20,
                    ),
                    Divider(),
                    // Button für Assistenten löschen
                    IconButton(
                      tooltip: 'Alle Assistenten löschen',
                      onPressed: () async {
                        await Provider.of<AssistantModel>(context, listen: false).deleteAllAssistants();
                      },
                      icon: Icon(Icons.delete),
                      iconSize: 20,
                    ),
                    // Button für Schichten löschen
                    IconButton(
                      tooltip: 'Alle Schichten löschen',
                      onPressed: () async {
                        await Provider.of<ShiftModel>(context, listen: false).deleteAllShifts();
                      },
                      icon: Icon(Icons.delete_sweep),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          if (_showTeamSidebar) ...[
            SizedBox(
              width: 280,
              child: TeamSidebar(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          if (_showSettingsSidebar) ...[
            SizedBox(
              width: 280,
              child: SettingsSidebar(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          Expanded(
            child: Scaffold(
              body: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

