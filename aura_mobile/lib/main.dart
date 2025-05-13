import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/rendering.dart';

extension DayEventX on DayEvent<String> {
  String getTimeRangeString(BuildContext context) {
    final startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    if (end == null) return startTime.format(context);
    final endTime = TimeOfDay(hour: end!.hour, minute: end!.minute);
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}

void main() {
  runApp(const AuraMobileApp());
}

class AuraMobileApp extends StatelessWidget {
  const AuraMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.purple.shade300,
          secondary: Colors.blue.shade300,
          surface: Colors.grey.shade900,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const LandingPage(title: 'Aura'),
    );
  }
}

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
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade900.withOpacity(0.5),
                  Colors.purple.shade900.withOpacity(0.5),
                  Colors.pink.shade300.withOpacity(0.5),
                ],
              ),
            ),
            child: AppBar(
              title: Text(widget.title),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
        body: Column(
          children: [
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime(2022),
                lastDay: DateTime(2026),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                headerStyle: HeaderStyle(formatButtonVisible: false),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 14),
                  weekendStyle: TextStyle(fontSize: 14),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    return Center(
                      child: Text(
                        DateFormat.E().format(day).substring(0, 1),
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
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
                              style: const TextStyle(
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
                            events: _getEventsForDay(_selectedDay!),
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
                              return GestureDetector(
                                onTap: () => _editEvent(context, event),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade800,
                                        Colors.purple.shade800,
                                      ],
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.getTimeRangeString(context),
                                        style: TextStyle(
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
                        ),
                      ],
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
                        child: TextField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
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
