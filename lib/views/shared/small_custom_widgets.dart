import 'package:der_assistenzplaner/models/shift.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/tag.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ShiftCard extends StatelessWidget {
  final Shift shift;
  final String assistantID;

  ShiftCard({super.key, required this.shift, required this.assistantID});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(        
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assistantID),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(shift.start.toString()),
                    Text(' - '),
                    Text(shift.end.toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
  
class AssistantCard extends StatelessWidget {
  final Assistant assistant;

  const AssistantCard({super.key, required this.assistant});

  @override
  Widget build(BuildContext context) {
    final name = assistant.name;
    final deviation = assistant.deviation.toString();
    final tags = assistant.tags;
    final color = Colors.purple;

    var screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
                    'Deviation: $deviation',
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

class TagWidget extends StatefulWidget {
  final Tag tag;
  TagWidget(this.tag);

  @override
  State<StatefulWidget> createState() => _TagWidgetViewState();
}

class _TagWidgetViewState extends State<TagWidget> {
  var isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Focus(
          child: GestureDetector(
            /// two states: focused and not focused 
            onTap: () {
              setState(() {
                isFocused = !isFocused;   
              });
            },
            child: Container(      
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                /// change border color when focused
                border: Border.all(color: isFocused ? Colors.blue : Colors.grey, width: 2),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FaIcon(
                    widget.tag.tagSymbol,
                    color: isFocused ? Colors.blue : Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.tag.name,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

