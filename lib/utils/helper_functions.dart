import 'dart:developer';

import 'package:der_assistenzplaner/data/models/assistant.dart';
import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


//------------------------- Shared Calculations -------------------------

Duration calculateTimeOfDayDuration(TimeOfDay start, TimeOfDay end) {
  int hours = end.hour - start.hour;
  int minutes = end.minute - start.minute;
  /// add 24 hours if end time is before start time
  if (hours < 0 || (hours == 0 && minutes < 0)) {
    hours += 24;
  }
  /// add 60 minutes if end minutes are before start minutes
  if (minutes < 0) {
    hours -= 1;
    minutes += 60;
  }
  return Duration(hours: hours, minutes: minutes);
}

double calculateShiftDuration(Shift shift) {
  return shift.end.difference(shift.start).inMinutes / 60;
}

DateTime lastDayOfMonth(DateTime dateTime) {
  DateTime firstDayNextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);
  return firstDayNextMonth.subtract(Duration(days: 1));
} 


//------------------------- Shared Methods -------------------------

enum Type {assistant, shift}

/// saves input from dynamic stepper according to type
void saveStepperInput(context, Map<String, dynamic> inputs, Type type) {
  if (type == Type.assistant) {
    final assistantModel = Provider.of<AssistantModel>(context, listen: false);
    final newAssistant = Assistant(inputs['name'],inputs['contractedHours']);
    assistantModel.saveAssistant(newAssistant);
    final color = inputs['color'];
    assistantModel.assignColor(newAssistant.assistantID, color);
    log('Assistant saved to database: $newAssistant, color: $color');
  } else if (type == Type.shift) {
    final shiftModel = Provider.of<ShiftModel>(context, listen: false);
      try {
        if (Shift.isValidShift(inputs['start'], inputs['end'])) {
          final newShift = Shift(inputs['start'], inputs['end'], inputs['assistantID']);
          shiftModel.saveShift(newShift);
        } 
      } catch (e) {
        log('Failed to save shift: $e');
      }
  }
}


/// inserts generic elements sorted into a list
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


/// normalizes DateTime to date without time
DateTime normalizeDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

/// fotmatted as 'Mo, 01.01.2021 08:00 Uhr'
String formatDateTime(DateTime dateTime) {
  final weekday = dayOfWeekToString(dateTime.weekday);
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year;
  return '$weekday, $day.$month.$year';
}

/// formatted as '08:00'
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// convert TimeOfDay to DateTime
DateTime timeOfDayToDateTime(TimeOfDay time, DateTime date) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// convert DateTime to TimeOfDay
TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

/// convert DateTime.weekday (int) to String
String dayOfWeekToString(int day)
{
  switch (day) {
    case 1:
      return 'Montag';
    case 2:
      return 'Dienstag';
    case 3:
      return 'Mittwoch';
    case 4:
      return 'Donnerstag';
    case 5:
      return 'Freitag';
    case 6:
      return 'Samstag';
    case 7:
      return 'Sonntag';
    default:
      return '';
  }
}

//------------------------- Comparators -------------------------


bool isBefore(TimeOfDay first, TimeOfDay second) {
  if (first.hour < second.hour) {
    return true;
  } else if (first.hour == second.hour && first.minute < second.minute) {
    return true;
  }
  return false;
}

bool isAfter(TimeOfDay first, TimeOfDay second) {
  if (first.hour > second.hour) {
    return true;
  } else if (first.hour == second.hour && first.minute > second.minute) {
    return true;
  }
  return false;
}