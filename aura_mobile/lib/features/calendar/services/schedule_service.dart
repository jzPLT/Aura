import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calendar_day_view/calendar_day_view.dart';

class ScheduleEntry {
  final String type;
  final String activity;
  final Map<String, dynamic>? frequency;
  final Map<String, dynamic>? timePreference;
  final Map<String, dynamic>? fixedSchedule;

  ScheduleEntry({
    required this.type,
    required this.activity,
    this.frequency,
    this.timePreference,
    this.fixedSchedule,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      type: json['type'],
      activity: json['activity'],
      frequency: json['frequency'],
      timePreference: json['timePreference'],
      fixedSchedule: json['fixedSchedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'activity': activity,
      if (frequency != null) 'frequency': frequency,
      if (timePreference != null) 'timePreference': timePreference,
      if (fixedSchedule != null) 'fixedSchedule': fixedSchedule,
    };
  }
}

class ScheduleService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<List<DayEvent<String>>> createScheduleEntry(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['events'] as List)
              .map(
                (event) => DayEvent<String>(
                  value: event['value'],
                  start: DateTime.parse(event['start']),
                  end: DateTime.parse(event['end']),
                ),
              )
              .toList();
        }
      }

      throw Exception(
        jsonDecode(response.body)['message'] ??
            'Failed to create schedule entry',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<List<ScheduleEntry>> getScheduleEntries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/schedule'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['entries'] as List)
              .map((entry) => ScheduleEntry.fromJson(entry))
              .toList();
        }
      }

      throw Exception(
        jsonDecode(response.body)['message'] ??
            'Failed to fetch schedule entries',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
