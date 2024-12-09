import 'package:der_assistenzplaner/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/shared/assistant_card.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/models/assistant.dart';
import 'dart:developer';
import 'package:der_assistenzplaner/utils/nav.dart';


//----------------- AssistantScreen -----------------

class AssistantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context);
    return Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: assistantModel.assistants.length,
                  itemBuilder: (context, index) {
                    var assistant = assistantModel.assistants[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssistantDetails(assistantModel),
                        ),
                      ),
                      child: AssistantCard(assistant)
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssistantAddScreen()),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Neue Assistenzkraft'),
            ),
          ),
        ],
      );
  }
}



//----------------- AssistantAddScreen -----------------

class AssistantAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Neue Assistenzkraft hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AssistantAddView(),
      ),
    );
  }
}

class AssistantAddView extends StatefulWidget {
  const AssistantAddView({super.key});

  @override
  State<AssistantAddView> createState() => _AssistantAddViewState();
}

class _AssistantAddViewState extends State<AssistantAddView> {
  int _index = 0;

  /// controller for textfields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  void _submitDataAndCreateAssistant() {
    /// get textfield values withouth whitespaces
    final name = _nameController.text.trim();
    final hoursText = _hoursController.text.trim();
    /// input check
    if (name.isEmpty || hoursText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte gib einen Namen und eine monatliche Stundenanzahl für deine Assistenzkraft ein')),
      );
      return;
    }
    /// only accept double as input
    final  double? hours = double.tryParse(hoursText);
    if (hours == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte gib eine gültige Stundenzahl ein')),
      );
      return;
    }
    /// save assistant to database
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    assistantModel.currentAssistant = Assistant(name, hours);
    assistantModel.saveCurrentAssistant();
    log(assistantModel.assistants.toString());
    /// navigate back to AssistantScreen with new data
    navigateToAssistantDetails(context, assistantModel);

    /// clear textfields
    _nameController.clear();
    _hoursController.clear();
    setState(() {
      _index = 0;
    });
  }

  /// stepper for user input of assistant data 
  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _index,
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepContinue: () {
        if (_index < 1) {
          setState(() {
            _index += 1;
          });
        } else {
          _submitDataAndCreateAssistant();
        }
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      steps: <Step>[
        Step(
          title: const Text('Wie soll die neue Assistenzkraft heißen?'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name der Assistenzkraft',
            ),
          ),
        ),
        Step(
          title: const Text('Wie viele Stunden soll die Assistenzkraft arbeiten?'),
          content: TextField(
            controller: _hoursController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Stundenzahl pro Monat',
            ),
            //only numbers allowed
            keyboardType: TextInputType.number, 
          ),
        ),
      ],
    );
  }
}


//----------------- AssistantDetailScreen -----------------

class AssistantDetails extends StatelessWidget {
  final AssistantModel assistant;

  AssistantDetails(this.assistant);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(assistant.name.toString())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [ 
            Icon(Icons.person, size: 100),
            Text(assistant.tags.toString()),
            Text(assistant.deviation.toString()),
            Text(assistant.notes.toString()),
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
                        assistant.deleteAssistant();
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
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height,   
                            width: MediaQuery.sizeOf(context).width,
                            child: TagView(true)),
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


