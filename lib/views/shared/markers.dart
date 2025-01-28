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


//----------------- ShiftCard + ShiftCardDetails -----------------

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final String assistantID;

  const ShiftCard({
    super.key, 
    required this.shift, 
    required this.assistantID,});

  /// check if splittime is outside shift or new shift shorter than 15 minutes
  bool _isInvalidShiftSplit(Shift shift, DateTime splitTime) {
    return (
      splitTime.isAtSameMomentAs(shift.start) ||
      splitTime.isAtSameMomentAs(shift.end) ||
      splitTime.isBefore(shift.start) || 
      splitTime.isAfter(shift.end) ||
      calculateDateTimeDuration(shift.start, shift.end) < 15.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Card(
        elevation: 15,
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: _buildAssistantInfo(context)),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShiftTimeInfo(shift),
                    _buildActions(context),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftTimeInfo(shift) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(shift.toString()),
      ],
    );
  } 
  
  Widget _buildAssistantInfo(context){
    final assistantModel = Provider.of<AssistantModel>(context);
    final assistant = assistantModel.assistantMap[assistantID];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AssistantMarker(size: 40, assistantID: assistantID, onTap: (){},),
        const SizedBox(width: 8),
        Text(assistant?.name ?? 'Unbesetzt'),
      ]);
  }

  Widget _buildActions(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Schicht bearbeiten'),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ShiftForm(
                      selectedDay: shift.start,
                      onSave: (start, end, assistantID) {
                        final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                        shiftModel.updateShift(shift);
                      },
                    ),
                  ),
                );
              },
            );
          },
          child: Column(
            children: [
              Icon(Icons.edit),
              Text('Bearbeiten', textAlign: TextAlign.center),
            ],

          ),
        ),


        TextButton(
          onPressed: () {}, 
          /// highlight all days/shifts where 
          /// assistant assigned to this shift is available
          /// AND assistant assigned to the other shift is available for this shift

          /// if user selects a day that is not highlighted:
          /// open alertDialog. If user confirms: 
          /// assistants need to confirm the swap first (send notification)
          child: Column(
            children: [
              Icon(Icons.change_circle),
              Text('Tauschen', textAlign: TextAlign.center),
            ],
          ),
        ),
                      
        TextButton(
          onPressed: () {
            pickTime(
              context: context, 
              initialTime: dateTimeToTimeOfDay(shift.start.add(const Duration(hours: 8))), 
              onTimeSelected: (time) {               
                ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
                final breakpoint = timeOfDayToDateTime(time, shift.start);
                if (_isInvalidShiftSplit(shift, breakpoint)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Ungültige Zeitangabe'),
                        content: const Text('Der Schichtwechsel muss innerhalb der Schicht liegen. Die neuen Schichten müssen mindestens 15 Minuten lang sein.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                shiftModel.splitShift(shift, breakpoint);
                }
              },
            );
          },
          child: Column(
            children: [
              Icon(Icons.call_split),
              Text('Aufteilen', textAlign: TextAlign.center), 
            ],
          ),
        ),
                      
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Möchten Sie diese Schicht wirklich löschen?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Abbrechen'),
                    ),
                    TextButton(
                      onPressed: () {
                        final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                        shiftModel.deleteShift(shift.shiftID);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Löschen bestätigen'),
                    ),
                  ],
                );
              },
            );
          }, 
          child: Column(
            children: [
              Icon(Icons.delete),
              Text('Löschen', textAlign: TextAlign.center), 
            ],
          ),
        ),
      ],
    ); 
  }
}


//----------------- AssistantCard -----------------

/// TO-DO: refactor with assistantID instead of assistant
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



