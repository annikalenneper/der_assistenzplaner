import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  /// save a value to Shared Preferences
  static Future<void> saveValue(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else if (value is DateTime) {
      await prefs.setString(key, value.toIso8601String());
    } else if (value is TimeOfDay) {
      await prefs.setInt('${key}_hour', value.hour);
      await prefs.setInt('${key}_minute', value.minute);
    } else if (value is Color) {
      await prefs.setInt(key, value.value);
    } else {
      throw ArgumentError('Unsupported type for Shared Preferences');
    }
  }

  /// load a value from Shared Preferences
  static Future<dynamic> loadValue(String key, {Type? type}) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      // handle DateTime
      if (type == DateTime) {
        String? dateTimeString = prefs.getString(key);
        if (dateTimeString != null) {
          return DateTime.parse(dateTimeString);
        }
      }

      // handle TimeOfDay
      if (type == TimeOfDay) {
        int? hour = prefs.getInt('${key}_hour');
        int? minute = prefs.getInt('${key}_minute');
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }

      // handle Color
      if (type == Color) {
        final int? colorValue = prefs.getInt(key);
        if (colorValue != null) {
          return Color(colorValue);
        } else {
          return null;
        }
      }

      // default handling for other types
      return prefs.get(key); /// returns value if key exists
    }
    return null; /// returns null if key does not exist
  }

  /// remove a value from Shared Preferences
  static Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);

    /// remove associated keys for TimeOfDay
    await prefs.remove('${key}_hour');
    await prefs.remove('${key}_minute');
  }

   /// does key exist in Shared Preferences?
  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key) ||
        prefs.containsKey('${key}_hour') && prefs.containsKey('${key}_minute');
  }
}
