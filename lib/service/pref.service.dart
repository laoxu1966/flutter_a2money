import 'dart:async' show Future;

import 'package:shared_preferences/shared_preferences.dart';

class Pref {
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences?> get _instance async {
    return await SharedPreferences.getInstance();
  }

  static init() async {
    _prefsInstance ??= await _instance;
  }

  static String? getString(String key, [String? defValue]) {
    return _prefsInstance!.getString(key) ?? "";
  }

  static Future<bool> setString(String key, String value) async {
    return _prefsInstance!.setString(key, value);
  }

  static bool? getBool(String key, [bool? defValue]) {
    return _prefsInstance!.getBool(key) ?? false;
  }

  static Future<bool> setBool(String key, bool value) async {
    return _prefsInstance!.setBool(key, value);
  }

  static List<String>? getStringList(String key, [String? defValue]) {
    return _prefsInstance!.getStringList(key) ?? [];
  }

  static Future<bool> setStringList(String key, List<String> value) {
    return _prefsInstance!.setStringList(key, value);
  }

  static bool containsKey(String key, [bool? defValue]) {
    return _prefsInstance!.containsKey(key);
  }

  static Future<bool> remove(String key, [bool? defValue]) {
    return _prefsInstance!.remove(key);
  }
}
