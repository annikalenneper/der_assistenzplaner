import 'package:der_assistenzplaner/models/shift.dart';

class Workschedule {
  final DateTime start;
  final DateTime end;
  /// map of shifts by date
  final Map<DateTime, List<ScheduledShift>> shiftsByDate = {};

  Workschedule(this.start, this.end);

  void addShift(ScheduledShift shift) {
    /// get date of shift, then add shift to list of shifts for that date if it exists, otherwise create a new list
    final date = DateTime(shift.start.year, shift.start.month, shift.start.day);
    shiftsByDate.putIfAbsent(date, () => []).add(shift);
  }

  /// returns all shifts for a given day or empty list if no shifts are scheduled
  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return shiftsByDate[date] ?? [];
  }
}
