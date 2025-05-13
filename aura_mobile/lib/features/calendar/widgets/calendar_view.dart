import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
          return selectedDay != null && isSameDay(selectedDay!, day);
        },
        headerStyle: const HeaderStyle(formatButtonVisible: false),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.outfit(fontSize: 14),
          weekendStyle: GoogleFonts.outfit(fontSize: 14),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: onDaySelected,
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
