
//----------------- AssistantCard -----------------

import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/shared/markers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssistantCard extends StatelessWidget {
  final String assistantID;

  const AssistantCard({super.key, required this.assistantID});

  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final assistant = assistantModel.assistantMap[assistantID];
    final name = assistant?.name ?? 'Unbekannt';
    final deviation = assistant?.formattedDeviation ?? 'Unbekannt';
    final tags = assistant?.tags ?? [];
    final color = assistantModel.assistantColorMap[assistantID] ?? Colors.grey;

    var screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      child: Card(
        elevation: 15,
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            AssistantMarker(
              size: 50, assistantID: 
              assistantID, 
              onTap: () {
                final ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
                shiftModel.updateDisplayOption(ShiftDisplayOptions.assistant, assistantID);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.0175,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    deviation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            /// tags
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: tags.isEmpty
                    ? [Text('No tags', style: TextStyle(color: Colors.grey))]
                    : tags.map((tag) => TagWidget(tag)).toList(),
                ),
              ),
            ),
            /// colored bottom section
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ) 
          ],
        ),
      ),
    );
  }
}