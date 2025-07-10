import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/planner/shift_form.dart';
import 'package:der_assistenzplaner/views/shared/markers.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShiftCard extends StatefulWidget {
  final Shift shift;
  final String assistantID;

  const ShiftCard({
    super.key, 
    required this.shift, 
    required this.assistantID,
  });

  @override
  State<ShiftCard> createState() => _ShiftCardState();
}

class _ShiftCardState extends State<ShiftCard> {
  
  /// check if split time is outside of shift or if the new shifts are too short
  bool _isInvalidShiftSplit(Shift shift, DateTime splitTime) {
    bool isOutsideShift = splitTime.isBefore(shift.start) || splitTime.isAfter(shift.end);
    
    // Check if new shifts would be too short (minimum 15 minutes)
    Duration firstShiftDuration = splitTime.difference(shift.start);
    Duration secondShiftDuration = shift.end.difference(splitTime);
    
    bool tooShort = firstShiftDuration.inMinutes < 15 || secondShiftDuration.inMinutes < 15;
    
    return isOutsideShift || tooShort;
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<ShiftModel>(
      builder: (context, shiftModel, child) {
        final currentShift = shiftModel.getShiftById(widget.shift.shiftID) ?? widget.shift;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                Row(
                  children: [
                    AssistantMarker(
                      size: 32,
                      assistantID: currentShift.assistantID ?? widget.assistantID,
                      onTap: _onAssistantPressed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAssistantName(),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentShift.toString(), // currentShift verwenden
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.edit,
                      'Bearbeiten',
                      _onEditPressed,
                    ),
                    _buildActionButton(
                      Icons.swap_horiz,
                      'Tauschen',
                      _onAssistantPressed,
                    ),
                    _buildActionButton(
                      Icons.call_split,
                      'Aufteilen',
                      _onSplitPressed,
                    ),
                    _buildActionButton(
                      Icons.delete_outline,
                      'Löschen',
                      _onDeletePressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAssistantName() {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final assistant = assistantModel.assistantMap[widget.assistantID];
    return assistant?.name ?? 'Unbesetzt';
  }

  void _onEditPressed() async {
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Schicht bearbeiten'),
          content: SizedBox(
            width: 400,
            child: ShiftForm(
              selectedDay: widget.shift.start,
              editShiftStart: widget.shift.start,
              editShiftEnd: widget.shift.end,
              onSave: (start, end, assistantID) {
                final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                shiftModel.updateShift(
                  widget.shift,
                  newStart: start,
                  newEnd: end,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onAssistantPressed() {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final availableAssistants = assistantModel.assistants
        .where((assistant) => assistant.assistantID != widget.assistantID)
        .toList();

    assignAssistant(availableAssistants);
  }

  Future<dynamic> assignAssistant(List<Assistant> availableAssistants) {
    return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Assistenzkraft tauschen'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Wähle eine neue Assistenzkraft für diese Schicht:'),
              const SizedBox(height: 16),
              ...availableAssistants.map((assistant) {
                return ListTile(
                  leading: AssistantMarker(
                    assistantID: assistant.assistantID,
                    size: 24,
                    onTap: () {},
                  ),
                  title: Text(assistant.name),
                  onTap: () {
                    final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                    
                    shiftModel.updateShift(
                      widget.shift,
                      newAssistantID: assistant.assistantID,
                    );
                  },
                );
              }
            ),
          ],),
        ),
          actions: [
            TextButton(
              onPressed: (){},
              child: const Text('Abbrechen'),
            ),
          ],
        );
      },
    );
  }

  void _onSplitPressed() {
    pickTime(
      context: context,
      initialTime: dateTimeToTimeOfDay(widget.shift.start.add(const Duration(hours: 4))),
      onTimeSelected: (time) {
        final shiftModel = Provider.of<ShiftModel>(context, listen: false);
        final breakpoint = timeOfDayToDateTime(time, widget.shift.start);
        
        if (_isInvalidShiftSplit(widget.shift, breakpoint)) {
          _showInvalidSplitDialog();
        } else {
          shiftModel.splitShift(widget.shift, breakpoint);
        }
      },
    );
  }

  void _onDeletePressed() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Schicht löschen'),
          content: Text(
            'Möchten Sie die Schicht von ${_getAssistantName()} am ${formatDate(widget.shift.start)} wirklich löschen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                shiftModel.deleteShift(widget.shift.shiftID);
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  //TODO: restraint to selectable shift time
  void _showInvalidSplitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ungültige Zeitangabe'),
          content: const Text(
            'Der Schichtwechsel muss innerhalb der Schicht liegen. Die neuen Schichten müssen mindestens 15 Minuten lang sein.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

