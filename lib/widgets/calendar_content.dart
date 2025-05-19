import 'package:flutter/material.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/utils.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CalendarContent extends StatefulWidget {
  const CalendarContent({super.key});

  @override
  State<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<CalendarContent> {
  var _selectedDay = DateTime.now();
  var _startDate = DateTime.now();
  var _endDate = DateTime.now().add(Duration(seconds: 300));
  var _isEmpty = true;

  @override
  void initState() {
    super.initState();

    _isEmpty = context.read<NoteDatabase>().currentNotes.isEmpty;
    initRanges();
  }

  void initRanges() async {
    final retrievedStart = await getCalendarStartDate();
    final retrievedEnd = await getCalendarEndDate();

    // get first day of month for start date
    final newStartDate = DateTime(
      retrievedStart?.year ?? DateTime.now().year,
      retrievedStart?.month ?? DateTime.now().month,
      1,
    );

    final sameStartAndEnd = _startDate == _endDate;

    final noteDB = context.read<NoteDatabase>();
    final notes = noteDB.currentNotes;

    setState(() {
      _startDate = newStartDate;
      _endDate =
          sameStartAndEnd
              ? newStartDate.add(Duration(seconds: 300))
              : retrievedEnd ?? DateTime.now();
      _isEmpty = notes.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isEmpty) {
      return VisibilityDetector(
        key: const Key("empty_calendar"),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction != 0) {
            initRanges();
          }
        },
        child: Center(
          child: Text(
            "No notes yet",
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      );
    }

    return TableCalendar(
      focusedDay: _selectedDay,
      firstDay: _startDate,
      lastDay: _endDate,
      calendarFormat: CalendarFormat.month,
      headerVisible: true,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: colorScheme.onSurface),
        todayDecoration: BoxDecoration(color: Colors.transparent),
        todayTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (day == _selectedDay || isSameDay(_selectedDay, day)) {
            return null;
          }
          return Container(
            margin: const EdgeInsets.all(4.0),
            width: 10,
            height: 3,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        },
      ),
    );
  }
}
