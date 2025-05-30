// Static entries - recurring patterns or fixed events
class StaticEntry {
  final int? id;
  final String userUid;
  final String? originalInputText;
  final String description;
  final DateTime? startingDatetime;
  final DateTime? endingDatetime;
  final int? frequencyPerPeriod;
  final FrequencyPeriod frequencyPeriod;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  StaticEntry({
    this.id,
    required this.userUid,
    this.originalInputText,
    required this.description,
    this.startingDatetime,
    this.endingDatetime,
    this.frequencyPerPeriod,
    required this.frequencyPeriod,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory StaticEntry.fromJson(Map<String, dynamic> json) {
    return StaticEntry(
      id: json['id'] as int?,
      userUid: json['userUid'] as String,
      originalInputText: json['originalInputText'] as String?,
      description: json['description'] as String,
      startingDatetime:
          json['startingDatetime'] != null
              ? DateTime.parse(json['startingDatetime'] as String)
              : null,
      endingDatetime:
          json['endingDatetime'] != null
              ? DateTime.parse(json['endingDatetime'] as String)
              : null,
      frequencyPerPeriod: json['frequencyPerPeriod'] as int?,
      frequencyPeriod: FrequencyPeriod.fromString(
        json['frequencyPeriod'] as String,
      ),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      deletedAt:
          json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userUid': userUid,
      'originalInputText': originalInputText,
      'description': description,
      'startingDatetime': startingDatetime?.toIso8601String(),
      'endingDatetime': endingDatetime?.toIso8601String(),
      'frequencyPerPeriod': frequencyPerPeriod,
      'frequencyPeriod': frequencyPeriod.value,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

// Dynamic entries - flexible tasks/goals to be scheduled
class DynamicEntry {
  final int? id;
  final String userUid;
  final String? originalInputText;
  final String descriptionOfEntry;
  final DateTime? startingDatetime;
  final DateTime? endingDatetime;
  final int? frequencyPerPeriod;
  final FrequencyPeriod? frequencyPeriod;
  final String? dependencyName;
  final DependencyType? dependencyType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  DynamicEntry({
    this.id,
    required this.userUid,
    this.originalInputText,
    required this.descriptionOfEntry,
    this.startingDatetime,
    this.endingDatetime,
    this.frequencyPerPeriod,
    this.frequencyPeriod,
    this.dependencyName,
    this.dependencyType,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory DynamicEntry.fromJson(Map<String, dynamic> json) {
    return DynamicEntry(
      id: json['id'] as int?,
      userUid: json['userUid'] as String,
      originalInputText: json['originalInputText'] as String?,
      descriptionOfEntry: json['descriptionOfEntry'] as String,
      startingDatetime:
          json['startingDatetime'] != null
              ? DateTime.parse(json['startingDatetime'] as String)
              : null,
      endingDatetime:
          json['endingDatetime'] != null
              ? DateTime.parse(json['endingDatetime'] as String)
              : null,
      frequencyPerPeriod: json['frequencyPerPeriod'] as int?,
      frequencyPeriod:
          json['frequencyPeriod'] != null
              ? FrequencyPeriod.fromString(json['frequencyPeriod'] as String)
              : null,
      dependencyName: json['dependencyName'] as String?,
      dependencyType:
          json['dependencyType'] != null
              ? DependencyType.fromString(json['dependencyType'] as String)
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      deletedAt:
          json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userUid': userUid,
      'originalInputText': originalInputText,
      'descriptionOfEntry': descriptionOfEntry,
      'startingDatetime': startingDatetime?.toIso8601String(),
      'endingDatetime': endingDatetime?.toIso8601String(),
      'frequencyPerPeriod': frequencyPerPeriod,
      'frequencyPeriod': frequencyPeriod?.value,
      'dependencyName': dependencyName,
      'dependencyType': dependencyType?.value,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

// Resulting entries - concrete scheduled instances on calendar
class ResultingEntry {
  final int? id;
  final String userUid;
  final int? originStaticEntryId;
  final int? originDynamicEntryId;
  final String description;
  final DateTime startingDatetime;
  final DateTime endingDatetime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  ResultingEntry({
    this.id,
    required this.userUid,
    this.originStaticEntryId,
    this.originDynamicEntryId,
    required this.description,
    required this.startingDatetime,
    required this.endingDatetime,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ResultingEntry.fromJson(Map<String, dynamic> json) {
    return ResultingEntry(
      id: json['id'] as int?,
      userUid: json['userUid'] as String,
      originStaticEntryId: json['originStaticEntryId'] as int?,
      originDynamicEntryId: json['originDynamicEntryId'] as int?,
      description: json['description'] as String,
      startingDatetime: DateTime.parse(json['startingDatetime'] as String),
      endingDatetime: DateTime.parse(json['endingDatetime'] as String),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      deletedAt:
          json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userUid': userUid,
      'originStaticEntryId': originStaticEntryId,
      'originDynamicEntryId': originDynamicEntryId,
      'description': description,
      'startingDatetime': startingDatetime.toIso8601String(),
      'endingDatetime': endingDatetime.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

// Enums
enum FrequencyPeriod {
  never,
  day,
  week,
  month,
  year;

  String get value {
    switch (this) {
      case FrequencyPeriod.never:
        return 'never';
      case FrequencyPeriod.day:
        return 'day';
      case FrequencyPeriod.week:
        return 'week';
      case FrequencyPeriod.month:
        return 'month';
      case FrequencyPeriod.year:
        return 'year';
    }
  }

  static FrequencyPeriod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'never':
        return FrequencyPeriod.never;
      case 'day':
        return FrequencyPeriod.day;
      case 'week':
        return FrequencyPeriod.week;
      case 'month':
        return FrequencyPeriod.month;
      case 'year':
        return FrequencyPeriod.year;
      default:
        throw ArgumentError('Invalid frequency period: $value');
    }
  }
}

enum DependencyType {
  before,
  after,
  during,
  notSameDay,
  sameDay,
  notSameWeek,
  sameWeek,
  notSameMonth,
  sameMonth;

  String get value {
    switch (this) {
      case DependencyType.before:
        return 'before';
      case DependencyType.after:
        return 'after';
      case DependencyType.during:
        return 'during';
      case DependencyType.notSameDay:
        return 'not_same_day';
      case DependencyType.sameDay:
        return 'same_day';
      case DependencyType.notSameWeek:
        return 'not_same_week';
      case DependencyType.sameWeek:
        return 'same_week';
      case DependencyType.notSameMonth:
        return 'not_same_month';
      case DependencyType.sameMonth:
        return 'same_month';
    }
  }

  static DependencyType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'before':
        return DependencyType.before;
      case 'after':
        return DependencyType.after;
      case 'during':
        return DependencyType.during;
      case 'not_same_day':
        return DependencyType.notSameDay;
      case 'same_day':
        return DependencyType.sameDay;
      case 'not_same_week':
        return DependencyType.notSameWeek;
      case 'same_week':
        return DependencyType.sameWeek;
      case 'not_same_month':
        return DependencyType.notSameMonth;
      case 'same_month':
        return DependencyType.sameMonth;
      default:
        throw ArgumentError('Invalid dependency type: $value');
    }
  }
}

// Schedule overview containing all entry types
class ScheduleOverview {
  final List<StaticEntry> staticEntries;
  final List<DynamicEntry> dynamicEntries;
  final List<ResultingEntry> resultingEntries;

  ScheduleOverview({
    required this.staticEntries,
    required this.dynamicEntries,
    required this.resultingEntries,
  });

  factory ScheduleOverview.fromJson(Map<String, dynamic> json) {
    return ScheduleOverview(
      staticEntries:
          (json['staticEntries'] as List<dynamic>)
              .map((e) => StaticEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      dynamicEntries:
          (json['dynamicEntries'] as List<dynamic>)
              .map((e) => DynamicEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      resultingEntries:
          (json['resultingEntries'] as List<dynamic>)
              .map((e) => ResultingEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staticEntries': staticEntries.map((e) => e.toJson()).toList(),
      'dynamicEntries': dynamicEntries.map((e) => e.toJson()).toList(),
      'resultingEntries': resultingEntries.map((e) => e.toJson()).toList(),
    };
  }
}
