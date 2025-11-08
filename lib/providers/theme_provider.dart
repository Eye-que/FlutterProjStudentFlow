import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider
/// Manages app theme state (light/dark mode) with persistence
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.light, // Default to light if invalid
        );
      } else {
        // Default to light mode if no preference is saved
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      _themeMode = ThemeMode.light; // Default to light on error
      notifyListeners();
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeMode();
      notifyListeners();
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}

