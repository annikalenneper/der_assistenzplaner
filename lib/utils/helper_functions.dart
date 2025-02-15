
import 'package:flutter/material.dart';


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

int calculateDateTimeDuration(DateTime start, DateTime end) {
  return end.difference(start).inMinutes;
}

DateTime lastDayOfMonth(DateTime dateTime) {
  DateTime firstDayNextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);
  return firstDayNextMonth.subtract(Duration(days: 1));
} 

DateTime firstDayOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, 1);
}


//------------------------- Shared Methods -------------------------


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
String formatDateAndTime(DateTime dateTime) {
  final weekday = dayOfWeekToString(dateTime.weekday);
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year;
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$weekday, $day.$month.$year $hour:$minute Uhr';
}

/// fotmatted as 'Mo, 01.01.2021'
String formatDate(DateTime dateTime) {
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

/// convert String to DateTime
DateTime stringToDate(String date) {
  final List<String> dateParts = date.split('.');
  return DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
}

/// convert String to TimeOfDay
TimeOfDay stringToTime(String time) {
  final List<String> timeParts = time.split(':');
  return TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
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
String dayOfWeekToString(int day) {
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

String daysOfWeekToString(Set<int> days) {
  if (days.isEmpty) return 'Keine Wochentage ausgewählt';

  String result = '';
  for (var day in days) {
    result += '${dayOfWeekToString(day)}, ';
  }
  return result.substring(0, result.length - 2); // Entfernt das letzte Komma + Leerzeichen
}


/// convert from String inputs to DateTimeRange
DateTimeRange parseDateTimeRange(
  String startDateText,
  String startTimeText,
  String endDateText,
  String endTimeText,
) {
  var startDate = stringToDate(startDateText);
  var startTime = stringToTime(startTimeText);
  var endDate = stringToDate(endDateText);
  var endTime = stringToTime(endTimeText);

  var start = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
    startTime.hour,
    startTime.minute,
  );

  var end = DateTime(
    endDate.year,
    endDate.month,
    endDate.day,
    endTime.hour,
    endTime.minute,
  );

  return DateTimeRange(start: start, end: end);
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

