import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/constants/fonts.dart';
import 'package:delego/constants/text_style.dart';
import 'package:delego/constants/separator.dart';
import 'package:delego/Pages/Schedule_Page/schedule_details.dart';

class ScheduleSummary extends StatelessWidget {
  final Schedule schedule;
  final bool horizontal;

  ScheduleSummary(this.schedule, {this.horizontal = true});
  ScheduleSummary.vertical(this.schedule) : horizontal = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final scheduleThumbnail = Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      alignment: horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: Hero(
        tag: "schedule-hero-${schedule.id}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            schedule.imageUrl,
            height: 92.0,
            width: 92.0,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    Widget _scheduleValue({String? value, String? image}) {
      return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Image.asset(image!, height: 12.0),
        const SizedBox(width: 8.0),
        Text(
          schedule.time ?? '',
          style: TextStyle(
            fontFamily: AppFontFamilies.mainFont,
            color: scheme.onPrimary,
          ),
        ),
      ]);
    }

    final scheduleCardContent = Container(
      margin: EdgeInsets.fromLTRB(
        horizontal ? 76.0 : 16.0,
        horizontal ? 16.0 : 42.0,
        16.0,
        16.0,
      ),
      constraints: BoxConstraints.expand(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 2.0),
            Text(
              schedule.name ?? '',
              style: Style.titleTextStyle?.copyWith(color: scheme.onPrimary),
            ),
            Container(height: 2.0),
            Text(
              schedule.location ?? '',
              style: Style.commonTextStyle?.copyWith(color: scheme.onPrimary.withOpacity(0.8)),
            ),
            Separator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: horizontal ? 1 : 0,
                  child: _scheduleValue(
                    value: schedule.time,
                    image: 'assets/img/ic_distance.png',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final scheduleCard = Container(
      child: scheduleCardContent,
      height: MediaQuery.of(context).size.height * 0.17,
      margin: horizontal ? EdgeInsets.only(left: 46.0) : EdgeInsets.only(top: 72.0),
      decoration: BoxDecoration(
        color: scheme.primary, // Theme support!
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.shadow.withOpacity(0.35), // Blended for theme
            blurRadius: 10.0,
            offset: Offset(0.0, 8.0),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: horizontal
          ? () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => DetailPage(schedule),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      )
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Stack(
          children: <Widget>[
            scheduleCard,
            scheduleThumbnail,
          ],
        ),
      ),
    );
  }
}
