import 'dart:developer';

import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/tag.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:der_assistenzplaner/views/settings_screen.dart';
import 'package:der_assistenzplaner/views/workschedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/views/assistant_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:der_assistenzplaner/views/documents_screen.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// initialize Hive database
  await Hive.initFlutter();
  Hive.registerAdapter(AssistantAdapter());
  Hive.registerAdapter(ShiftAdapter());
  Hive.registerAdapter(TagAdapter());
  //Hive.registerAdapter(NoteAdapter());

  /// initialize models 
  final assistantModel = AssistantModel();
  final tagModel = TagModel();
  final workscheduleModel = WorkscheduleModel();

  /// load data
  await assistantModel.initialize();
  await tagModel.initialize();
  
  
  /// initialize date formatting and make providers available before running the app
  initializeDateFormatting().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => tagModel,
          ),
          ChangeNotifierProvider(
            create: (_) => workscheduleModel,
          ),
          ChangeNotifierProvider(
            create: (_) => assistantModel,
          ),
          
        ],
    
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Der Assistenzplaner',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink),
        
      ),
      home: HomeScreen(),
      routes: {
          '/assistantScreen': (context) => HomeScreen(initialPageIndex: 1),
        },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int initialPageIndex;
  const HomeScreen({this.initialPageIndex = 0, super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  /// key for the inner scaffold (drawer)
  final GlobalKey<ScaffoldState> _drawerScaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    /// initial page index set to calendar/ workschedule
    _currentPageIndex = widget.initialPageIndex; 
  }

  /// list of screens to be displayed via navigation bar
  @override
  Widget build(BuildContext context) {
    final pages = [
      WorkScheduleScreen(),
      AssistantScreen(),
      DocumentsScreen(),
      SettingsScreen()
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        /// responsive design: switch between wide and normal container
        return constraints.maxWidth >= 600 
          ? _buildForWideScreens(pages)
          : _buildForNarrowScreens(pages);
      },
    );
  }

  /// narrow screen uses bottom navigation bar, wide screen uses navigation rail
  Widget _buildForNarrowScreens(List<Widget> pages) {
    log("HomeScreen build: narrow screen");
    return Scaffold(
      appBar: AppBar(
        title: Text('Der Assistenzplaner'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Dienstplan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Assistenzkräfte',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_copy),
            label: 'Dokumente',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
      body: pages[_currentPageIndex],
    );
  }

 Widget _buildForWideScreens(List<Widget> pages) {
  log("HomeScreen build: wide screen");
  return Scaffold(
    body: Row(
      children: [
        NavigationRail(
          selectedIndex: _currentPageIndex,
          groupAlignment: -1.0,
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
              /// open drawer if settings page is selected
              if (_currentPageIndex == 3) {
                _drawerScaffoldKey.currentState?.openDrawer(); 
              } else {
                _drawerScaffoldKey.currentState?.closeDrawer();
              }
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.calendar_today),
              label: Text('Dienstplan'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Assistenzkräfte'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.file_copy),
              label: Text('Dokumente'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Einstellungen'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        /// inner scaffold for the selected page
        Expanded(
          child: Scaffold(
            /// key for the inner scaffold
            key: _drawerScaffoldKey,
            drawer: SizedBox(
              width: 250,
              child: const Drawer(
                child: SettingsDrawer(),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: pages[_currentPageIndex],
            ),
          ),
        ),
      ],
    ),
  );
}
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const DrawerHeader(
          child: Text('Einstellungen'),
        ),
        ListTile(
          title: const Text('Schichten'),
          onTap: () {
            /// TO-DO: navigate to shift settings
          },
        ),
        ListTile(
          title: const Text('Besondere Anforderungen'),
          onTap: () {
            /// TO-DO: navigate to tag settings
          },
        ),
        ListTile(
          title: const Text('Dienstpläne'),
          onTap: () {
            ///
          },
        ),
        ListTile(
          title: const Text('Weitere Einstellungen'),
          onTap: () {
            ///
          },
        ),
      ],
    );
  }
}


