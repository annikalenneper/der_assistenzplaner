import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/styles.dart';
import 'package:der_assistenzplaner/utils/cache.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/utils/step_data.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/shared/cards_and_markers.dart';
import 'package:der_assistenzplaner/views/shared/user_input_widgets.dart';
import 'package:der_assistenzplaner/views/shared/view_containers.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';


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

          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
                });
              }
            },
          );

          /// headline
          final headingForSelectedDay = Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(formatDateTime(_selectedDay), style: const TextStyle(fontSize: 20)),
          );
                

          /// shows scheduled shifts for selected day
          /// shows scheduled shifts for selected day and selected display option
        
        final shiftsForSelectedDay = shiftModel.shiftsByDay[(_selectedDay)] ?? [];

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
                      builder: (context) {
                        return PopUpBox(
                          view: DynamicStepper(
                            steps: addShiftStepData(_selectedDay),
                            onComplete: (inputs) =>
                                saveStepperInput(context, inputs, Type.shift),
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
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, 
                        child: Row(
                          children: assistantModel.assistants.map((assistant) {
                            return AssistantMarker(
                              assistantID: assistant.assistantID,
                              size: 40, 
                              onTap: (){},
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

