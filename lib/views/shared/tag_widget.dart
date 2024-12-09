import 'package:der_assistenzplaner/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


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
            onTap: () {
              setState(() {
                isFocused = !isFocused;   
              });
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isFocused ? Colors.blue : Colors.grey, width: 2),
              ),
              child: Center(
                child: FaIcon(
                  widget.tag.tagSymbol,
                  size: 30,
                  color: isFocused ? Colors.blue : Colors.grey.shade800,
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

