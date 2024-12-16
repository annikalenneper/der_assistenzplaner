import 'package:der_assistenzplaner/views/shared/small_custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:provider/provider.dart';

///WorkScheduleScreen
class WorkScheduleScreen extends StatelessWidget {
  //TO-DO: implement methods to pass different parameters to WorkScheduleView
  @override
  Widget build(BuildContext context) {
    final workscheduleModel = Provider.of<WorkscheduleModel>(context);
    return Center(
      child: Column(
        children: [
          CalendarView(wsModel: workscheduleModel),  
        ]
      ),
    );
  }
}

class CalendarView extends StatefulWidget {
  final WorkscheduleModel wsModel;

  //TO:DO: instead of using wsModel, use parameters to pass shifts, scheduledShifts and availabilities as lists (with methods implemented in models)
  CalendarView({required this.wsModel});
  
  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
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
      firstDay: wsModel.start, //TO-DO: change to oldest shift
      lastDay: wsModel.end,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      locale: 'de_DE',
      
      shouldFillViewport: true,
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

    /// shows scheduled shifts for selected day
    final scheduledShiftsView = Center(
      child: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('Schichten am $_selectedDay', style: TextStyle(fontSize: 18)),
          ),
          ValueListenableBuilder<List<ScheduledShift>>(
            valueListenable: _scheduledShiftsSelectedDay,
            builder: (context, workschedule, child) {
              return workschedule.isEmpty ? Text('Keine Schichten', textAlign: TextAlign.center,)
              : ListView.builder(
                shrinkWrap: true,
                itemCount: workschedule.length,
                itemBuilder: (context, index) {
                  final shift = workschedule[index];
                  return ShiftCard(shift: shift, assistantID: shift.assistantID);
                },
              );
            },            
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: IconButton(onPressed: (){}, icon: Icon(Icons.add), alignment: Alignment.center, padding: EdgeInsets.all(12)),
          ),
        ],
      ),
    );

    return 
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(flex: 3, child: calendar),
                  Flexible(flex:2, child: scheduledShiftsView),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Dein Team hat noch X Tage Zeit für die Abgabe der Verfügbarkeiten für \$nextMonth. \nZahl der eingegangenen Verfügbarkeiten: X"),
                  ),
                ),
              ],
             ),
            ],
          )
        );
      
    
  }
}