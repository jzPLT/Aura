import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Animation<double> animation;

  const CalendarView({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime(2022),
        lastDay: DateTime(2026),
        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },
        headerStyle: HeaderStyle(formatButtonVisible: false),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.outfit(fontSize: 14),
          weekendStyle: GoogleFonts.outfit(fontSize: 14),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade600, width: 1.5),
          ),
          todayTextStyle: GoogleFonts.outfit(color: Colors.grey.shade300),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          onDaySelected(selectedDay, focusedDay);
        },
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            return Center(
              child: Text(
                DateFormat.E().format(day).substring(0, 1),
                style: GoogleFonts.outfit(fontSize: 14),
              ),
            );
          },
        ),
      ),
    );
  }
}
