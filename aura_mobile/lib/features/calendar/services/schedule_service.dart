import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../../../core/config.dart';

class ScheduleEntry {
  final String type;
  final String description;
  final String? startingDatetime;
  final Frequency? frequency;
  final Dependency? dependsOn;

  ScheduleEntry({
    required this.type,
    required this.description,
    this.startingDatetime,
    this.frequency,
    this.dependsOn,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      type: json['type'],
      description: json['description'],
      startingDatetime: json['startingDatetime'],
      frequency:
          json['frequency'] != null
              ? Frequency.fromJson(json['frequency'])
              : null,
      dependsOn:
          json['dependsOn'] != null
              ? Dependency.fromJson(json['dependsOn'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      if (startingDatetime != null) 'startingDatetime': startingDatetime,
      if (frequency != null) 'frequency': frequency!.toJson(),
      if (dependsOn != null) 'dependsOn': dependsOn!.toJson(),
    };
  }
}

class Frequency {
  final int perPeriod;
  final String period;

  Frequency({required this.perPeriod, required this.period});

  factory Frequency.fromJson(Map<String, dynamic> json) {
    return Frequency(perPeriod: json['perPeriod'], period: json['period']);
  }

  Map<String, dynamic> toJson() {
    return {'perPeriod': perPeriod, 'period': period};
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
  Future<List<ScheduleEntry>> createScheduleEntry(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> entries = data['data']['entries'];

          return entries.map((entry) => ScheduleEntry.fromJson(entry)).toList();
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
