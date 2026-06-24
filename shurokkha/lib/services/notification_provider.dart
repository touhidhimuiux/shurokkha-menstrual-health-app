import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _notificationKey = 'notifications_enabled';

  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  NotificationProvider() {
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, value);
    notifyListeners();
  }

  // Get period tips and motivational messages
  String getPeriodTip() {
    final tips = [
      '💪 Stay hydrated! Drink plenty of water during your period.',
      '🧘 Try some light yoga or stretching to ease cramps.',
      '🍫 Dark chocolate can help with period cravings and mood!',
      '❤️ Be kind to yourself. Rest is essential during your period.',
      '🥗 Eat iron-rich foods like spinach to boost energy.',
      '🌟 Your body is amazing! Celebrate your health.',
      '💚 Deep breathing exercises can help ease period discomfort.',
      '📝 Keep a journal to track your mood and symptoms.',
      '☕ A warm cup of tea can soothe period cramps.',
      '👯 Talk to friends or family if you need support.',
    ];
    return tips[DateTime.now().day % tips.length];
  }

  String getMotivationalMessage() {
    final messages = [
      '✨ You are strong, capable, and beautiful!',
      '🌸 Taking care of yourself is the best investment.',
      '💖 Your health is your wealth.',
      '🎯 You\'ve got this! Keep pushing forward.',
      '🌈 Every day is a fresh opportunity to feel great.',
      '👸 Embrace your femininity with confidence.',
      '🌺 Self-love is the best medicine.',
      '⭐ You deserve to feel amazing.',
      '🎀 Treat yourself with care and compassion.',
      '💝 Your body works hard for you. Appreciate it!',
    ];
    return messages[DateTime.now().day % messages.length];
  }
}
