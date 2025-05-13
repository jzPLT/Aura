import 'package:calendar_day_view/calendar_day_view.dart';

class EventService {
  final List<DayEvent<String>> _events = [
    DayEvent(
      value: 'Morning Meeting - Team standup',
      start: DateTime(2025, 5, 13, 9, 0),
      end: DateTime(2025, 5, 13, 10, 0),
    ),
    DayEvent(
      value: 'Lunch Break',
      start: DateTime(2025, 5, 13, 12, 0),
      end: DateTime(2025, 5, 13, 13, 0),
    ),
    DayEvent(
      value: 'Project Review - Sprint review',
      start: DateTime(2025, 5, 13, 14, 30),
      end: DateTime(2025, 5, 13, 15, 30),
    ),
  ];

  List<DayEvent<String>> getEventsForDay(DateTime day) {
    return _events
        .where(
          (event) =>
              event.start.year == day.year &&
              event.start.month == day.month &&
              event.start.day == day.day,
        )
        .toList();
  }

  // TODO: Add methods for CRUD operations when implementing API integration
  Future<void> addEvent(DayEvent<String> event) async {
    // TODO: Implement API call
    _events.add(event);
  }

  Future<void> updateEvent(DayEvent<String> event) async {
    // TODO: Implement API call
  }

  Future<void> deleteEvent(DayEvent<String> event) async {
    // TODO: Implement API call
    _events.remove(event);
  }
}
