import 'package:der_assistenzplaner/main.dart';
import 'package:flutter/material.dart';


// navigation without stack
void navigateToAssistantScreen(BuildContext context) {
  Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen(initialTabIndex: 1)),
);

}


// /// replaces current Route, stack won't change
// void navigateToAssistantDetails(BuildContext context, assistant) {
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => AssistantScreen(
//       initialViewIndex: 1,
//     )),
//   );
// }

