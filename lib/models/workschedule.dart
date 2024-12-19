import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';

class Workschedule {
  final DateTime start;
  final DateTime end;
  /// map of shifts by date
  final List<Shift> Shifts = [];

  Workschedule(this.start, this.end);

  List<Shift> getShiftsByDay(DateTime day) {
    return Shifts.where((shift) => shift.start.day == day.day).toList();
  }

  void addShift(Shift shift) {
    if (shift.start.isBefore(start) || shift.end.isAfter(end)) {
      throw ArgumentError('Schicht liegt nicht im ausgewählten Zeitraum.');
    } 
    /// insert shift sorted by start time (helper function from utils/sort.dart)
    insertSorted<Shift>(
      Shifts,
      shift,
      (a, b) => a.start.compareTo(b.start),
    );

    /// warning if shifts overlap
    int index = Shifts.indexOf(shift);
    if (index > 0 && doesOverlap(shift, Shifts[index - 1])) {
      print('Hinweis: Die neue Schicht überschneidet sich mit der vorherigen Schicht (Start: ${shift.start} liegt vor Ende: ${Shifts[index - 1].end.toString()}).');
    } if (index < Shifts.length - 1 && doesOverlap(shift, Shifts[index + 1])) {
      print('Hinweis: Die neue Schicht überschneidet sich mit der nächsten Schicht (Ende: ${shift.end} liegt nach Start: ${Shifts[index + 1].start.toString()}).');
      } else {
        print('Schicht erfolgreich hinzugefügt.');
      }
  }

  void removeShift(Shift shift) {
    bool removed = Shifts.remove(shift);
    if (!removed) {
      print('Schicht nicht gefunden.');
    } else {
      print('Schicht erfolgreich entfernt.');
    }
  }

}

///TO-DO: move to utils, make generic
bool doesOverlap(Shift newShift, Shift existingShift) => newShift.start.isBefore(existingShift.end) && newShift.end.isAfter(existingShift.start);