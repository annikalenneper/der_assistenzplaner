import 'package:der_assistenzplaner/styles/styles.dart';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/shared/markers.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' hide normalizeDate;
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/planner/shift_usecases.dart' as planner;


class CalendarView extends StatefulWidget {
  CalendarView({super.key});

  @override
  State<CalendarView> createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  static final _defaultFirstDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
  static final _defaultLastDay = lastDayOfMonth(DateTime.now());

  MarkerCache markerCache = MarkerCache();

  @override
  Widget build(BuildContext context) {
    return Consumer<ShiftModel>(
      builder: (context, shiftModel, child) {
        final assistantModel = Provider.of<AssistantModel>(context);

        final calendar = TableCalendar(

          firstDay: _defaultFirstDay, 
          lastDay: _defaultLastDay, 
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
              color: ModernBusinessTheme.primaryColor.withValues(), 
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: ModernBusinessTheme.primaryColor, 
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
            canMarkersOverflow: true,
          ),

          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) => buildDayMarker(context, day, shiftModel) 
          ),

          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },

          eventLoader: (day) => shiftModel.shiftsByDay[(day)] ?? [],

        );

        /// headline
        final headingForSelectedDay = Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(formatDateTime(_selectedDay), style: const TextStyle(fontSize: 20)),
        );        

        /// shows scheduled shifts for selected day         
        final normalizedSelectedDay = normalizeDate(_selectedDay);
        final shiftsForSelectedDay = shiftModel.shiftsByDay[(normalizedSelectedDay)] ?? [];

        final scrollableListOfShifts = SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                itemCount: shiftsForSelectedDay.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final shift = shiftsForSelectedDay[index];
                  return ShiftCard(
                    shift: shift,
                    assistantID: shift.assistantID ?? '',
                  );
                },
              ),

              /// + Button
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),
                  onPressed: () {
                    showDialog(
                      context: context, 
                      builder:
                       (context) {
                        return AlertDialog(
                          content: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: planner.ShiftForm(
                              selectedDay: _selectedDay,
                              onSave: (start, end, assistantID) {
                                final newShift = shiftModel.createShift(start, end, assistantID);
                                shiftModel.saveShift(newShift);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),
        );


        final scheduledShiftsView = Column(
          children: [
            headingForSelectedDay,         
            Expanded(child: scrollableListOfShifts), 
          ],
        );

        return Row(     
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
                      child: Consumer<AvailabilitiesModel>(
                        builder: (BuildContext context, availabilities, child) {  
                          return Text (
                            'Dein Team hat noch ${availabilities.daysUntilAvailabilitiesDueDate} Tage Zeit für die Abgabe der Verfügbarkeiten. \nZahl der eingetragenen Verfügbarkeiten: X',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
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
                  /// row of assistant markers to select all shifts for one assistant
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, 
                      child: Row(
                        children: assistantModel.assistants.map((assistant) {
                          return AssistantMarker(
                            assistantID: assistant.assistantID,
                            size: 40, 
                            onTap: (){
                              shiftModel.updateDisplayOption(ShiftDisplayOptions.assistant, assistant.assistantID);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],      
        );   
      },
    );
  }
}

