

import 'package:der_assistenzplaner/assistants.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';



//----------------- Shift -----------------

class Shift {
  DateTime start;
  DateTime end;

  Shift(this.start, this.end);
  
  Duration get duration => end.difference(start);
}




//----------------- ScheduledShift -----------------

class ScheduledShift extends Shift {
  final Assistant assistant;

  /// TO-DO: implement getter/setter-methods for conflicts
  var tagConflictPrio1 = false;
  var tagConflictPrio2 = false;
  var availabilityConflict1 = false;
  var availabilityConflict2 = false;

  ScheduledShift(super.start, super.end, this.assistant);
}

class Availability {
  final Shift shift;
  final Assistant assistant;

  const Availability(this.shift, this.assistant);
}




//----------------- Workschedule -----------------

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



//----------------- Workschedule-Model -----------------

class WorkscheduleModel extends ChangeNotifier {
  final Workschedule _workschedule;

  WorkscheduleModel(this._workschedule);

  DateTime getStart() {
    return _workschedule.start;
  }

  DateTime getEnd() {
    return _workschedule.end;
  }

  void addShift(ScheduledShift shift) {
    _workschedule.addShift(shift);
    notifyListeners(); // Widgets benachrichtigen
  }

  List<ScheduledShift> getScheduledShiftsByDay(DateTime day) {
    return _workschedule.getScheduledShiftsByDay(day);
  }
}



//----------------- Workschedule-View -----------------


class WorkScheduleView extends StatefulWidget {
  final WorkscheduleModel wsModel;

  WorkScheduleView({required this.wsModel});
  
  @override
  WorkScheduleViewState createState() => WorkScheduleViewState();
}

class WorkScheduleViewState extends State<WorkScheduleView> {
  WorkscheduleModel? wsModel;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  late final ValueNotifier<List<ScheduledShift>> _scheduledShiftsSelectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override 
  void initState() {
    super.initState();
    _scheduledShiftsSelectedDay = ValueNotifier(widget.wsModel.getScheduledShiftsByDay(_focusedDay));
  }
  
  @override
  Widget build(BuildContext context) {
    final wsModel = widget.wsModel;
    
    final calendar = TableCalendar(
      firstDay: wsModel.getStart(),
      lastDay: wsModel.getEnd(),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      
      headerVisible: true,
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),

      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.black),
        weekendStyle: TextStyle(color: Colors.black),
      ),
      
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.pink,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        canMarkersOverflow: true,
      ),


      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },

      eventLoader: (day) {
        return wsModel.getScheduledShiftsByDay(day);
      },

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _scheduledShiftsSelectedDay.value = wsModel.getScheduledShiftsByDay(selectedDay);

        });
      },

      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
    );

    var scheduledShiftsView = 
      ValueListenableBuilder<List<ScheduledShift>>(
        valueListenable: _scheduledShiftsSelectedDay,
        builder: (context, workschedule, child) {
          return workschedule.isEmpty ? Text ('Keine Schichten') 
          : Center(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: workschedule.length,
              itemBuilder: (context, index) {
                final shift = workschedule[index];
                return ListTile(
                  title: Text(shift.assistant.name),
                  subtitle: Text('${shift.start} - ${shift.end}'),
                );
              },
            ),
          );
        },
      );

    return Column(
      children: [
        calendar,
        scheduledShiftsView,
      ],
    );
  }
}





