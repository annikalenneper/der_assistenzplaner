import 'package:der_assistenzplaner/services/workschedule_service.dart';
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
            // Generierungs-Info Footer (ohne Marker)
            Container(
              padding: const EdgeInsets.all(16.0), // Mehr Padding
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1.5), // Dickerer Border
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0), // Noch mehr inneres Padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12), // Größere Rundungen
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Größeres Info Icon mit Hintergrund
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24, // Größeres Icon
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Info Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Automatische Dienstplan-Generierung',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16, // Größere Schrift
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nächste automatische Generierung: ${_getNextGenerationDate()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Alle offenen Schichten werden optimal an verfügbare Assistenten verteilt.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Generieren Button (größer und präsenter)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _generateScheduleNow(context, shiftModel);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          elevation: 3,
                          shadowColor: Colors.blue.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.play_arrow, size: 18),
                        label: Text(
                          'Dienstplan jetzt generieren',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                          padding: const EdgeInsets.all(8.0), // Mehr Padding
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
                                          
                              // AssistantMarker in weißem Container - nur für Assistenten mit Verfügbarkeiten
                              Consumer<AssistantModel>(
                                builder: (context, assistantModel, child) {
                                  // Filtere Assistenten, die bereits Verfügbarkeiten eingereicht haben
                                  final assistantsWithAvailabilities = assistantModel.assistants
                                      .where((assistant) => 
                                          availabilities.availabilitiesByAssistant[assistant.assistantID]?.isNotEmpty ?? false)
                                      .toList();
                                  
                                  return assistantsWithAvailabilities.isEmpty 
                                    ? Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Noch keine Verfügbarkeiten eingereicht',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: assistantsWithAvailabilities.map((assistant) {
                                            final availabilityCount = availabilities
                                                .availabilitiesByAssistant[assistant.assistantID]?.length ?? 0;
                                            
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.green.shade300,
                                                  width: 1.5,
                                                ),
                                                color: Colors.green.shade50,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AssistantMarker(
                                                    assistantID: assistant.assistantID,
                                                    size: 20,
                                                    onTap: () {
                                                      shiftModel.updateDisplayOption(
                                                        ShiftDisplayOptions.assistant, 
                                                        assistant.assistantID
                                                      );
                                                    },
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '$availabilityCount',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.green.shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                },
                              ),
                              
                              // Fortschrittsbalken
                              const SizedBox(height: 12),
                              Consumer<AssistantModel>(
                                builder: (context, assistantModel, child) {
                                  final totalAssistants = assistantModel.assistants.length;
                                  
                                  // Zähle Assistenten mit eingereichten Verfügbarkeiten
                                  final submittedCount = assistantModel.assistants
                                      .where((assistant) => 
                                          availabilities.availabilitiesByAssistant[assistant.assistantID]?.isNotEmpty ?? false)
                                      .length;
                                  
                                  final progress = totalAssistants > 0 ? submittedCount / totalAssistants : 0.0;
                                  
                                  return Column(
                                    children: [                         
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
                                      if (progress == 1.0) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.green.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                            '$submittedCount von $totalAssistants Verfügbarkeitsangaben eingegangen',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: progress == 1.0 
                                                  ? Colors.green.shade700 
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                          ],
                                        ),
                                      ],
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

  // Hilfsmethode für das nächste Generierungsdatum
  String _getNextGenerationDate() {
    // TODO: Hier sollte die echte Logik für das nächste Generierungsdatum stehen
    final nextMonth = DateTime.now().month == 12 
        ? DateTime(DateTime.now().year + 1, 1, 25)
        : DateTime(DateTime.now().year, DateTime.now().month + 1, 25);
    
    return '${nextMonth.day}.${nextMonth.month.toString().padLeft(2, '0')}.${nextMonth.year}';
  }

  // Methode für die manuelle Generierung
  void _generateScheduleNow(BuildContext context, ShiftModel shiftModel) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text('Dienstplan generieren'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Möchtest du jetzt den Dienstplan für den kommenden Monat generieren?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bestehende Planungen könnten überschrieben werden.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              // WICHTIG: Dialog schließen und context sichern BEVOR async Operation
              Navigator.of(dialogContext).pop();
              
              // Sichere den ursprünglichen context VOR der async Operation
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Zeige sofort die "wird generiert" Nachricht
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Generiere Dienstplan...')),
              );
              
              try {
                final service = WorkscheduleService(context);
                final result = await service.generateWorkschedule();
                
                // Verwende den gesicherten ScaffoldMessenger
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ ${result.length} Schichten erfolgreich zugewiesen'),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              } catch (e) {
                // Verwende den gesicherten ScaffoldMessenger
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('❌ Fehler bei der Generierung: $e'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Generieren'),
          ),
        ],
      ),
    );
  }
}

