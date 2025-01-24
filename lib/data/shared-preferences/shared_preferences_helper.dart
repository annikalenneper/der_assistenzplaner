import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class SharedPreferencesHelper {
  const SharedPreferencesHelper();

  /// save value to SharedPreferences based on type
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
    } else if (value is List<int>) {
      await prefs.setStringList(key, value.map((e) => e.toString()).toList());
    } else if (value is Set<int>) {
      await prefs.setStringList(key, value.map((e) => e.toString()).toList());
    } else if (value is DateTime) {
      await prefs.setString(key, value.toIso8601String());
    } else if (value is TimeOfDay) {
      await prefs.setInt('${key}_hour', value.hour);
      await prefs.setInt('${key}_minute', value.minute);
    } else if (value is Color) {
      await prefs.setDouble('${key}_a', value.a);
      await prefs.setDouble('${key}_r', value.r);
      await prefs.setDouble('${key}_g', value.g);
      await prefs.setDouble('${key}_b', value.b);
    } else {
      throw ArgumentError('Unsupported type for Shared Preferences');
    }
  }

  /// load value from SharedPreferences based on type
  static Future<dynamic> loadValue(String key, Type? type) async {
    final prefs = await SharedPreferences.getInstance();

    bool hasColorComponents = type == Color &&
      prefs.containsKey('${key}_a') &&
      prefs.containsKey('${key}_r') &&
      prefs.containsKey('${key}_g') &&
      prefs.containsKey('${key}_b');

  bool hasTimeOfDay = type == TimeOfDay &&
      prefs.containsKey('${key}_hour') &&
      prefs.containsKey('${key}_minute');

  bool hasKey = prefs.containsKey(key);

    if (hasKey || hasColorComponents || hasTimeOfDay) {
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
        final double? a = prefs.getDouble('${key}_a');
        final double? r = prefs.getDouble('${key}_r');
        final double? g = prefs.getDouble('${key}_g');
        final double? b = prefs.getDouble('${key}_b');
        if (a != null && r != null && g != null && b != null) {
          final color = Color.from(alpha: a, red: r, green: g, blue: b);
          return color;
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
