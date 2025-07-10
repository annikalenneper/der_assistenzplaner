import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';

/// Erstellt für jeden Tag im aktuellen Monat eine Schicht
/// von 8:00 bis 16:00 Uhr und speichert diese über das ShiftModel.
Future<void> addCurrentMonthShifts(ShiftModel shiftModel) async {
  final now = DateTime.now();
  final int year = now.year;
  final int month = now.month;
  
  // Bestimme die Anzahl der Tage im aktuellen Monat
  final int daysInMonth = DateTime(year, month + 1, 0).day;
  
  for (int day = 1; day <= daysInMonth; day++) {
    DateTime shiftStart = DateTime(year, month, day, 8, 0);
    DateTime shiftEnd = DateTime(year, month, day, 16, 0);
    
    // Erstelle eine neue Schicht ohne zugewiesenen Assistenten (null)
    Shift newShift = shiftModel.createShift(shiftStart, shiftEnd, null);
    
    // Speichere die Schicht über das ShiftModel
    await shiftModel.saveShift(newShift);
  }
}