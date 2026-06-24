import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinProvider extends ChangeNotifier {
  static const String _pinKey = 'app_pin';
  static const String _pinSetKey = 'pin_is_set';
  static const String _firstTimeKey = 'first_time_user';
  static const String _loginCompleteKey = 'login_complete';

  bool _isPinSet = false;
  String _savedPin = '';
  bool _isFirstTimeUser = true;
  bool _hasCompletedInitialLogin = false;

  bool get isPinSet => _isPinSet;
  String get savedPin => _savedPin;
  bool get isFirstTimeUser => _isFirstTimeUser;
  bool get hasCompletedInitialLogin => _hasCompletedInitialLogin;

  PinProvider() {
    _loadPin();
  }

  Future<void> _loadPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPinSet = prefs.getBool(_pinSetKey) ?? false;
      _savedPin = prefs.getString(_pinKey) ?? '';
      _isFirstTimeUser = prefs.getBool(_firstTimeKey) ?? true;
      _hasCompletedInitialLogin = prefs.getBool(_loginCompleteKey) ?? false;
    } catch (e) {
      _isFirstTimeUser = true;
      _isPinSet = false;
    }
    notifyListeners();
  }

  Future<bool> setPin(String pin) async {
    if (pin.length != 4 || !RegExp(r'^\d+$').hasMatch(pin)) {
      return false;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, pin);
      await prefs.setBool(_pinSetKey, true);
      _isPinSet = true;
      _savedPin = pin;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    return pin == _savedPin;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (oldPin != _savedPin) {
      return false;
    }
    return await setPin(newPin);
  }

  Future<void> completeInitialLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeKey, false);
      await prefs.setBool(_loginCompleteKey, true);
      _isFirstTimeUser = false;
      _hasCompletedInitialLogin = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing initial login: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear all user data except PIN and flags
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key != _pinKey &&
            key != _pinSetKey &&
            key != _firstTimeKey &&
            key != _loginCompleteKey) {
          await prefs.remove(key);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<void> deleteAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _isPinSet = false;
      _savedPin = '';
      _isFirstTimeUser = true;
      _hasCompletedInitialLogin = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting all data: $e');
    }
  }
}
