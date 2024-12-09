import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/views/assistant_screen.dart';
import 'package:der_assistenzplaner/main.dart';

/// remove stack and navigate 
void navigateToAssistantScreen(BuildContext context) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/assistantScreen',
    (route) => false
  );
}

/// replaces current Route, stack won't change
void navigateToAssistantDetails(BuildContext context, assistant) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => AssistantDetails(assistant)),
  );
}

