import 'package:aura_mobile/features/calendar/models/day_event_extension.dart';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduleView extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onDateTap;

  const ScheduleView({
    super.key,
    required this.selectedDay,
    required this.onDateTap,
  });

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
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

  void _editEvent(BuildContext context, DayEvent<String> event) {
    final TextEditingController titleController = TextEditingController(
      text: event.value,
    );
    final ValueNotifier<TimeOfDay> startTime = ValueNotifier(
      TimeOfDay.fromDateTime(event.start),
    );
    final ValueNotifier<TimeOfDay> endTime = ValueNotifier(
      TimeOfDay.fromDateTime(
        event.end ?? event.start.add(const Duration(hours: 1)),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        hintText: 'Enter event title',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: ValueListenableBuilder(
                        valueListenable: startTime,
                        builder: (context, time, _) {
                          return Text(time.format(context));
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: ValueListenableBuilder(
                        valueListenable: endTime,
                        builder: (context, time, _) {
                          return Text(time.format(context));
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [],
        );
      },
    );
  }

  List<DayEvent<String>> _getEventsForDay(DateTime day) {
    return _events
        .where(
          (event) =>
              event.start.year == day.year &&
              event.start.month == day.month &&
              event.start.day == day.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.selectedDay != null) ...[
          _buildDateHeader(),
          _buildDayView(),
        ],
      ],
    );
  }

  Widget _buildDateHeader() {
    return GestureDetector(
      onTap: widget.onDateTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Text(
          DateFormat.yMMMMd().format(widget.selectedDay!),
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDayView() {
    return Expanded(
      child: CalendarDayView.overflow(
        events: _getEventsForDay(widget.selectedDay!),
        config: OverFlowDayViewConfig(
          currentDate: widget.selectedDay!,
          timeGap: 30,
          heightPerMin: 1.5,
          startOfDay: const TimeOfDay(hour: 0, minute: 0),
          endOfDay: const TimeOfDay(hour: 23, minute: 59),
          showCurrentTimeLine: true,
          dividerColor: Colors.grey.shade300,
          renderRowAsListView: true,
        ),
        overflowItemBuilder: (context, constraints, index, event) {
          return GestureDetector(
            onTap: () => _editEvent(context, event),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade800, Colors.purple.shade800],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.value,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.getTimeRangeString(context),
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
