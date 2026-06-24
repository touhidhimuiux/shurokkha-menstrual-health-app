import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PeriodDataProvider extends ChangeNotifier {
  static const String _lastPeriodDateKey = 'last_period_date';
  static const String _cycleLengthKey = 'cycle_length';
  static const String _periodLengthKey = 'period_length';
  static const String _userNameKey = 'user_name';

  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  String _userName = 'User';
  int _currentCycleDay = 1;
  
  // Timer for real-time updates
  Timer? _updateTimer;
  static const Duration _updateInterval = Duration(minutes: 1);

  DateTime? get lastPeriodDate => _lastPeriodDate;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  String get userName => _userName;
  int get currentCycleDay => _currentCycleDay;

  PeriodDataProvider() {
    _loadData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    // Update cycle day every minute to refresh UI in real-time
    _updateTimer = Timer.periodic(_updateInterval, (_) {
      _updateCycleDayIfNeeded();
    });
  }

  void _updateCycleDayIfNeeded() {
    if (_lastPeriodDate != null) {
      final newCycleDay = _calculateCurrentCycleDay();
      if (newCycleDay != _currentCycleDay) {
        _currentCycleDay = newCycleDay;
        notifyListeners();
      }
    }
  }

  int _calculateCurrentCycleDay() {
    if (_lastPeriodDate == null) return 1;
    final now = DateTime.now();
    final difference = now.difference(_lastPeriodDate!).inDays;
    final cycleDay = (difference % _cycleLength) + 1;
    return cycleDay;
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lastPeriodString = prefs.getString(_lastPeriodDateKey);
      if (lastPeriodString != null) {
        _lastPeriodDate = DateTime.parse(lastPeriodString);
        _currentCycleDay = _calculateCurrentCycleDay();
      }
      
      _cycleLength = prefs.getInt(_cycleLengthKey) ?? 28;
      _periodLength = prefs.getInt(_periodLengthKey) ?? 5;
      _userName = prefs.getString(_userNameKey) ?? 'User';
    } catch (e) {
      debugPrint('Error loading period data: $e');
    }
    notifyListeners();
  }

  Future<void> setPeriodData({
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodLength,
    required String userName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_lastPeriodDateKey, lastPeriodDate.toIso8601String());
      await prefs.setInt(_cycleLengthKey, cycleLength);
      await prefs.setInt(_periodLengthKey, periodLength);
      await prefs.setString(_userNameKey, userName);
      
      _lastPeriodDate = lastPeriodDate;
      _cycleLength = cycleLength;
      _periodLength = periodLength;
      _userName = userName;
      _currentCycleDay = _calculateCurrentCycleDay();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving period data: $e');
    }
  }

  int getCurrentCycleDay() {
    // Return the cached value which is updated by the timer
    return _currentCycleDay;
  }

  // Force refresh data - useful when screen comes back into focus
  Future<void> refreshData() async {
    await _loadData();
    _updateCycleDayIfNeeded();
  }

  int getDaysUntilNextPeriod() {
    if (_lastPeriodDate == null) return _cycleLength;
    
    final currentDay = getCurrentCycleDay();
    final daysUntilNext = _cycleLength - currentDay + 1;
    return daysUntilNext > 0 ? daysUntilNext : _cycleLength;
  }

  int getDaysUntilOvulation() {
    // Ovulation typically occurs around day 14 of a 28-day cycle
    final oculationDay = (_cycleLength / 2).round();
    final currentDay = getCurrentCycleDay();
    
    if (currentDay <= oculationDay) {
      return oculationDay - currentDay;
    } else {
      return (_cycleLength - currentDay) + oculationDay;
    }
  }

  bool isPeriodDay(int dayOfCycle) {
    return dayOfCycle <= _periodLength;
  }

  bool isOvulationDay(int dayOfCycle) {
    final ovulationDay = (_cycleLength / 2).round();
    return (dayOfCycle >= ovulationDay - 2) && (dayOfCycle <= ovulationDay + 2);
  }

  String getCyclePhase(int dayOfCycle) {
    if (dayOfCycle <= _periodLength) {
      return 'Menstruation';
    } else if (dayOfCycle <= 12) {
      return 'Follicular Phase';
    } else if (dayOfCycle <= 16) {
      return 'Ovulation Window';
    } else if (dayOfCycle <= _cycleLength) {
      return 'Luteal Phase';
    }
    return 'Unknown';
  }
}
