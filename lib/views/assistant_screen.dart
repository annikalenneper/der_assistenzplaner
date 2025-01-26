import 'package:der_assistenzplaner/views/settings_screen.dart';
import 'package:der_assistenzplaner/views/shared/view_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/shared/cards_and_markers.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'dart:developer';
import 'package:der_assistenzplaner/utils/nav.dart';


//----------------- AssistantPage -----------------

/// main view for the assistant management
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  int _index = 0;

  /// change view in AssistantPage
  void _setAssistantPageViewState(int index) {
    setState(() {
      _index = index;
    });
    log('AssistantPageViewState: $_index');
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: IndexedStack(
            index: _index,
            children: [
              /// callback function executes setAssistantPageViewState() from AssistantListView
              AssistantListView(
                changePageViewIndex: _setAssistantPageViewState
              ),
              AssistantDetailView(),
            ],
          ),
        ),
      ),
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
    return Scaffold(
          body: SizedBox(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Consumer<AssistantModel>(
                        builder: (context, assistantModel, child) {  
                        return GridView.builder(
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
                        );
                        }
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
                          content: Text('kommt bald'),
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
                          PopUpBox(view: TagGridView()),
                          ElevatedButton(
                            onPressed: () {
                             /// TO-DO assignTag()
                            }, 
                            child: Text('Ausgewählte Tags zuordnen'))
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

