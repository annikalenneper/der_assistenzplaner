import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/workschedule.dart';
import 'package:der_assistenzplaner/models/shift.dart';

/// create test workschedule with two assistents and three shifts
Workschedule createTestWorkSchedule() {
  Assistant assistent1 = Assistant("Max Mustermann");
  Assistant assistent2 = Assistant("Anna Müller");

  ScheduledShift shift1 = ScheduledShift(
    DateTime(2024, 12, 23, 9, 0), 
    DateTime(2024, 12, 24, 17, 0), 
    assistent1,
  );

  ScheduledShift shift2 = ScheduledShift(
    DateTime(2024, 12, 24, 14, 0), 
    DateTime(2024, 12, 24, 22, 0), 
    assistent2,
  );

  ScheduledShift shift3 = ScheduledShift(
    DateTime(2024, 12, 23, 18, 0), 
    DateTime(2024, 12, 23, 22, 0), 
    assistent2,
  );

  ScheduledShift shift4 = ScheduledShift(
    DateTime(2024, 12, 23, 18, 0), 
    DateTime(2024, 12, 23, 22, 0), 
    assistent2,
  );

  Workschedule workschedule = Workschedule(
    DateTime(2024, 12, 1),  
    DateTime(2024, 12, 30), 
  );


  workschedule.addShift(shift1);
  workschedule.addShift(shift2);
  workschedule.addShift(shift3);
  workschedule.addShift(shift4);

  return workschedule;
}

