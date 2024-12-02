
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:flutter/material.dart';

class AssistantDetails extends StatelessWidget {
  final AssistantModel assistant;

  AssistantDetails(this.assistant);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            onPressed: (){},
            icon: Icon(Icons.edit),
          )
        ),
        Column(
        children: [
          Icon(Icons.person),
          Text(assistant.name),
          Row(
            children: [
              Text(assistant.tags.toString()),
              Icon(Icons.add),
            ],
          ),
          Text('${assistant.deviation}'),
          Text('StundenVertragliche Arbeitsstunden: ${assistant.contractedHours}'),
          Text('Tatsächliche Arbeitsstunden: ${assistant.actualHours}'),
        ],
      ),
      ] 
    );
  }
}