import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart'; // Use the updated model
import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';

// Use a single widget that accepts the list of events
class SchedulePageBody extends StatelessWidget {
  final List<Schedule> schedules;

  const SchedulePageBody({required this.schedules, super.key});

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
              "No events scheduled for this day.",
              style: TextStyle(fontSize: 16.0, color: Colors.black54)
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        color: const Color(0xFFFFFFFF),
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
