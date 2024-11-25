import 'package:der_assistenzplaner/workschedules.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:der_assistenzplaner/test_data.dart';


void main() {
  Workschedule workschedule = createTestWorkSchedule();
  initializeDateFormatting().then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => WorkscheduleModel(workschedule),
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
      AssistantsScreen(),
      TagScreen(),
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
            icon: Icon(Icons.label),
            label: 'Besondere Anforderungen',
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

///AssistantsScreen
class AssistantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Assistenzkräfte'),
          Text('Liste der Assistenzkräfte'),
        ] 
      ),
    );
  }
}

//TagScreen
class TagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Besondere Anforderungen'),
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


