class UserData {
  final String uid;
  final String email;
  final String? displayName;
  final String? preferencesTheme;
  final bool? preferencesNotifications;
  final int? defaultDurationForScheduling; // in minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  UserData({
    required this.uid,
    required this.email,
    this.displayName,
    this.preferencesTheme,
    this.preferencesNotifications,
    this.defaultDurationForScheduling,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      preferencesTheme: json['preferencesTheme'] as String?,
      preferencesNotifications: json['preferencesNotifications'] as bool?,
      defaultDurationForScheduling:
          json['defaultDurationForScheduling'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'preferencesTheme': preferencesTheme,
      'preferencesNotifications': preferencesNotifications,
      'defaultDurationForScheduling': defaultDurationForScheduling,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserData copyWith({
    String? displayName,
    String? preferencesTheme,
    bool? preferencesNotifications,
    int? defaultDurationForScheduling,
  }) {
    return UserData(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      preferencesTheme: preferencesTheme ?? this.preferencesTheme,
      preferencesNotifications:
          preferencesNotifications ?? this.preferencesNotifications,
      defaultDurationForScheduling:
          defaultDurationForScheduling ?? this.defaultDurationForScheduling,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class UserPreferences {
  final String? theme;
  final bool notifications;

  UserPreferences({this.theme = 'dark', this.notifications = true});

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] as String?,
      notifications: json['notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'theme': theme, 'notifications': notifications};
  }
}

class ScheduleSettings {
  final int defaultDuration;
  final WorkingHours workingHours;

  ScheduleSettings({this.defaultDuration = 30, WorkingHours? workingHours})
    : workingHours = workingHours ?? WorkingHours();

  factory ScheduleSettings.fromJson(Map<String, dynamic> json) {
    return ScheduleSettings(
      defaultDuration: json['defaultDuration'] as int? ?? 30,
      workingHours:
          json['workingHours'] != null
              ? WorkingHours.fromJson(json['workingHours'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultDuration': defaultDuration,
      'workingHours': workingHours.toJson(),
    };
  }
}

class WorkingHours {
  final String start;
  final String end;

  WorkingHours({this.start = '09:00', this.end = '17:00'});

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      start: json['start'] as String? ?? '09:00',
      end: json['end'] as String? ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }
}
