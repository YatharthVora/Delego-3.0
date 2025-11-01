import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';

// Widget for displaying the full day's schedule list, using theme
class SchedulePageBody extends StatelessWidget {
  final List<Schedule> schedules;

  const SchedulePageBody({required this.schedules, super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (schedules.isEmpty) {
      return Expanded(
        child: Container(
          color: scheme.surface,
          child: const Center(
            child: Text(
              "No events scheduled for this day.",
              style: TextStyle(fontSize: 16.0, color: Colors.black54),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        color: scheme.surface,
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => ScheduleSummary(schedules[index]),
                  childCount: schedules.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
