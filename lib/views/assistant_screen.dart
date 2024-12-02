import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/shared/assistant_card.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';

///AssistantsScreen
class AssistantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context);
    return Stack(
      children: [
        Column(
        children: [
          Text('Assistenzkräfte'),
          AssistantCard(assistantModel),      
        ] 
      ),
      Positioned(
        bottom: 20,
        right: 20,
        child: 
          FloatingActionButton(
            onPressed: () {
          
          },
          child: Icon(Icons.add),
          ),  
        ),
      ] 
    );
  }
}