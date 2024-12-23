import 'dart:developer';

import 'package:der_assistenzplaner/models/assistant.dart';
import 'package:der_assistenzplaner/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:provider/provider.dart';




/// ------------------------- Enumerations -------------------------
enum Type {assistant, shift}


/// ------------------------- Dynamic Database Methods -------------------------

void saveStepperInput(context, Map<String, dynamic> inputs, Type type) {
  if (type == Type.assistant) {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final newAssistant = Assistant(inputs['name'],inputs['contractedHours']);
    assistantModel.saveNewAssistant(newAssistant);
    final color = inputs['color'];
    assistantModel.assignColor(newAssistant.assistantID, color);
    log('Assistant saved to database: $newAssistant, color: $color');
  } else if (type == Type.shift) {
    final shiftModel = Provider.of<ShiftModel>(context, listen: false);
    final newShift = Shift(inputs['start'], inputs['end'], inputs['assistantID']);
    shiftModel.saveShift(newShift);
  }
}


//------------------------- Generic Sorting Algorithm -------------------------

/// inserts elements sorted into a list
void insertSorted<T>(List<T> list, T element, int Function(T a, T b) compare) {

  /// find index where to insert element
  int index = list.indexWhere((e) => compare(element, e) < 0);
  /// if no element found that is greater than the current element, insert at end
  if (index == -1) {
    list.add(element);
  } else {
    list.insert(index, element);
  }
}


//------------------------- Time Formatting -------------------------


String getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mo';
      case DateTime.tuesday:
        return 'Di';
      case DateTime.wednesday:
        return 'Mi';
      case DateTime.thursday:
        return 'Do';
      case DateTime.friday:
        return 'Fr';
      case DateTime.saturday:
        return 'Sa';
      case DateTime.sunday:
        return 'So';
      default:
        return '';
    }
  }

  // Formatierte Strings für Start- und Endzeit
  String formatDateTime(DateTime dateTime) {
    final weekday = getWeekdayName(dateTime.weekday);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$weekday, $day.$month.$year $hour:$minute Uhr';
  }
