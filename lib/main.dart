import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:der_assistenzplaner/views/workschedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:der_assistenzplaner/test_data.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/views/assistant_screen.dart';



void main() {
  Workschedule workschedule = createTestWorkSchedule();
  Assistant assistant = Assistant('Mona', 120);
  
  initializeDateFormatting().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => WorkscheduleModel(workschedule),
          ),
          ChangeNotifierProvider(
            create: (_) => AssistantModel(assistant),
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
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {

    final pages = [
      WorkScheduleScreen(),
      AssistantScreen(),
      SettingsScreen()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Der Assistenzplaner'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
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
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
      body: pages[currentPageIndex], 
    );
  }
}

///WorkScheduleScreen
class WorkScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workscheduleModel = Provider.of<WorkscheduleModel>(context);
    return Center(
      child: Column(
        children: [
          Text('Dienstplan'),
          WorkScheduleView(wsModel: workscheduleModel),  
        ]
      ),
    );
  }
}

///SettingsScreen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Einstellungen'),
    );
  }
}


