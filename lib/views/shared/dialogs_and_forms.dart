import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShiftForm extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime start, DateTime end, String? assistantID) onSave;
  
  const ShiftForm({super.key, required this.onSave, required this.selectedDay});

  @override
  State<ShiftForm> createState() => ShiftFormState();
}

class ShiftFormState extends State<ShiftForm> {
  // global key identifies form widget
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// set initial value for dates
    _startDateController.text = formatDate(widget.selectedDay);
    _endDateController.text = formatDate(widget.selectedDay);
    //TO-DO: set default values from settings
    _startTimeController.text = '08:00'; 
    _endTimeController.text = '16:00';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDayOfMonth(widget.selectedDay),
      lastDate: lastDayOfMonth(widget.selectedDay),
    );
    if (picked != null) {
      controller.text = formatDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build form using _formKey 
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const Text('Wann beginnt die Schicht?'),
          TextFormField(
            controller: _startDateController,
            decoration: const InputDecoration(
              hintText: 'TT.MM.YYYY',
            ),
            readOnly: true,
            onTap: () async => await _pickDate(_startDateController),      
            validator: (value) => validateDate(value),
          ),
          TextFormField(
            controller: _startTimeController,
            decoration: const InputDecoration(
              hintText: '00:00',
            ),
            readOnly: true,
            onTap: () async {
              pickTime(
                context: context, 
                initialTime: stringToTime(_startTimeController.text), 
                onTimeSelected: (time) => _startTimeController.text = formatTimeOfDay(time)
              );
            },
            validator: (value) => validateTime(value),
          ),
          
          const Text('Wann endet die Schicht?'),
          TextFormField(
            controller: _endDateController,
            decoration: const InputDecoration(
              hintText: 'TT.MM.YYYY',
            ),
            readOnly: true,
            onTap: () async => await _pickDate(_endDateController),
            validator: (value) => validateDate(value),
          ),
          TextFormField(
            controller: _endTimeController,
            decoration: const InputDecoration(
              hintText: '00:00',
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                _endTimeController.text = formatTimeOfDay(picked);
              }
            },
            validator: (value) => validateTime(value),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Schicht wird angelegt')),
                );
                _formKey.currentState!.save();
                final shiftTimeRange = parseDateTimeRange(
                  _startDateController.text, 
                  _startTimeController.text, 
                  _endDateController.text, 
                  _endTimeController.text
                );
                widget.onSave(shiftTimeRange.start, shiftTimeRange.end, null);
                Navigator.pop(context);
              }
            },
            child: const Text('Schicht erstellen'),
          ),
        ],
      ),
    );
  }
}


class AssistantForm extends StatefulWidget {
  final Function(String name, double hours, Color color) onSave;
  
  const AssistantForm({super.key, required this.onSave});

  @override
  State<AssistantForm> createState() => AssistantFormState();
}

class AssistantFormState extends State<AssistantForm> {
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





//------------------------- Validators -------------------------

String? validateTime(String? value) {
  final RegExp timeRegExp = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
  if (value == null || value.isEmpty) {
    return 'Bitte gib eine Uhrzeit ein';
  }
  if (!timeRegExp.hasMatch(value)) {
    return 'Bitte gib eine gültige Uhrzeit im Format HH:MM ein';
  }
  return null;
}

String? validateDate(String? value) {
  final RegExp dateRegExp = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
  if (value == null || value.isEmpty) {
    return 'Bitte gib ein Datum ein';
  }
  if (!dateRegExp.hasMatch(value)) {
    return 'Bitte gib ein gültiges Datum im Format TT.MM.JJJJ ein';
  }
  return null;
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

String? startBeforeEnd(DateTime start, DateTime end) {
  if (start.isAfter(end)) {
    return 'Startzeit muss vor Endzeit liegen';
  }
  return null;
}
