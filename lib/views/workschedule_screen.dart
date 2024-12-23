import 'package:der_assistenzplaner/styles.dart';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/utils/step_data.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/viewmodels/workschedule_model.dart';
import 'package:der_assistenzplaner/views/shared/small_custom_widgets.dart';
import 'package:der_assistenzplaner/views/shared/user_input_widgets.dart';
import 'package:der_assistenzplaner/views/shared/view_containers.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:provider/provider.dart';


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
        final MarkerCache markerCache = MarkerCache();

  @override
  void initState() {
    super.initState();
    /// initialize as empty list
    _scheduledShiftsSelectedDay = ValueNotifier([]);
  }

  /// safe use of provider after build
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ShiftModel shiftModel = Provider.of<ShiftModel>(context, listen: false);
    /// listens to changes in selected days shifts
    _scheduledShiftsSelectedDay.value = shiftModel.getShiftsByDay(_selectedDay!);
  }
  
  @override
  Widget build(BuildContext context) {
    final AssistantModel assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final calendar = TableCalendar(
      firstDay: DateTime(2024, 12, 1), //TO-DO: change to first day of month of oldest shift
      lastDay: DateTime(2024, 12, 30),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
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
          color: ModernBusinessTheme.primaryColor.withOpacity(0.5), 
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: ModernBusinessTheme.primaryColor, 
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        canMarkersOverflow: true,
      ),

      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },

      eventLoader: (day) {
        final workscheduleModel = Provider.of<WorkscheduleModel>(context, listen: false);
        return workscheduleModel.selectDisplayedShifts(
          context,
          workscheduleModel.selectedDisplayOption
          /// filter given list by day
        ).where((shift) => isSameDay(shift.start, day)).toList();
      },


      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          final shiftModel = Provider.of<ShiftModel>(context, listen: false);
          _scheduledShiftsSelectedDay.value = shiftModel.getShiftsByDay(_selectedDay!);
        });
      },

    calendarBuilders: CalendarBuilders(
      markerBuilder: (context, day, events) {
        if (events.isNotEmpty) {      
          final withAssistantID = events
              .where((event) => event is Shift && event.assistantID != '')
              .map((event) => (event as Shift).assistantID)
              .toSet();
          final withoutAssistantID = events
              .where((event) => event is Shift && event.assistantID == '')
              .toSet();
          return markerCache.getMarker(day, withAssistantID, withoutAssistantID);
        }
        return const SizedBox.shrink();
      },
    ),

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
            builder: (context, shifts, child) {
              return shifts.isEmpty ? Text('Keine Schichten', textAlign: TextAlign.center,)
              : ListView.builder(
                shrinkWrap: true,
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
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
              onPressed: () { showDialog(
                context: context, 
                builder: (context) {
                  return PopUpBox(
                    view:  DynamicStepper(
                        steps: addShiftStepData(_selectedDay!),
                        onComplete: (inputs) => saveStepperInput(context, inputs, Type.shift),
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
      Row(
        children: [
          /// left side
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: calendar
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text ('Dein Team hat noch X Tage Zeit für die Abgabe der Verfügbarkeiten. \nZahl der eingetragenen Verfügbarkeiten: X', style: TextStyle(fontSize: 12),),
                  ),
                )
              ],
            )
          ),
          /// right side
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: scheduledShiftsView,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, 
                    child: Row(
                      children: assistantModel.assistants.map((assistant) {
                        return AssistantMarker(
                          assistantID: assistant.assistantID,
                          size: 40, 
                        );
                      }
                    ).toList(),                      
                  ),
                ),
              ),
            ],
          ),
        ),      
      ],
    );
  }
}

