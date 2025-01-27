import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/views/shared/cards_and_markers.dart';
import 'package:flutter/material.dart';

/// Cache for markers to avoid unnecessary rebuilds
class MarkerCache {
  final Map<DateTime, Widget> _cache = {};

  Widget getMarker(DateTime day, Shift shift, Color color) {
    if (_cache.containsKey(day)) {
      return _cache[day]!;
    }
    final marker = CalendarDayMarker(
      shift: shift,
      color: color,
    );
    _cache[day] = marker;
    return marker;
  }
  void clearCache() {
    _cache.clear();
  }
}
