import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:der_assistenzplaner/views/workschedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/views/assistant_screen.dart';
import 'package:der_assistenzplaner/views/settings_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:der_assistenzplaner/viewmodels/tag_model.dart';
import 'package:der_assistenzplaner/views/documents_screen.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(AssistantAdapter());

  final assistantModel = AssistantModel();
  await assistantModel.initialize();

  final tagModel = TagModel();
  await tagModel.initialize();

  final workscheduleModel = WorkscheduleModel();
  
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
    final assistantModel = Provider.of<AssistantModel>(context);
    return MaterialApp(
      title: 'Der Assistenzplaner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink),
      ),
      home: HomeScreen(),
      /// routes for navigation without stack
      routes: {
        '/assistantScreen': (context) => HomeScreen(initialPageIndex: 1),
        '/documentsScreen': (context) => HomeScreen(initialPageIndex: 2), 
        '/settingsScreen': (context) => HomeScreen(initialPageIndex: 3),
        '/assistantAddScreen': (context) => AssistantAddScreen(),
        '/assistantDetails': (context) => AssistantDetails(assistantModel),
      }
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
  late int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex; // Initialen Index setzen
  }

  @override
  Widget build(BuildContext context) {

    final pages = [
      WorkScheduleScreen(),
      AssistantScreen(),
      DocumentsScreen(),
      SettingsScreen()
    ];

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
}


