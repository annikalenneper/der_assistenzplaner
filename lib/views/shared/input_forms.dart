import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class ShiftForm extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime start, DateTime end, String? assistantID) onSave;
  
  const ShiftForm({super.key, required this.onSave, required this.selectedDay});

  @override
  ShiftFormState createState() => ShiftFormState();
}

class ShiftFormState extends State<ShiftForm> {
  // global key identifies form widget
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// set initial value for date
    _startDateController.text = formatDate(widget.selectedDay);
  }

  Future<DateTime?> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDayOfMonth(widget.selectedDay),
      lastDate: lastDayOfMonth(widget.selectedDay),
      initialDate: widget.selectedDay,
    );
    if (picked != null) {
      _startDateController.text = picked.day.toString();
    }
    return picked;
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
            onTap: () async {
              DateTime? picked = await _pickDate();
              if (picked != null) {
                _startDateController.text = picked.day.toString();
              }
            },
            validator: (value) => validateTime(value),
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
                _startTimeController.text = picked.format(context);
              }
            },
            validator: (value) => validateTime(value),
          ),
          
          const Text('Wann endet die Schicht?'),
          TextFormField(
            controller: _endController,
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
                _endController.text = picked.format(context);
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
                widget.onSave(
                  DateTime.parse(_startDateController.text),
                  DateTime.parse(_endController.text), 
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