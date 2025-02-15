

import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/utils/validators.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';

class ShiftForm extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime? editShiftStart;
  final DateTime? editShiftEnd;
  final Function(DateTime start, DateTime end, String? assistantID) onSave;
  
  const ShiftForm({super.key, required this.onSave, required this.selectedDay, this.editShiftStart, this.editShiftEnd});

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

  //TO-DO: add validators

  //TO-DO: default values from settings when creating new shift (no start and end time given in constructor)
  String getInitialStart(){
    return (widget.editShiftStart != null) 
      ? formatDate(widget.editShiftStart!)
      : "08:00";
  }

  String getInitialEnd(){
    return (widget.editShiftEnd != null) 
      ? formatDate(widget.editShiftEnd!)
      : "16:00";
  }

  @override
  void initState() {
    super.initState();
    /// set initial value for dates
    _startDateController.text = formatDate(widget.selectedDay);
    _endDateController.text = formatDate(widget.selectedDay);
    _startTimeController.text = getInitialStart(); 
    _endTimeController.text = getInitialEnd();
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
              pickTime(
                context: context, 
                initialTime: stringToTime(_endTimeController.text), 
                onTimeSelected: (time) => _endTimeController.text = formatTimeOfDay(time)
              );
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
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}