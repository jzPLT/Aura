import 'package:flutter/material.dart';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/event.dart';

class EventDetails extends StatelessWidget {
  final DayEvent<String> event;
  final Function(DayEvent<String>) onEdit;

  const EventDetails({super.key, required this.event, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onEdit(event),
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
  }
}
