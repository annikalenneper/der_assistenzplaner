import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class SharedPreferencesHelper {
  const SharedPreferencesHelper();

  /// save value to SharedPreferences based on type
  static Future<void> saveValue(String key, dynamic type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type is String) {
      await prefs.setString(key, type);
    } else if (type is int) {
      await prefs.setInt(key, type);
    } else if (type is double) {
      await prefs.setDouble(key, type);
    } else if (type is bool) {
      await prefs.setBool(key, type);
    } else if (type is List<String>) {
      await prefs.setStringList(key, type);
    } else if (type is List<int>) {
      await prefs.setStringList(key, type.map((e) => e.toString()).toList());
    } else if (type is Set<int>) {
      await prefs.setStringList(key, type.map((e) => e.toString()).toList());
    } else if (type is DateTime) {
      await prefs.setString(key, type.toIso8601String());
    } else if (type is TimeOfDay) {
      await prefs.setInt('${key}_hour', type.hour);
      await prefs.setInt('${key}_minute', type.minute);
    } else if (type is Color) {
      await prefs.setInt(key, type.value);
    } else {
      throw ArgumentError('Unsupported type for Shared Preferences');
    }
  }

  /// load value from SharedPreferences based on type
  static Future<dynamic> loadValue(String key, Type? type) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      if (type == DateTime) {
        String? dateTimeString = prefs.getString(key);
        if (dateTimeString != null) {
          return DateTime.parse(dateTimeString);
        }
      }

      if (type == TimeOfDay) {
        int? hour = prefs.getInt('${key}_hour');
        int? minute = prefs.getInt('${key}_minute');
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        } else {
          log('SharedPreferencesHelper: TimeOfDay values incomplete for key $key');
          return null;
        }
      }

      if (type == Color) {
        final int? colorValue = prefs.getInt(key);
        if (colorValue != null) {
          return Color(colorValue);
        }
      }

      if (type == List<int>) {
        final stringList = prefs.getStringList(key);
        if (stringList != null) {
          try {
            return stringList.map((e) => int.parse(e)).toList();
          } catch (e) {
            log('SharedPreferencesHelper: Error parsing List<int>: $e');
            return [];
          }
        }
      }

      if (type == Set<int>) {
        final stringList = prefs.getStringList(key);
        if (stringList != null) {
          try {
            return stringList.map((e) => int.parse(e)).toSet();
          } catch (e) {
            log('SharedPreferencesHelper: Error parsing Set<int>: $e');
            return {};
          }
        }
      }

      return prefs.get(key);
    }

    return null; // return null if key not found, handle in model
  }

  static Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await prefs.remove('${key}_hour');
    await prefs.remove('${key}_minute');
  }

  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key) ||
        (prefs.containsKey('${key}_hour') && prefs.containsKey('${key}_minute'));
  }
}
