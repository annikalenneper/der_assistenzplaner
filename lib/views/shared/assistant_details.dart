
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:flutter/material.dart';

class AssistantDetails extends StatelessWidget {
  final Assistant assistant;

  AssistantDetails(this.assistant);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(assistant.name.toString())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [ 
              Icon(Icons.person, size: 100),
              Text(assistant.tags.toString()),
              Text(assistant.deviation.toString()),
              Text(assistant.notes.toString()),
          ],
        ),
      ),
    );
  }
}
