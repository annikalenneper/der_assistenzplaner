import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/utils/step_data.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/shared/small_custom_widgets.dart';
import 'package:der_assistenzplaner/views/shared/stepper.dart';
import 'package:der_assistenzplaner/views/shared/view_containers.dart';
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
  State<CalendarView> createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  DateTime? _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late final ValueNotifier<List<Shift>> _scheduledShiftsSelectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  /// safe use of provider after build
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
    /// listens to changes in selected days shifts
    _scheduledShiftsSelectedDay = ValueNotifier(shiftModel.getShiftsByDay(_selectedDay!));
  }
  
  @override
  Widget build(BuildContext context) {
    final calendar = TableCalendar(
      firstDay: DateTime(2024, 12, 1), //TO-DO: change to oldest shift
      lastDay: DateTime(2024, 12, 30),
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

      eventLoader: (day) {
        final shiftModel = Provider.of<ShiftModel>(context);
        return shiftModel.getShiftsByDay(day);
      },

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          final shiftModel = Provider.of<ShiftModel>(context, listen: false);
          _scheduledShiftsSelectedDay.value = shiftModel.getShiftsByDay(_selectedDay!);
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
          ValueListenableBuilder<List<Shift>>(
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
            child: IconButton(   
              icon: Icon(Icons.add), 
              alignment: Alignment.center, 
              padding: EdgeInsets.all(12),
              onPressed: () {
                  showDialog(
                  context: context, 
                  builder: (context) {
                    return PopUpBox(
                      view:  DynamicStepper(
                        steps: addShiftStepData(),
                        onComplete: (inputs) => saveToDatabase(context, inputs, Type.shift),
                      ),
                    );
                  }, 
                );
              },
            ),
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