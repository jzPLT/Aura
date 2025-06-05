import 'package:aura_mobile/features/calendar/services/schedule_service.dart';
import 'package:flutter/material.dart';

class CalendarState extends ChangeNotifier {
  List<ScheduleEntry> _scheduleEntries = [];
  bool _isLoading = false;
  String? _error;

  List<ScheduleEntry> get scheduleEntries => _scheduleEntries;
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

  void addScheduleEntries(List<ScheduleEntry> entries) {
    _scheduleEntries.addAll(entries);
    notifyListeners();
  }

  void setScheduleEntries(List<ScheduleEntry> entries) {
    _scheduleEntries = entries;
    notifyListeners();
  }
}
