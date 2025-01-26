import 'package:der_assistenzplaner/utils/helper_functions.dart';
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
              label: Text('Uhrzeit'),
              hintText: '00:00',
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                initialEntryMode: TimePickerEntryMode.input,
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                _startTimeController.text = formatTimeOfDay(picked);
              }
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
            controller: _endDateController,
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
                _endDateController.text = formatTimeOfDay(picked);
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
                var startDate = stringToDate(_startDateController.text);
                var startTime = stringToTime(_startTimeController.text);
                var endDate = stringToDate(_endDateController.text);
                var endTime = stringToTime(_endTimeController.text);
                var start = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
                var end = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
                widget.onSave(
                  start,
                  end, 
                  null
                );
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
  final Function(String name, double hours) onSave;
  
  const AssistantForm({super.key, required this.onSave});

  @override
  State<AssistantForm> createState() => AssistantFormState();
}

class AssistantFormState extends State<AssistantForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hourController = TextEditingController();
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie eine Stundenanzahl ein';
              }
              else if (double.parse(value) < 0 || double.parse(value) > 192) {
                return 'Bitte geben Sie eine gültige Zahl an Arbeitsstunden pro Monat ein';
              } 
              return null;
            },
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assistent wird angelegt')),
                );
                _formKey.currentState!.save();
                widget.onSave(
                  _nameController.text,
                  double.parse(_hourController.text), 
                );
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
