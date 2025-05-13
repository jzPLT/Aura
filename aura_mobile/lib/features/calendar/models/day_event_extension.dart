import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';

extension DayEventX on DayEvent<String> {
  String getTimeRangeString(BuildContext context) {
    final startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    if (end == null) return startTime.format(context);
    final endTime = TimeOfDay(hour: end!.hour, minute: end!.minute);
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}
