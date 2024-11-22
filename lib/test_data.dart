import 'package:der_assistenzplaner/assistents.dart';
import 'package:der_assistenzplaner/workschedules.dart';

/// create test workschedule with two assistents and three shifts
Workschedule createTestWorkSchedule() {
  Assistent assistent1 = Assistent("Max Mustermann");
  Assistent assistent2 = Assistent("Anna Müller");

  ScheduledShift shift1 = ScheduledShift(
    DateTime(2024, 11, 23, 9, 0), 
    DateTime(2024, 11, 23, 17, 0), 
    assistent1,
  );

  ScheduledShift shift2 = ScheduledShift(
    DateTime(2024, 11, 24, 14, 0), 
    DateTime(2024, 11, 24, 22, 0), 
    assistent2,
  );

  ScheduledShift shift3 = ScheduledShift(
    DateTime(2024, 11, 23, 18, 0), 
    DateTime(2024, 11, 23, 22, 0), 
    assistent2,
  );

  Workschedule workschedule = Workschedule(
    DateTime(2024, 11, 1),  
    DateTime(2024, 11, 30), 
  );


  workschedule.addShift(shift1);
  workschedule.addShift(shift2);
  workschedule.addShift(shift3);

  return workschedule;
}
