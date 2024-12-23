import 'dart:ui';

import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/styles.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:der_assistenzplaner/views/settings_screen.dart';
import 'package:der_assistenzplaner/views/workschedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/views/assistant_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  /// initialize Hive database
  await Hive.initFlutter();
  Hive.registerAdapter(AssistantAdapter());
  Hive.registerAdapter(ShiftAdapter());
  //Hive.registerAdapter(NoteAdapter());

  /// initialize models 
  final assistantModel = AssistantModel();
  final shiftModel = ShiftModel();
  final workscheduleModel = WorkscheduleModel();

  /// load data
  await assistantModel.initialize();
  await shiftModel.initialize();

  /// initialize date formatting and make providers available before running the app
  initializeDateFormatting().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => workscheduleModel,
          ),
          ChangeNotifierProvider(
            create: (_) => shiftModel,
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

/// stateless widget holds stateful home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Der Assistenzplaner',
      // TO-DO: add theme
      theme: ModernBusinessTheme.themeData,
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = widget.initialTabIndex; 
  }

  /// avoid memory leaks
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        title: Text('Der Assistenzplaner'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Kalender', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Team', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CalendarView(),
          AssistantPage(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                TextButton.icon(onPressed: (){}, label: Text('Dienstplan'), icon: Icon(Icons.add),),
                Spacer(),
                TextButton.icon(onPressed: (){}, label: Text('Downloads'), icon: Icon(Icons.download),)
              ],      
            ),
          ],
        ),      
      ),
    );
  }
}

