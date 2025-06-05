import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config.dart';
import '../../schedule/models/schedule_models.dart';

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

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

class ScheduleCreateResponse {
  final String originalText;
  final List<SavedStaticEntry> staticEntries;
  final List<SavedDynamicEntry> dynamicEntries;
  final int totalEntries;

  ScheduleCreateResponse({
    required this.originalText,
    required this.staticEntries,
    required this.dynamicEntries,
    required this.totalEntries,
  });

  factory ScheduleCreateResponse.fromJson(Map<String, dynamic> json) {
    final savedEntries = json['savedEntries'] as Map<String, dynamic>;
    
    return ScheduleCreateResponse(
      originalText: json['originalText'] as String,
      staticEntries: (savedEntries['staticEntries'] as List<dynamic>)
          .map((e) => SavedStaticEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      dynamicEntries: (savedEntries['dynamicEntries'] as List<dynamic>)
          .map((e) => SavedDynamicEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEntries: json['totalEntries'] as int,
    );
  }
}

class SavedStaticEntry {
  final int id;
  final String userUid;
  final String? originalInputText;
  final String description;
  final String? startingDatetime;
  final String? endingDatetime;
  final int? frequencyPerPeriod;
  final String frequencyPeriod;
  final String createdAt;
  final String updatedAt;

  SavedStaticEntry({
    required this.id,
    required this.userUid,
    this.originalInputText,
    required this.description,
    this.startingDatetime,
    this.endingDatetime,
    this.frequencyPerPeriod,
    required this.frequencyPeriod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedStaticEntry.fromJson(Map<String, dynamic> json) {
    return SavedStaticEntry(
      id: json['id'] as int,
      userUid: json['userUid'] as String,
      originalInputText: json['originalInputText'] as String?,
      description: json['description'] as String,
      startingDatetime: json['startingDatetime'] as String?,
      endingDatetime: json['endingDatetime'] as String?,
      frequencyPerPeriod: json['frequencyPerPeriod'] as int?,
      frequencyPeriod: json['frequencyPeriod'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class SavedDynamicEntry {
  final int id;
  final String userUid;
  final String? originalInputText;
  final String descriptionOfEntry;
  final String? startingDatetime;
  final String? endingDatetime;
  final int? frequencyPerPeriod;
  final String? frequencyPeriod;
  final String? dependencyName;
  final String? dependencyType;
  final String createdAt;
  final String updatedAt;

  SavedDynamicEntry({
    required this.id,
    required this.userUid,
    this.originalInputText,
    required this.descriptionOfEntry,
    this.startingDatetime,
    this.endingDatetime,
    this.frequencyPerPeriod,
    this.frequencyPeriod,
    this.dependencyName,
    this.dependencyType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedDynamicEntry.fromJson(Map<String, dynamic> json) {
    return SavedDynamicEntry(
      id: json['id'] as int,
      userUid: json['userUid'] as String,
      originalInputText: json['originalInputText'] as String?,
      descriptionOfEntry: json['descriptionOfEntry'] as String,
      startingDatetime: json['startingDatetime'] as String?,
      endingDatetime: json['endingDatetime'] as String?,
      frequencyPerPeriod: json['frequencyPerPeriod'] as int?,
      frequencyPeriod: json['frequencyPeriod'] as String?,
      dependencyName: json['dependencyName'] as String?,
      dependencyType: json['dependencyType'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class ScheduleService {
  /// Creates schedule entries from natural language text
  /// Now returns the saved database entries with their IDs
  Future<ScheduleCreateResponse> createScheduleEntry(String text) async {
    try {
      // Get current user and auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final idToken = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success']) {
          return ScheduleCreateResponse.fromJson(responseData['data']);
        }
        throw Exception(responseData['message'] ?? 'Failed to create schedule entry');
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please sign in again.');
      }

      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['error'] ?? errorData['message'] ?? 'Failed to create schedule entry',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }

  /// Legacy method for backward compatibility
  /// Converts the new response format to the old ScheduleEntry format
  Future<List<ScheduleEntry>> createScheduleEntryLegacy(String text) async {
    try {
      final response = await createScheduleEntry(text);
      final List<ScheduleEntry> entries = [];
      
      // Convert static entries
      for (final staticEntry in response.staticEntries) {
        entries.add(ScheduleEntry(
          type: 'static',
          description: staticEntry.description,
          startingDatetime: staticEntry.startingDatetime,
          frequency: staticEntry.frequencyPerPeriod != null
              ? Frequency(
                  perPeriod: staticEntry.frequencyPerPeriod!,
                  period: staticEntry.frequencyPeriod,
                )
              : null,
        ));
      }
      
      // Convert dynamic entries
      for (final dynamicEntry in response.dynamicEntries) {
        entries.add(ScheduleEntry(
          type: 'dynamic',
          description: dynamicEntry.descriptionOfEntry,
          startingDatetime: dynamicEntry.startingDatetime,
          frequency: dynamicEntry.frequencyPerPeriod != null && dynamicEntry.frequencyPeriod != null
              ? Frequency(
                  perPeriod: dynamicEntry.frequencyPerPeriod!,
                  period: dynamicEntry.frequencyPeriod!,
                )
              : null,
          dependsOn: dynamicEntry.dependencyName != null && dynamicEntry.dependencyType != null
              ? Dependency(
                  activity: dynamicEntry.dependencyName!,
                  relation: dynamicEntry.dependencyType!,
                )
              : null,
        ));
      }
      
      return entries;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleEntry>> getScheduleEntries() async {
    try {
      // Get current user and auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final idToken = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/entries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // This would need to be updated based on the actual entries endpoint response format
          return (data['data'] as List)
              .map((entry) => ScheduleEntry.fromJson(entry))
              .toList();
        }
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please sign in again.');
      }

      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['error'] ?? errorData['message'] ?? 'Failed to fetch schedule entries',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
