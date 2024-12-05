import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/shared/assistant_card.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/models/assistant.dart';

//----------------- AssistantScreen -----------------

class AssistantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context);
    return Stack(
      children: [
        Column(
        children: [
          Text('Assistenzkräfte'),
          AssistantCard(assistantModel),      
        ] 
      ),
      Positioned(
        bottom: 20,
        right: 20,
        child: 
          FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AssistantAddScreen()));
          },
          child: Icon(Icons.add),
          ),  
        ),
      ] 
    );
  }
}

//----------------- AssistantDetailView -----------------

class AssistantDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
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

    if (name.isEmpty || hoursText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte gib einen Namen und eine monatliche Stundenanzahl für deine Assistenzkraft ein')),
      );
      return;
    }

    final  double? hours = double.tryParse(hoursText);
    if (hours == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte gib eine gültige Stundenzahl ein')),
      );
      return;
    }

    var newAssistant = AssistantModel(Assistant(name, hours));
    newAssistant.saveAssistant(); /// not implemented yet

    /// testing + user feedback
    print("Neue Assistenzkraft: Name = $name, Stunden = $hours");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assistenzkraft $name wurde hinzugefügt')),
    );

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
