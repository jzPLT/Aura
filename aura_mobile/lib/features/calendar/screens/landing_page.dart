import 'package:flutter/material.dart';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/event_service.dart';
import '../widgets/calendar_view.dart';
import '../widgets/event_details.dart';

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
  final EventService _eventService = EventService();

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
      if (_isMonthViewVisible) {
        _toggleMonthView();
        return true;
      }
    }
    return false;
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
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
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              animation: _animation,
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                  child: Column(
                    children: [
                      if (_selectedDay != null) ...[
                        GestureDetector(
                          onTap: _toggleMonthView,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              DateFormat.yMMMMd().format(_selectedDay!),
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: CalendarDayView.overflow(
                            events: _eventService.getEventsForDay(
                              _selectedDay!,
                            ),
                            config: OverFlowDayViewConfig(
                              currentDate: _selectedDay!,
                              timeGap: 30,
                              heightPerMin: 1.0,
                              startOfDay: const TimeOfDay(hour: 0, minute: 0),
                              endOfDay: const TimeOfDay(hour: 23, minute: 59),
                              showCurrentTimeLine: true,
                              dividerColor: Colors.grey.shade300,
                              renderRowAsListView: true,
                            ),
                            overflowItemBuilder: (
                              context,
                              constraints,
                              index,
                              event,
                            ) {
                              return EventDetails(
                                event: event,
                                onEdit: (event) => _editEvent(context, event),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
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
