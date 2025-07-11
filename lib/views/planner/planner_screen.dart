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
            headerMargin: const EdgeInsets.only(bottom: 0, top: 8.0), 
            headerPadding: const EdgeInsets.only(bottom: 0.0),
          ),

          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.black),
            weekendStyle: TextStyle(color: Colors.black),
            
          ),
          
          calendarStyle: CalendarStyle(
            outsideDaysVisible: true,
            weekendTextStyle: TextStyle(color: Colors.grey.shade600),
            holidayTextStyle: TextStyle(color: Colors.red.shade600),
            
            // Kein cellMargin für nahtlose Gitterlinien
            cellMargin: const EdgeInsets.all(0),
            cellPadding: const EdgeInsets.all(8.0),
            
            // Marker-Konfiguration
            markersMaxCount: 0, // Deaktiviere Standard-Marker
            canMarkersOverflow: false,
          ),

          calendarBuilders: CalendarBuilders(
            // Standard-Tage mit Rahmen
            defaultBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(0), // Kein Margin für nahtlose Gitterlinien
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade200, // Mittelhelles Grau für Gitterlinien
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Tag-Nummer zentriert
                    Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    // Marker
                    Consumer<AvailabilitiesModel>(
                      builder: (context, availabilitiesModel, _) {
                        return buildDayMarker(context, day) ?? SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            },
            
            // Heute-Builder mit Rahmen
            todayBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: ModernBusinessTheme.primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Heute-Markierung (kleinerer Kreis)
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ModernBusinessTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Marker
                    Consumer<AvailabilitiesModel>(
                      builder: (context, availabilitiesModel, _) {
                        return buildDayMarker(context, day) ?? SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            },
            
            // Ausgewählter Tag-Builder mit Rahmen
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(0),
                child: Stack(
                  children: [
                    // Auswahl-Markierung (kleinerer Kreis)
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Marker
                    Consumer<AvailabilitiesModel>(
                      builder: (context, availabilitiesModel, _) {
                        return buildDayMarker(context, day) ?? SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            },
            
            // Außerhalb des Monats-Builder mit Rahmen
            outsideBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                        size: 26,
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
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: calendar,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
                    child: Consumer<AvailabilitiesModel>(
                      builder: (BuildContext context, availabilities, child) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              const SizedBox(height: 12),
                              
                              // AssistantMarker in Wrap-Layout
                              Consumer<AssistantModel>(
                                builder: (context, assistantModel, child) {
                                  return assistantModel.assistants.isEmpty 
                                    ? Text(
                                        'Keine Assistenten vorhanden',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: assistantModel.assistants.map((assistant) {
                                          // TODO: Hier sollte geprüft werden, ob der Assistant bereits eingereicht hat
                                          final hasSubmitted = true; // Platzhalter
                                          
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: hasSubmitted 
                                                    ? Colors.green.shade300 
                                                    : Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                AssistantMarker(
                                                  assistantID: assistant.assistantID,
                                                  size: 22,
                                                  onTap: () {},
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(right: 6),
                                                  child: Icon(
                                                    hasSubmitted 
                                                        ? Icons.check_circle 
                                                        : Icons.schedule,
                                                    size: 12,
                                                    color: hasSubmitted 
                                                        ? Colors.green.shade600 
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                },
                              ),
                              
                              // Fortschrittsbalken
                              const SizedBox(height: 8),
                              Consumer<AssistantModel>(
                                builder: (context, assistantModel, child) {
                                  final totalAssistants = assistantModel.assistants.length;
                                  final submittedCount = assistantModel.assistants.length; // TODO: Echte Logik
                                  final progress = totalAssistants > 0 ? submittedCount / totalAssistants : 0.0;
                                  
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Eingereichte Verfügbarkeiten',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            '$submittedCount von $totalAssistants',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          progress == 1.0 
                                              ? Colors.green.shade600 
                                              : Colors.blue.shade600,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        minHeight: 6,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
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

