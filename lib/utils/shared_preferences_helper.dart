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
    } else {
      throw ArgumentError('Unsupported type for Shared Preferences');
    }
  }

  /// load a value from Shared Preferences
  static Future<dynamic> loadValue(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      return prefs.get(key); /// returns value if key exists
    }
    return null; /// returns null if key does not exist
  }

  /// remove a value from Shared Preferences
  static Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// does key exist in Shared Preferences?
  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
