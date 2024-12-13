import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/models/assistant.dart';


class AssistantCard extends StatelessWidget {
  /// pass currentAssistant from AssistantModel as assistant to display
  final Assistant assistant;
  AssistantCard({required this.assistant});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Icon(size: 50, Icons.person)]
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(assistant.deviation.toString()),
                  Text(assistant.tags.toString()),
                ]),
              ),
            ],
          ),
        )
      ),
    );
  }
}