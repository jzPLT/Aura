import 'package:aura_mobile/features/calendar/components/calendar_view.dart';
import 'package:aura_mobile/features/calendar/components/schedule_view.dart';
import 'package:aura_mobile/features/calendar/services/schedule_service.dart';
import 'package:aura_mobile/features/calendar/state/calendar_state.dart';
import 'package:aura_mobile/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _notesController = TextEditingController();

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
    _notesController.dispose();
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
                      Colors.black.withOpacity(1.0),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthProvider>().signOut();
                    },
                  ),
                ],
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
                child: ScheduleView(
                  selectedDay: _selectedDay,
                  onDateTap: _toggleMonthView,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade500.withOpacity(0.2),
                    Colors.purple.shade300.withOpacity(0.2),
                    Colors.pink.shade200.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Add a goal...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 20.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade800, Colors.purple.shade800],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          if (_notesController.text.isEmpty) return;

                          final calendarState = context.read<CalendarState>();
                          calendarState.setLoading(true);

                          try {
                            final scheduleService = ScheduleService();
                            final entry = await scheduleService
                                .createScheduleEntry(_notesController.text);

                            // calendarState.addScheduleEntries(entry);
                            _notesController.clear();

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            calendarState.setError(e.toString());
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            calendarState.setLoading(false);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
