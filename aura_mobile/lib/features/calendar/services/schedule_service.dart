import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ScheduleEntry {
  final String type;
  final String activity;
  final String? datetime;
  final Schedule? schedule;
  final Dependency? dependsOn;

  ScheduleEntry({
    required this.type,
    required this.activity,
    this.datetime,
    this.schedule,
    this.dependsOn,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      type: json['type'],
      activity: json['activity'],
      datetime: json['datetime'],
      schedule:
          json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
      dependsOn:
          json['dependsOn'] != null
              ? Dependency.fromJson(json['dependsOn'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'activity': activity,
      if (datetime != null) 'datetime': datetime,
      if (schedule != null) 'schedule': schedule!.toJson(),
      if (dependsOn != null) 'dependsOn': dependsOn!.toJson(),
    };
  }
}

class Schedule {
  final List<String>? days;
  final String? startTime;
  final String? endTime;
  final Frequency? frequency;

  Schedule({this.days, this.startTime, this.endTime, this.frequency});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      days: json['days'] != null ? List<String>.from(json['days']) : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      frequency:
          json['frequency'] != null
              ? Frequency.fromJson(json['frequency'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (days != null) 'days': days,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (frequency != null) 'frequency': frequency!.toJson(),
    };
  }
}

class Frequency {
  final int times;
  final String period;

  Frequency({required this.times, required this.period});

  factory Frequency.fromJson(Map<String, dynamic> json) {
    return Frequency(times: json['times'], period: json['period']);
  }

  Map<String, dynamic> toJson() {
    return {'times': times, 'period': period};
  }
}

class Dependency {
  final String activity;
  final String relation;

  Dependency({required this.activity, required this.relation});

  factory Dependency.fromJson(Map<String, dynamic> json) {
    return Dependency(activity: json['activity'], relation: json['relation']);
  }

  Map<String, dynamic> toJson() {
    return {'activity': activity, 'relation': relation};
  }
}

class ScheduleService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<List<ScheduleEntry>> createScheduleEntry(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['entries'] as List)
              .map((entry) => ScheduleEntry.fromJson(entry))
              .toList();
        }
        log(data.toString());
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
