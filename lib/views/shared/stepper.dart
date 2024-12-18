

import 'dart:developer';
import 'package:der_assistenzplaner/utils/step_data.dart';
import 'package:flutter/material.dart';


class DynamicStepper extends StatefulWidget {
  final List<StepData> steps;

  const DynamicStepper({Key? key, required this.steps}) : super(key: key);

  @override
  _DynamicStepperState createState() => _DynamicStepperState();
}

class _DynamicStepperState extends State<DynamicStepper> {
  int _currentStep = 0;
  final Map<String, dynamic> _inputs = {};

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (step) => setState(() => _currentStep = step),
      onStepContinue: () {
        if (_currentStep < widget.steps.length - 1) {
          setState(() => _currentStep++);
        } else {
          log("$_inputs");
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      steps: widget.steps.map((stepData) {
        return Step(
          title: Text(stepData.title),
          content: stepData.contentBuilder(_inputs),
          isActive: widget.steps.indexOf(stepData) == _currentStep,
        );
      }).toList(),
    );
  }
}

