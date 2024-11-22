

import 'package:der_assistenzplaner/assistents.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class Shift {
  DateTime start;
  DateTime end;

  Shift(this.start, this.end);
  
  Duration get duration => end.difference(start);
}

class ScheduledShift extends Shift {
  final Assistent assistent;

  /// TO-DO: implement getter/setter-methods for conflicts
  var tagConflictPrio1 = false;
  var tagConflictPrio2 = false;
  var availabilityConflict1 = false;
  var availabilityConflict2 = false;

  ScheduledShift(super.start, super.end, this.assistent);
}

class Availability {
  final Shift shift;
  final Assistent assistent;

  const Availability(this.shift, this.assistent);
}




//----------------- Workschedule -----------------

class Workschedule {
  final DateTime start;
  final DateTime end;
  /// map of shifts by date
  final Map<DateTime, List<ScheduledShift>> shiftsByDate = {};

  Workschedule(this.start, this.end);

  void addShift(ScheduledShift shift) {
    /// get date of shift
    final date = DateTime(shift.start.year, shift.start.month, shift.start.day);
    /// add shift to list of shifts for that date if it exists, otherwise create a new list
    shiftsByDate.putIfAbsent(date, () => []).add(shift);
  }

  /// returns all shifts for a given day or empty list if no shifts are scheduled
  List<ScheduledShift> getShiftsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return shiftsByDate[date] ?? [];
  }
}

/// model for workschedule
class WorkscheduleModel extends ChangeNotifier {
  final Workschedule workschedule;

  WorkscheduleModel(this.workschedule);

  void addShift(ScheduledShift shift) {
    workschedule.addShift(shift);
    notifyListeners(); // Widgets benachrichtigen
  }

  List<ScheduledShift> getShiftsForDay(DateTime day) {
    return workschedule.getShiftsForDay(day);
  }
}

/// dynamically displays workschedule based on selected workschedule
class WorkScheduleView extends StatefulWidget {
  final Workschedule workschedule;

  WorkScheduleView({required this.workschedule});

  @override
  WorkScheduleViewState createState() => WorkScheduleViewState();
}

class WorkScheduleViewState extends State<WorkScheduleView> {
  DateTime _selectedDay = DateTime.now(); // Standardmäßig ist der aktuelle Tag ausgewählt
  List<ScheduledShift> _selectedShifts = []; // Liste der Schichten für den ausgewählten Tag

  @override
  Widget build(BuildContext context) {
    final workschedule = widget.workschedule;

    final calendar = TableCalendar(
      firstDay: workschedule.start,
      lastDay: workschedule.end,
      focusedDay: DateTime.now(),
      selectedDayPredicate: (day) {
        // Markiere den ausgewählten Tag im Kalender
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay; // Aktualisiere den ausgewählten Tag
          _selectedShifts = workschedule.getShiftsForDay(selectedDay); // Lade die Schichten
        });
      },
      eventLoader: (day) {
        // Lade Schichten für den jeweiligen Tag
        return workschedule.getShiftsForDay(day);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: events.map((event) {
              final shift = event as ScheduledShift;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Tooltip(
                    message:
                        "${shift.start.hour}:${shift.start.minute} - ${shift.end.hour}:${shift.end.minute} (${shift.assistent.name})",
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );

    return Column(
      children: [
        calendar,
        const SizedBox(height: 16),
        Expanded(
          child: _selectedShifts.isEmpty
              ? Center(child: Text("Keine Schichten für den ${_selectedDay.toLocal().toString().split(' ')[0]}"))
              : ListView.builder(
                  itemCount: _selectedShifts.length,
                  itemBuilder: (context, index) {
                    final shift = _selectedShifts[index];
                    return ListTile(
                      title: Text("${shift.start.hour}:${shift.start.minute} - ${shift.end.hour}:${shift.end.minute}"),
                      subtitle: Text("Assistent: ${shift.assistent.name}"),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
