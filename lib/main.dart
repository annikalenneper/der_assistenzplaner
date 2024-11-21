import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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

  final List<Widget> pages = [
    WorkScheduleScreen(),
    AssistantsScreen(),
    TagScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
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
    return Center(
      child: Column(
        children: [
          Text('Monat'),
          Text('Dienstplan'),       
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


