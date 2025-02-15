import 'dart:developer';

import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/planner/shift_usecases.dart';
import 'package:der_assistenzplaner/views/shared/markers.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final String assistantID;

  const ShiftCard({
    super.key, 
    required this.shift, 
    required this.assistantID,});

  /// check if split time is outside of shift or if the new shifts are too short
  bool _isInvalidShiftSplit(Shift shift, DateTime splitTime) {
    bool isOutsideShift = splitTime.isBefore(shift.start) || splitTime.isAfter(shift.end);
    int firstShiftDuration = calculateDateTimeDuration(shift.start, splitTime);
    int secondShiftDuration = calculateDateTimeDuration(splitTime, shift.end);
    bool isTooShort = firstShiftDuration < 15.0 || secondShiftDuration < 15.0;
    return isOutsideShift || isTooShort; 
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

  Widget _buildShiftTimeInfo(Shift shift) {
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
                log('Splitting shift at $breakpoint');
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