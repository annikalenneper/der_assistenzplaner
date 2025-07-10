import 'package:der_assistenzplaner/styles/styles.dart';
import 'package:der_assistenzplaner/utils/helper_functions.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/planner/shift_card.dart';
import 'package:der_assistenzplaner/views/shared/markers.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' hide normalizeDate;
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/views/planner/shift_form.dart' as planner;


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


  @override
  Widget build(BuildContext context) {
    return Consumer<ShiftModel>(
      builder: (context, shiftModel, child) {
        final assistantModel = Provider.of<AssistantModel>(context);

        final calendar = TableCalendar(
          key: ValueKey(shiftModel.shiftsByDay.hashCode), // TODO: check if this is necessary
          firstDay: _defaultFirstDay, 
          lastDay: _defaultLastDay, 
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'de_DE',    
          shouldFillViewport: true,
          headerVisible: true,

          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: Theme.of(context).textTheme.headlineSmall!, 
            headerMargin: const EdgeInsets.only(bottom: 22.0), 
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
            markerBuilder: (context, day, events) => buildDayMarker(context, day) 
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

          eventLoader: (day) {
            final normalizedDay = normalizeDate(day);
            return shiftModel.shiftsByDay[normalizedDay] ?? [];
          },
        );

        /// scheduled shifts for selected day for the right side view      
        final normalizedSelectedDay = normalizeDate(_selectedDay);
        final shiftsForSelectedDay = shiftModel.shiftsByDay[(normalizedSelectedDay)] ?? [];
        shiftsForSelectedDay.sort((a, b) => a.start.compareTo(b.start));

        final shiftsView = Column(
          children: [
            // Header mit Datum und Add-Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(_selectedDay),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      showDialog(
                        context: context, 
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Neue Schicht'),
                            content: SizedBox(
                              width: 400,
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
                    },
                  ),
                ],
              ),
            ),
            // Scrollable Shifts Liste
            Expanded(
              child: shiftsForSelectedDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Keine Schichten geplant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: shiftsForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final shift = shiftsForSelectedDay[index];
                        return ShiftCard(
                          shift: shift,
                        );
                      },
                    ),
            ),
            // Assistant Markers Footer
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: assistantModel.assistants.map((assistant) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: AssistantMarker(
                        assistantID: assistant.assistantID,
                        size: 32,
                        onTap: () {
                          shiftModel.updateDisplayOption(ShiftDisplayOptions.assistant, assistant.assistantID);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
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
                    padding: const EdgeInsets.all(12.0),
                    child: Consumer<AvailabilitiesModel>(
                      builder: (BuildContext context, availabilities, child) {
                        return Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Dein Team hat noch ${availabilities.daysUntilAvailabilitiesDueDate} Tage Zeit für die Abgabe der Verfügbarkeiten.\nZahl der eingetragenen Verfügbarkeiten: X',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            ),

            /// right side
            Expanded(
              flex: 2,
              child: shiftsView,
            ),
          ],      
        );   
      },
    );
  }
}

