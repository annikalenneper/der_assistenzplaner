import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/planner/shift_form.dart';
import 'package:der_assistenzplaner/views/shared/markers.dart';
import 'package:der_assistenzplaner/views/shared/single_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;

  const ShiftCard({
    super.key, 
    required this.shift, 
  });

  @override
  Widget build(BuildContext context) {
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
                  assistantID: shift.assistantID ?? '',
                  onTap: () => _onAssistantPressed(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getAssistantName(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shift.toString(), 
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
                  context,
                  Icons.edit,
                  'Bearbeiten',
                  () => _onEditPressed(context),
                ),
                _buildActionButton(
                  context,
                  Icons.swap_horiz,
                  'Tauschen',
                  () => _onAssistantPressed(context),
                ),
                _buildActionButton(
                  context,
                  Icons.call_split,
                  'Aufteilen',
                  () => _onSplitPressed(context),
                ),
                _buildActionButton(
                  context,
                  Icons.delete_outline,
                  'Löschen',
                  () => _onDeletePressed(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
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

  String _getAssistantName(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final assistant = assistantModel.assistantMap[shift.assistantID];
    return assistant?.name ?? 'Unbesetzt';
  }

  void _onEditPressed(BuildContext context) async {
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Schicht bearbeiten'),
          content: SizedBox(
            width: 400,
            child: ShiftForm(
              selectedDay: shift.start,
              editShiftStart: shift.start,
              editShiftEnd: shift.end,
              onSave: (start, end, assistantID) {
                final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                shiftModel.updateShift(
                  shift,
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

  void _onAssistantPressed(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final availableAssistants = assistantModel.assistants
        .where((assistant) => assistant.assistantID != shift.assistantID)
        .toList();
    
    showDialog(
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
                        shift,
                        newAssistantID: assistant.assistantID,
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSplitPressed(BuildContext context) {
    pickTime(
      context: context,
      initialTime: dateTimeToTimeOfDay(shift.start.add(const Duration(hours: 4))),
      onTimeSelected: (time) {
        final shiftModel = Provider.of<ShiftModel>(context, listen: false);
        final breakpoint = timeOfDayToDateTime(time, shift.start);
        
        if (_isInvalidShiftSplit(shift, breakpoint)) {
          _showInvalidSplitDialog(context);
        } else {
          shiftModel.splitShift(shift, breakpoint);
        }
      },
    );
  }

  void _onDeletePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Schicht löschen'),
          content: Text(
            'Möchten Sie die Schicht von ${_getAssistantName(context)} am ${formatDate(shift.start)} wirklich löschen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                final shiftModel = Provider.of<ShiftModel>(context, listen: false);
                shiftModel.deleteShift(shift.shiftID);
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

  bool _isInvalidShiftSplit(Shift shift, DateTime splitTime) {
    bool isOutsideShift = splitTime.isBefore(shift.start) || splitTime.isAfter(shift.end);
    
    Duration firstShiftDuration = splitTime.difference(shift.start);
    Duration secondShiftDuration = shift.end.difference(splitTime);
    
    bool tooShort = firstShiftDuration.inMinutes < 15 || secondShiftDuration.inMinutes < 15;
    
    return isOutsideShift || tooShort;
  }

  void _showInvalidSplitDialog(BuildContext context) {
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

