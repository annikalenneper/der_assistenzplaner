import 'package:der_assistenzplaner/main.dart';
import 'package:flutter/material.dart';


void navigateToWorkScheduleScreen(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 0))
  );
}

void navigateToAssistantScreen(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 1))
  );
}

