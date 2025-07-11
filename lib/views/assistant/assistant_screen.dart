import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/views/assistant/assistant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/views/assistant/assistant_usecases.dart';


//----------------- AssistantPage -----------------

/// main view for the assistant management
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late int _selectedIndex;
  late bool _showTeamSidebar;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _showTeamSidebar = _selectedIndex == 1;
    
    // Wenn Team angezeigt wird, aber kein Assistent ausgewählt ist, setze currentAssistant auf null
    if (_selectedIndex == 1) {
      Future.microtask(() {
        Provider.of<AssistantModel>(context, listen: false).deselectAssistant();
      });
    }
  }

  Widget build(BuildContext context) {
    return Consumer<AssistantModel>(
      builder: (context, assistantModel, child) {
        if (assistantModel.currentAssistant != null) {
          return AssistantDetailView();
        } else {
          return Center(
            child: Text(
              'Wähle eine Assistenzkraft aus',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }
      },
    );
  }
}

//----------------- AssistantListView -----------------	

class AssistantListView extends StatefulWidget {
  /// pass callback function from AssistantPage to AssistantListView
  final Function(int) changePageViewIndex;

  const AssistantListView({required this.changePageViewIndex, super.key});

  @override
  State<AssistantListView> createState() => _AssistantListViewState();
}

class _AssistantListViewState extends State<AssistantListView> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantModel>(
      builder: (context, assistantModel, child) {
        return Scaffold(
            body: SizedBox(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: assistantModel.assistants.length,
                          itemBuilder: (context, index) {
                            /// get individual assistants from assistantModel assistants list
                            var assistant = assistantModel.assistants.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                assistantModel.selectAssistant(assistant.assistantID);
                                widget.changePageViewIndex(1);
                              },
                              child: AssistantCard(assistantID: assistant.assistantID,)
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Neue Assistenzkraft hinzufügen'),
                              content: AddAssistantForm(
                                onSave: (name, hours, color) {
                                  final newAssistant = assistantModel.createAssistant(name, hours);
                                  assistantModel.saveAssistant(newAssistant);
                                  assistantModel.assignColor(newAssistant.assistantID, color);
                                },
                              ),
                            );
                          }, 
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}
    


//----------------- AssistantDetailView -----------------

class AssistantDetailView extends StatefulWidget {
  AssistantDetailView({super.key});

  @override
  State<AssistantDetailView> createState() => _AssistantDetailViewState();
}

class _AssistantDetailViewState extends State<AssistantDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AssistantModel, ShiftModel, AvailabilitiesModel>(
      builder: (context, assistantModel, shiftModel, availabilitiesModel, child) {
        final assistant = assistantModel.currentAssistant!;
        final assistantColor = assistantModel.assistantColorMap[assistant.assistantID] ?? Colors.grey;
        
        // Korrigierte Methodenaufrufe
        final assignedShifts = shiftModel.mapOfShiftsByAssistant[assistant.assistantID]?.toList() ?? [];
        final availabilities = availabilitiesModel.getAvailabilitiesByAssistant(assistant.assistantID).toList();
        
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: assistantColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Name und Stunden
                    Text(
                      assistant.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${assistant.contractedHours} Std/Woche', // Korrigiert von hours zu contractedHours
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Statistik Cards
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Geplante Schichten',
                        '${assignedShifts.length}',
                        Icons.event,
                        Colors.blue.shade600,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Verfügbarkeiten',
                        '${availabilities.length}',
                        Icons.event_available,
                        Colors.green.shade600,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Abweichung',
                        '${assistant.deviation.toStringAsFixed(1)}h', // Korrigiert von formattedDeviation
                        Icons.trending_up,
                        assistant.deviation >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: assistantColor,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: assistantColor,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.event),
                      text: 'Schichten',
                    ),
                    Tab(
                      icon: Icon(Icons.event_available),
                      text: 'Verfügbarkeiten',
                    ),
                    Tab(
                      icon: Icon(Icons.label),
                      text: 'Tags',
                    ),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Schichten Tab
                    _buildShiftsTab(assignedShifts, assistantColor),
                    
                    // Verfügbarkeiten Tab
                    _buildAvailabilitiesTab(availabilities, shiftModel, assistantColor),
                    
                    // Tags Tab
                    _buildTagsTab(assistant, assistantModel, assistantColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsTab(List<dynamic> shifts, Color assistantColor) {
    if (shifts.isEmpty) {
      return _buildEmptyState(
        'Keine Schichten zugewiesen',
        'Dieser Assistent hat noch keine Schichten zugewiesen bekommen.',
        Icons.event_busy,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        final shift = shifts[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: assistantColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: assistantColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${shift.start.day}.${shift.start.month}.${shift.start.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')} - ${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: assistantColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${((shift.end.difference(shift.start).inMinutes) / 60).toStringAsFixed(1)}h',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: assistantColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailabilitiesTab(List<dynamic> availabilities, ShiftModel shiftModel, Color assistantColor) {
    if (availabilities.isEmpty) {
      return _buildEmptyState(
        'Keine Verfügbarkeiten',
        'Dieser Assistent hat noch keine Verfügbarkeiten eingereicht.',
        Icons.event_available,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: availabilities.length,
      itemBuilder: (context, index) {
        final availability = availabilities[index];
        final shift = shiftModel.getShiftById(availability.shiftID); // Korrigiert von getShiftByID zu getShiftById
        
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_available,
                  color: Colors.green.shade600,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift != null 
                        ? '${shift.start.day}.${shift.start.month}.${shift.start.year}'
                        : 'Schicht nicht gefunden',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (shift != null) ...[
                      SizedBox(height: 4),
                      Text(
                        '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')} - ${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagsTab(dynamic assistant, AssistantModel assistantModel, Color assistantColor) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zugewiesene Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showTagDialog(context, assistant, assistantModel);
                },
                icon: Icon(Icons.add, size: 18),
                label: Text('Tag hinzufügen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: assistantColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          assistant.tags.isEmpty
            ? _buildEmptyState(
                'Keine Tags zugewiesen',
                'Füge Tags hinzu, um die Fähigkeiten und Eigenschaften dieses Assistenten zu kennzeichnen.',
                Icons.label_off,
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: assistant.tags.map<Widget>((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: assistantColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: assistantColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag.toString(),
                          style: TextStyle(
                            color: assistantColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // TODO: Remove tag logic
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: assistantColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic assistant, AssistantModel assistantModel) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            SizedBox(width: 8),
            Text('Warnung!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Möchtest du ${assistant.name} wirklich endgültig löschen?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('Alle Daten, die mit der Assistenzkraft zusammenhängen, gehen beim Löschen verloren.'),
            SizedBox(height: 8),
            Text('Du kannst die Assistenzkraft stattdessen auch archivieren. Sie ist dann nicht mehr in der Teamübersicht sichtbar, bleibt jedoch im Archiv erhalten.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Archive logic
              Navigator.of(context).pop();
            },
            child: Text('Archivieren'),
          ),
          ElevatedButton(
            onPressed: () {
              assistantModel.deleteAssistant(assistant.assistantID);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${assistant.name} erfolgreich gelöscht.')),
              );
              Navigator.of(context).pop();
              assistantModel.deselectAssistant();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
            ),
            child: Text('Endgültig löschen', style: TextStyle(color: Colors.white)),
          ),
        ],  
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, dynamic assistant, AssistantModel assistantModel) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.archive, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Text('Archivieren'),
          ],
        ),
        content: Text('Möchtest du ${assistant.name} archivieren? Die Assistenzkraft wird nicht mehr in der Teamübersicht angezeigt, bleibt aber im Archiv erhalten.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Archive logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${assistant.name} wurde archiviert.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              elevation: 0,
            ),
            child: Text('Archivieren', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTagDialog(BuildContext context, dynamic assistant, AssistantModel assistantModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Tag zuordnen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tag-Auswahl wird hier implementiert'),
            // TODO: Tag selection logic
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save tag logic
              Navigator.of(context).pop();
            },
            child: Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}

class TeamSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantModel>(
      builder: (context, assistantModel, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Neue Assistenzkraft hinzufügen'),
                              content: AddAssistantForm(
                                onSave: (name, hours, color) {
                                  final newAssistant = assistantModel.createAssistant(name, hours);
                                  assistantModel.saveAssistant(newAssistant);
                                  assistantModel.assignColor(newAssistant.assistantID, color);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: assistantModel.assistants.length,
                  itemBuilder: (context, index) {
                    var assistant = assistantModel.assistants.elementAt(index);
                    return AssistantSidebarCard(
                      assistantID: assistant.assistantID,
                      onTap: () {
                        assistantModel.currentAssistant = assistant;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AssistantSidebarCard extends StatelessWidget {
  final String assistantID;
  final VoidCallback onTap;

  const AssistantSidebarCard({
    super.key,
    required this.assistantID,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assistantModel = Provider.of<AssistantModel>(context);
    final assistant = assistantModel.assistantMap[assistantID];
    final name = assistant?.name ?? 'Unbekannt';
    final deviation = assistant?.formattedDeviation ?? 'Unbekannt';
    final color = assistantModel.assistantColorMap[assistantID] ?? Colors.grey;

    return Card(
      elevation: assistantModel.currentAssistant?.assistantID == assistantID ? 8 : 1,
      color: assistantModel.currentAssistant?.assistantID == assistantID 
          ? Theme.of(context).colorScheme.primaryContainer 
          : null,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text(deviation),
        onTap: () {
          assistantModel.selectAssistant(assistantID);
          onTap();
        },
      ),
    );
  }
}

