import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/utils/sort.dart';

class Workschedule {
  final DateTime start;
  final DateTime end;
  /// map of shifts by date
  final List<ScheduledShift> scheduledShifts = [];

  Workschedule(this.start, this.end);

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return scheduledShifts.where((shift) => shift.start.day == day.day).toList();
  }

  void addShift(ScheduledShift shift) {
    if (shift.start.isBefore(start) || shift.end.isAfter(end)) {
      throw ArgumentError('Schicht liegt nicht im ausgewählten Zeitraum.');
    } 
    /// insert shift sorted by start time (helper function from utils/sort.dart)
    insertSorted<ScheduledShift>(
      scheduledShifts,
      shift,
      (a, b) => a.start.compareTo(b.start),
    );

    /// warning if shifts overlap
    int index = scheduledShifts.indexOf(shift);
    if (index > 0 && doesOverlap(shift, scheduledShifts[index - 1])) {
      print('Hinweis: Die neue Schicht überschneidet sich mit der vorherigen Schicht (Start: ${shift.start} liegt vor Ende: ${scheduledShifts[index - 1].end.toString()}).');
    } if (index < scheduledShifts.length - 1 && doesOverlap(shift, scheduledShifts[index + 1])) {
      print('Hinweis: Die neue Schicht überschneidet sich mit der nächsten Schicht (Ende: ${shift.end} liegt nach Start: ${scheduledShifts[index + 1].start.toString()}).');
      } else {
        print('Schicht erfolgreich hinzugefügt.');
      }
  }

  void removeShift(ScheduledShift shift) {
    bool removed = scheduledShifts.remove(shift);
    if (!removed) {
      print('Schicht nicht gefunden.');
    } else {
      print('Schicht erfolgreich entfernt.');
    }
  }

}

///TO-DO: move to utils, make generic
bool doesOverlap(ScheduledShift newShift, ScheduledShift existingShift) => newShift.start.isBefore(existingShift.end) && newShift.end.isAfter(existingShift.start);