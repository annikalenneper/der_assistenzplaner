import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/planner/shift_usecases.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:der_assistenzplaner/data/models/tag.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';






//----------------- AssistantMarker -----------------


class AssistantMarker extends StatelessWidget {
  final String assistantID;
  final double size;
  final VoidCallback onTap; 

  const AssistantMarker({
    super.key,
    required this.size,
    required this.assistantID,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final assistant = assistantModel.assistantMap[assistantID];
    final name = assistant?.name ?? 'Unbekannt';
    final color = assistantModel.assistantColorMap[assistantID] ?? Colors.grey;

    /// wrapped with Material Widget to enable InkWell without overflow
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap, // tap-callback
          customBorder: const CircleBorder(), 
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.6,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


//----------------- TagWidget -----------------

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
          child: InkWell(
            /// switch between the states
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

//----------------- CalendarDayMarkers -----------------

CalendarDayMarker? buildDayMarker(context, day, shiftModel) {
  final normalizedDay = normalizeDate(day);
  final shiftMap = shiftModel.shiftsByDay;
  final shifts = shiftMap[normalizedDay];
  if (shifts != null && shifts.isNotEmpty){
    //TO-DO: Assi-Farben anzeigen, wenn Schicht besetzt
    return CalendarDayMarker(shift: shifts.first, color: Colors.grey.shade300);
  }
  else {
    return null;
  }
}


class CalendarDayMarker extends StatelessWidget {
  final Shift shift;
  final Color color;

  const CalendarDayMarker({super.key, required this.shift, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          Positioned.fill(
            right: 1,
            bottom: 1,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(shift.toString()),
                ),
              )
            ),
          ),
        ]
      );
    }    
  }



