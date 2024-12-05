
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:flutter/material.dart';

class AssistantDetails extends StatelessWidget {
  final AssistantModel selectedAssistant;

  AssistantDetails(this.selectedAssistant);

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
          Text(selectedAssistant.name),
          Row(
            children: [
              Text(selectedAssistant.tags.toString()),
              Icon(Icons.add),
            ],
          ),
          Text('${selectedAssistant.deviation}'),
          Text('Vertraglich vereinbarte Arbeitsstunden: ${selectedAssistant.contractedHours}'),
          Text('Tatsächliche Arbeitsstunden: ${selectedAssistant.actualHours}'),
        ],
      ),
      ] 
    );
  }
}