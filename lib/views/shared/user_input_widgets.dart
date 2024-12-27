

import 'dart:developer';
import 'package:der_assistenzplaner/styles.dart';
import 'package:der_assistenzplaner/utils/step_data.dart';
import 'package:flutter/material.dart';


class DynamicStepper extends StatefulWidget {
  final List<StepData> steps;
  /// callback function to handle user inputs and safe them to the database
  final void Function(Map<String, dynamic> inputs) onComplete;

  const DynamicStepper({super.key, required this.steps, required this.onComplete});

  @override
  State<DynamicStepper> createState() => DynamicStepperState();
}

class DynamicStepperState extends State<DynamicStepper> {
  int _currentStep = 0;
  final Map<String, dynamic> _inputs = {};

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < widget.steps.length - 1) {
            setState(() => _currentStep++);
          } else {
            log("$_inputs");
            widget.onComplete(_inputs);
            Navigator.pop(context);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        /// returns map of user inputs
        steps: widget.steps.map((stepData) {
          return Step(
            title: Text(stepData.title),
            content: stepData.contentBuilder(_inputs),
            isActive: widget.steps.indexOf(stepData) == _currentStep,
          );
        }).toList(),
      ),
    );
  }
}


//---------------- Custom Time Picker Hours and Minutes ----------------

class DropDownTimePicker extends StatefulWidget {
  /// initial date for the time picker, pass from calender
  final DateTime date; 
  /// callback function to handle user inputs 
  final ValueChanged<DateTime> onTimeSelected; 

  const DropDownTimePicker({super.key, required this.date, required this.onTimeSelected,});

  @override
  State<DropDownTimePicker> createState() => DropDownTimePickerState();
}

class DropDownTimePickerState extends State<DropDownTimePicker> {
  late int selectedHour = widget.date.hour;
  late int selectedMinute = widget.date.minute;

  @override
  void initState() {
    super.initState();
    _updateTime(hour: selectedHour, minute: selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            /// hours dropdown
            Expanded(
              child: DropdownButton<int>(
                value: selectedHour,
                hint: const Text('Stunde'),
                items: List.generate(24, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(index.toString().padLeft(2, '0')),
                  );
                }),
                /// update time when user selects new hour
                onChanged: (value) {
                  if (value != null) {
                    _updateTime(hour: value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16), 
            /// minutes dropdown
            Expanded(
              child: DropdownButton<int>(
                value: selectedMinute,
                hint: const Text('Minute'),
                items: List.generate(60, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(index.toString().padLeft(2, '0')),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    _updateTime(minute: value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateTime({int? hour, int? minute}) {
    setState(() {
      /// set values on changed
      if (hour != null) selectedHour = hour;
      if (minute != null) selectedMinute = minute;

      /// create new DateTime object with updated values 
      final updatedDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        selectedHour,
        selectedMinute,
      );

      /// update inputs map and call callback
      widget.onTimeSelected(updatedDateTime);
    });
  }
}


class DropDownColorPicker extends StatefulWidget {
  final List<Map<String, dynamic>> colors = ModernBusinessTheme.assistantColors;

  final ValueChanged<Color> onColorSelected;

  DropDownColorPicker({super.key, required this.onColorSelected});

  @override
  State<DropDownColorPicker> createState() => DropDownColorPickerState();
}

class DropDownColorPickerState extends State<DropDownColorPicker> {
  late Map<String, dynamic> selectedColor = widget.colors.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Map<String, dynamic>>(
      value: selectedColor,
      isExpanded: true, 
      items: widget.colors.map((colorData) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: colorData,
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: colorData['color'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 8), 
              Text(colorData['label']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedColor = value;
            widget.onColorSelected(value['color']);
          });
        }
      },
    );
  }
}


/// generic dropdown widget 
class DropDownOptionPicker<T> extends StatefulWidget {
  final List<T> options; 
  final ValueChanged<T> onOptionSelected; 
  final T? initialValue; 

  const DropDownOptionPicker({super.key, required this.options, required this.onOptionSelected, this.initialValue});

  @override
  State<DropDownOptionPicker<T>> createState() => _DropDownOptionPickerState<T>();
}

class _DropDownOptionPickerState<T> extends State<DropDownOptionPicker<T>> {
  late T selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialValue ?? widget.options.first; 
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: selectedOption,
      isExpanded: true,
      items: widget.options.map((option) {
        return DropdownMenuItem<T>(
          value: option,
          /// use enum name if option is enum, else use toString
          child: Text(
            option is Enum ? option.name : option.toString(), 
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedOption = value;
          });
          widget.onOptionSelected(value);
        }
      },
    );
  }
}

