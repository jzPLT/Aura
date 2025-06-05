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
