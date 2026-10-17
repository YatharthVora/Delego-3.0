import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';

// Roadmap-style timeline for the selected day's events.
class SchedulePageBody extends StatelessWidget {
  final List<Schedule> schedules;
  final String dateText;

  const SchedulePageBody({required this.schedules, this.dateText = '', super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (schedules.isEmpty) {
      return Expanded(
        child: Container(
          color: scheme.surface,
          child: Center(
            child: Text(
              "No events scheduled for this day.",
              style: TextStyle(fontSize: 16.0, color: scheme.onSurface),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        color: scheme.surface,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
          itemCount: schedules.length,
          itemBuilder: (context, index) => ScheduleSummary(
            schedules[index],
            isFirst: index == 0,
            isLast: index == schedules.length - 1,
            dateText: dateText,
          ),
        ),
      ),
    );
  }
}
