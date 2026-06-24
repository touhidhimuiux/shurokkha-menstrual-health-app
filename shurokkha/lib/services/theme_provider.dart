import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeProvider extends ChangeNotifier {
  Color _primaryColor = const Color(0xFF7B35B5); // Default Purple
  String? _bgImagePath;

  Color get primaryColor => _primaryColor;
  String? get bgImagePath => _bgImagePath;

  AppThemeProvider() {
    _loadThemeSettings();
  }

  void updateColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
  }

  void updateBgImage(String? path) async {
    _bgImagePath = path;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('bg_image_path', path);
    } else {
      await prefs.remove('bg_image_path');
    }
  }

  void _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('primary_color');
    _bgImagePath = prefs.getString('bg_image_path');
    if (colorValue != null) _primaryColor = Color(colorValue);
    notifyListeners();
  }
}