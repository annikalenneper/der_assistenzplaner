import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AddAssistantForm extends StatefulWidget {
  final Function(String name, double hours, Color color) onSave;
  
  const AddAssistantForm({super.key, required this.onSave});

  @override
  State<AddAssistantForm> createState() => AddAssistantFormState();
}

class AddAssistantFormState extends State<AddAssistantForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hourController = TextEditingController();
  Color selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text('Wie heißt die Assistenz?'),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Name der Assistenz',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib einen Namen ein';
              }
              return null;
            },
          ),
          Text('Wie viele Stunden soll die Assistenz pro Monat arbeiten?'),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: _hourController,
            decoration: const InputDecoration(
              hintText: 'Stundenanzahl',
            ),
            validator: (value) => validateHours(value),
          ),
          Text('Ordne der neuen Assistenz eine Farbe zu'),
          DropDownColorPicker(
            onColorSelected: (color) {
              selectedColor = color;
            },
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSave(
                  _nameController.text,
                  double.parse(_hourController.text), 
                  selectedColor,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Assistent erstellen'),
          ),
        ],
      ),
    );
  }
}

String? validateHours (value) {
  if (value == null || value.isEmpty) {
    return 'Bitte geben Sie eine Stundenanzahl ein';
  }
  else if (double.parse(value) < 0 || double.parse(value) > 192) {
    return 'Bitte geben Sie eine gültige Zahl an Arbeitsstunden pro Monat ein';
  } 
  return null;
}

