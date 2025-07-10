import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/styles/styles.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
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

    // Für sehr kleine Größen (< 20) kein Padding und vereinfachte Struktur
    if (size < 20) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: size * 0.5, // Etwas kleiner für bessere Lesbarkeit
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
        ),
      );
    }

    // Normale Größe mit Padding und Material-Wrapper
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
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

CalendarDayMarker? buildDayMarker(context, day) {
  final normalizedDay = normalizeDate(day);

  final shiftModel = Provider.of<ShiftModel>(context, listen: false);
  final shiftMap = shiftModel.shiftsByDay;
  final shifts = shiftMap[normalizedDay];
  
  if (shifts != null && shifts.isNotEmpty){
    return CalendarDayMarker(shifts: shifts); 
  }
  else {
    return null;
  }
}


class CalendarDayMarker extends StatelessWidget {
  final List<Shift> shifts; 
  final Color? color;

  const CalendarDayMarker({
    super.key, 
    required this.shifts,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          right: 1,
          bottom: 1,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: color ?? Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...shifts
                      .where((shift) => shift.assistantID != null)
                      .map((shift) => shift.assistantID!)
                      .toSet() // no duplicates
                      .map((assistantID) => Padding(
                            padding: const EdgeInsets.all(1.0), 
                            child: AssistantMarker(
                              size: 14, 
                              assistantID: assistantID,
                              onTap: () {},
                            ),
                          )),
                  // number of shifts
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        '${shifts.length} Schicht${shifts.length > 1 ? 'en' : ''}',
                        style: const TextStyle(
                          fontSize: 8,
                          color: ModernBusinessTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}



