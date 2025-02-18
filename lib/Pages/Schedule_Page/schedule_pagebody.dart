import 'package:flutter/material.dart';
import 'package:delego/models/shedule.dart';
import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';

/*
class ShedulePageBody extends StatelessWidget {
  const ShedulePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: new Container(
        color: new Color(0xFFFFFFFF),
        child: new CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          slivers: <Widget>[
            new SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              sliver: new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (context, index) => new ScheduleSummary(schedules[index]),
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

class HomePageBodyDay2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Container(
        color: new Color(0xFFFFFFFF),
        child: new CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          slivers: <Widget>[
            new SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              sliver: new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (context, index) => new ScheduleSummary(schedules1[index]),
                  childCount: schedules1.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

class HomePageBodyDay3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color(0xFFFFFFFF),
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => ScheduleSummary(schedules2[index]),
                  childCount: schedules2.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
