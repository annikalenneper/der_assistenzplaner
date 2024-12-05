
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:flutter/material.dart';

class AssistantDetails extends StatelessWidget {
  final Assistant assistant;

  AssistantDetails(this.assistant);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(assistant.name.toString())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

      ),
    );
  }
}
