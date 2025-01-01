import 'package:der_assistenzplaner/main.dart';
import 'package:flutter/material.dart';


void navigateToWorkScheduleScreen(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 0)),
    (route) => false
  );
}

void navigateToAssistantScreen(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 1)),
    (route) => false
  );
}

