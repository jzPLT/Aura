import 'package:flutter/material.dart';
import 'package:calendar_day_view/calendar_day_view.dart';

class CalendarState extends ChangeNotifier {
  List<DayEvent<String>> _scheduleEntries = [];
  bool _isLoading = false;
  String? _error;

  List<DayEvent<String>> get scheduleEntries => _scheduleEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addScheduleEntries(List<DayEvent<String>> entries) {
    _scheduleEntries.addAll(entries);
    notifyListeners();
  }

  void setScheduleEntries(List<DayEvent<String>> entries) {
    _scheduleEntries = entries;
    notifyListeners();
  }
}
