import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
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
    return Center(
      child: Column(
        children: [
          CalendarView(),  
        ]
      ),
    );
  }
}

class CalendarView extends StatefulWidget {
  CalendarView({super.key});
  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  DateTime? _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late final ValueNotifier<List<ScheduledShift>> _scheduledShiftsSelectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  /// safe use of provider after build
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
    _scheduledShiftsSelectedDay = ValueNotifier(shiftModel.getScheduledShiftsByDay(_selectedDay!));
  }
  
  @override
  Widget build(BuildContext context) {
    WorkscheduleModel wsModel = Provider.of<WorkscheduleModel>(context, listen: false);
    var selectDisplayedShifts = DisplayShifts.scheduled;
    
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
      
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.pink,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        canMarkersOverflow: true,
      ),


      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },

      eventLoader: (day) => wsModel.selectDisplayedShifts(context, selectDisplayedShifts),

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _scheduledShiftsSelectedDay.value = wsModel.selectDisplayedShifts(context, selectDisplayedShifts);
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
            child: Text('Schichten am ${_selectedDay!.day.toString().padLeft(2, '0')}.${_selectedDay!.month.toString().padLeft(2, '0')}.${_selectedDay!.year}', style: TextStyle(fontSize: 18)),
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