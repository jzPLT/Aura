import 'package:aura_mobile/features/calendar/components/calendar_view.dart';
import 'package:aura_mobile/features/calendar/components/schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.title});

  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMonthViewVisible = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _isAnimating = false;
      }
    });

    // Start with month view visible
    _animationController.value = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMonthView() {
    if (_isAnimating) return;
    _isAnimating = true;
    setState(() {
      _isMonthViewVisible = !_isMonthViewVisible;
      if (_isMonthViewVisible) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isAnimating) return false;

    if (notification is ScrollStartNotification) {
      // If scrolling starts and we're going up, hide the month view
      if (_isMonthViewVisible) {
        _toggleMonthView();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.blue.shade900,
                      Colors.purple.shade900,
                      Colors.pink.shade300,
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              AppBar(
                title: Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            CalendarView(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: (focusedDay, selectedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = selectedDay;
                });
              },
              animation: _animation,
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade900.withOpacity(0.05),
                        Colors.purple.shade900.withOpacity(0.05),
                        Colors.pink.shade300.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: ScheduleView(
                    selectedDay: _selectedDay,
                    onDateTap: _toggleMonthView,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
