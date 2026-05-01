import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SettingsController extends GetxController {
  final Box _settingsBox = Hive.box('settings');

  // Observables for UI reactivity
  var isDarkMode = false.obs;
  var currentLanguage = 'ar'.obs; // Default to Arabic

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

 void _loadSettings() {
    // 1. Load values from Hive immediately
    isDarkMode.value = _settingsBox.get('isDarkMode', defaultValue: false);
    currentLanguage.value = _settingsBox.get('language', defaultValue: 'ar');

    // 2. Wait for the UI to finish building BEFORE applying global changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      _applyLanguage(currentLanguage.value);
    });
  }

  // --- THEME TOGGLE ---
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _settingsBox.put('isDarkMode', isDarkMode.value);
  }

  // --- LANGUAGE SWITCHER ---
  void changeLanguage(String langCode) {
    currentLanguage.value = langCode;
    _applyLanguage(langCode);
    _settingsBox.put('language', langCode);
  }

  void _applyLanguage(String langCode) {
    Locale locale;
    switch (langCode) {
      case 'fr':
        locale = const Locale('fr', 'FR');
        break;
      case 'en':
        locale = const Locale('en', 'US');
        break;
      case 'ar':
      default:
        locale = const Locale('ar', 'DZ');
        break;
    }
    Get.updateLocale(locale);
  }
}