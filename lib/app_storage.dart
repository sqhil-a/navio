import 'dart:convert';

import 'package:navio/widgets/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> loadString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> saveStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<List<String>> loadStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    try {
      return (jsonDecode(raw) as List).map((item) => item.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> loadBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset all notifiers
    selectedStyleNotifier.value = null;
    selectedAoiNotifier.value = [];
    stageNotifier.value = "";
    careerNotifier.value = "";
    careerTitleNotifier.value = "";
    usernameNotifier.value = "";
    completedOnboardingNotifier.value = false;
    onboardingStepNotifier.value = 0;
    selectedNavIndexNotifier.value = 1;
    chatResetNotifier.value++;
    showAuthPageNotifier.value = true;
  }
}
