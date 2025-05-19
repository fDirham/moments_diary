import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:moments_diary/models/monthly_activity_doc.dart';
import 'package:moments_diary/models/note.dart';
import 'package:moments_diary/models/note_database.dart';
import 'package:moments_diary/utils.dart';
import 'package:moments_diary/widgets/note_list.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CalendarContent extends StatefulWidget {
  const CalendarContent({super.key});

  @override
  State<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<CalendarContent> {
  static final logger = Logger("CalendarContent");

  var _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();
  var _startDate = DateTime.now();
  var _endDate = DateTime.now().add(Duration(seconds: 300));
  var _isEmpty = true;
  var _dayNotes = <Note>[];

  MonthlyActivityDoc? _monthlyActivityDoc;

  @override
  void initState() {
    super.initState();

    _isEmpty = context.read<NoteDatabase>().currentNotes.isEmpty;
    loadRanges();
    loadMonthlyActivityDoc();
    loadDayNotes();
  }

  void loadRanges() async {
    logger.info("Loading calendar ranges");

    final retrievedStart = await getCalendarStartDate();
    final retrievedEnd = await getCalendarEndDate();

    // get first day of month for start date
    final newStartDate = DateTime(
      retrievedStart?.year ?? DateTime.now().year,
      retrievedStart?.month ?? DateTime.now().month,
      1,
    );

    final sameStartAndEnd = _startDate == _endDate;

    if (!mounted) return;

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

  void loadMonthlyActivityDoc() async {
    logger.info("Loading monthly activity doc");

    final year = _focusedDay.year;
    final month = _focusedDay.month;

    final doc = await MonthlyActivityDoc.readFromDisk(year, month);

    setState(() {
      _monthlyActivityDoc = doc;
    });
  }

  void loadDayNotes() async {
    logger.info("Loading day notes");

    final noteDB = context.read<NoteDatabase>();
    final notes = await noteDB.fetchDayNotes(_selectedDay);

    setState(() {
      _dayNotes = notes;
    });
  }

  void onRevisible() {
    loadMonthlyActivityDoc();
    loadDayNotes();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayString = DateFormat.yMMMEd(
      Intl.getCurrentLocale(),
    ).format(_selectedDay);

    if (_isEmpty) {
      return Center(
        child: Text(
          "No notes yet",
          style: TextStyle(color: colorScheme.onSurface),
        ),
      );
    }

    return VisibilityDetector(
      key: const Key("calendars"),
      onVisibilityChanged: (info) {
        if (info.visibleFraction != 0) {
          onRevisible();
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              dayString,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: _startDate,
              lastDay: _endDate,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                loadMonthlyActivityDoc();
              },
              calendarFormat: CalendarFormat.month,
              headerVisible: true,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
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

                  if (_monthlyActivityDoc == null) {
                    return null;
                  }

                  final dailyActivity =
                      _monthlyActivityDoc!.dailyActivities[day.day];

                  if (dailyActivity == null) {
                    return null;
                  }
                  final numNotes = dailyActivity.numNotes;

                  if (numNotes == 0) {
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
            ),
            if (_monthlyActivityDoc != null)
              DayInfo(
                monthlyActivityDoc: _monthlyActivityDoc!,
                day: _selectedDay.day,
                dayNotes: _dayNotes,
              ),
          ],
        ),
      ),
    );
  }
}

class DayInfo extends StatelessWidget {
  final MonthlyActivityDoc monthlyActivityDoc;
  final int day;
  final List<Note> dayNotes;

  const DayInfo({
    super.key,
    required this.monthlyActivityDoc,
    required this.day,
    required this.dayNotes,
  });

  @override
  Widget build(BuildContext context) {
    final dailyActivity = monthlyActivityDoc.dailyActivities[day];

    if (dailyActivity == null) {
      return const SizedBox.shrink();
    }

    var numNotesText = "Notes: ${dailyActivity.numNotes}";
    var hasReflectionText =
        "Reflections: ${dailyActivity.hasReflection ? "Yes" : "No"}";

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  numNotesText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                Text(
                  hasReflectionText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          if (dayNotes.isNotEmpty) NoteList(notes: dayNotes),
        ],
      ),
    );
  }
}
