import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';

class AssistantCard extends StatelessWidget {
  final AssistantModel assistant;

  AssistantCard(this.assistant);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Icon(Icons.person)]
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assistant.name),
                  Text(assistant.notes.toString()),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(assistant.deviation.toString()),
                Text(assistant.tags.toString()),
              ]),
            ),
          ],
        ),
      )
    );
  }
}