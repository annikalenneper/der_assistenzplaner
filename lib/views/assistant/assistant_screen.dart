import 'package:der_assistenzplaner/views/assistant/assistant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'dart:developer';
import 'package:der_assistenzplaner/utils/nav.dart';
import 'package:der_assistenzplaner/views/assistant/assistant_usecases.dart';


//----------------- AssistantPage -----------------

/// main view for the assistant management
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late int _selectedIndex;
  late bool _showTeamSidebar;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _showTeamSidebar = _selectedIndex == 1;
    
    // Wenn Team angezeigt wird, aber kein Assistent ausgewählt ist, setze currentAssistant auf null
    if (_selectedIndex == 1) {
      Future.microtask(() {
        Provider.of<AssistantModel>(context, listen: false).deselectAssistant();
      });
    }
  }

  Widget build(BuildContext context) {
    return Consumer<AssistantModel>(
      builder: (context, assistantModel, child) {
        if (assistantModel.currentAssistant != null) {
          return AssistantDetailView();
        } else {
          return Center(
            child: Text(
              'Wähle eine Assistenzkraft aus der Sidebar aus',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }
      },
    );
  }
}

//----------------- AssistantListView -----------------	

class AssistantListView extends StatefulWidget {
  /// pass callback function from AssistantPage to AssistantListView
  final Function(int) changePageViewIndex;

  const AssistantListView({required this.changePageViewIndex, super.key});

  @override
  State<AssistantListView> createState() => _AssistantListViewState();
}

class _AssistantListViewState extends State<AssistantListView> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantModel>(
      builder: (context, assistantModel, child) {
        return Scaffold(
            body: SizedBox(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: assistantModel.assistants.length,
                          itemBuilder: (context, index) {
                            /// get individual assistants from assistantModel assistants list
                            var assistant = assistantModel.assistants.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                assistantModel.currentAssistant = assistant;
                                /// navigate to AssistantDetailView
                                widget.changePageViewIndex(1);
                              },
                              child: AssistantCard(assistantID: assistant.assistantID,)
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Neue Assistenzkraft hinzufügen'),
                              content: AddAssistantForm(
                                onSave: (name, hours, color) {
                                  final newAssistant = assistantModel.createAssistant(name, hours);
                                  assistantModel.saveAssistant(newAssistant);
                                  assistantModel.assignColor(newAssistant.assistantID, color);
                                },
                              ),
                            );
                          }, 
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}
    


//----------------- AssistantDetailView -----------------

class AssistantDetailView extends StatelessWidget {
  AssistantDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    late AssistantModel assistant = Provider.of<AssistantModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(assistant.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            assistant.deselectAssistant();
            navigateToAssistantScreen(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [ 
            Icon(Icons.person, size: 100),
            Text(assistant.tags.toString()),
            Text(assistant.deviation.toString()),
            ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Warnung!'), 
                  content: SingleChildScrollView(
                     child: ListBody(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text('Alle Daten, die mit der Assistenzkraft zusammenhängen, gehen beim Löschen verloren.'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text('Du kannst die Assistenzkraft stattdessen auch archivieren. Sie ist dann nicht mehr in der Teamübersicht sichtbar, bleibt jedoch im Archiv erhalten.'),
                        )
                      ],
                    )
                  ), 
                  actions: [
                    TextButton(
                      onPressed: () { 
                        assistant.deleteAssistant(assistant.assistantID);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${assistant.name} erfolgreich gelöscht.')),
                        );
                        navigateToAssistantScreen(context);
                      },
                      child: Text('Entgültig löschen')
                    ),
                    TextButton(
                      onPressed: (){},
                      child: Text('Archivieren')
                    )
                  ], 
                ),
              ),       
              child: Text('Löschen'),      
            ),
            ElevatedButton(
              onPressed: () {
                 showDialog(
                  context: context, 
                  builder: (BuildContext context) => Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                        ],
                      ),            
                    ),
                  ),                  
                );
              },
              child: Text('Tag zuordnen')
            ),
          ],
        ),
      ),
    );
  }
}

class TeamSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantModel>(
      builder: (context, assistantModel, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Neue Assistenzkraft hinzufügen'),
                              content: AddAssistantForm(
                                onSave: (name, hours, color) {
                                  final newAssistant = assistantModel.createAssistant(name, hours);
                                  assistantModel.saveAssistant(newAssistant);
                                  assistantModel.assignColor(newAssistant.assistantID, color);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: assistantModel.assistants.length,
                  itemBuilder: (context, index) {
                    var assistant = assistantModel.assistants.elementAt(index);
                    return AssistantSidebarCard(
                      assistantID: assistant.assistantID,
                      onTap: () {
                        assistantModel.currentAssistant = assistant;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AssistantSidebarCard extends StatelessWidget {
  final String assistantID;
  final VoidCallback onTap;

  const AssistantSidebarCard({
    super.key,
    required this.assistantID,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context);
    final assistant = assistantModel.assistantMap[assistantID];
    final name = assistant?.name ?? 'Unbekannt';
    final deviation = assistant?.formattedDeviation ?? 'Unbekannt';
    final color = assistantModel.assistantColorMap[assistantID] ?? Colors.grey;

    return Card(
      elevation: assistantModel.currentAssistant?.assistantID == assistantID ? 8 : 1,
      color: assistantModel.currentAssistant?.assistantID == assistantID 
          ? Theme.of(context).colorScheme.primaryContainer 
          : null,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text(deviation),
        onTap: () {
          assistantModel.selectAssistant(assistantID);
          onTap();
        },
      ),
    );
  }
}

