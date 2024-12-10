import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:provider/provider.dart';

///WorkScheduleScreen
class WorkScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workscheduleModel = Provider.of<WorkscheduleModel>(context);
    return Center(
      child: Column(
        children: [
          WorkScheduleView(wsModel: workscheduleModel),  
        ]
      ),
    );
  }
}

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
      firstDay: wsModel.start,
      lastDay: wsModel.end,
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

      eventLoader: (day) => wsModel.getScheduledShiftsByDay(day),

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
                  title: Text(shift.assistantID),
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