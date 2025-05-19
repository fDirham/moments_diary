import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarContent extends StatefulWidget {
  const CalendarContent({super.key});

  @override
  State<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<CalendarContent> {
  var _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    final kLastDay = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    return TableCalendar(
      focusedDay: _selectedDay,
      firstDay: kFirstDay,
      lastDay: kLastDay,
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
          if (day == _selectedDay) {
            return null;
          }
          return Container(
            margin: const EdgeInsets.all(4.0),
            width: 10,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        },
      ),
    );
  }
}
