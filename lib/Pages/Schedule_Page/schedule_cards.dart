import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/models/schedule_now.dart';
import 'package:delego/Pages/Schedule_Page/schedule_details.dart';
import 'package:delego/widgets/neon.dart';

/// Picks an icon for an event from keywords in its name.
IconData scheduleIconFor(String name) {
  final n = name.toLowerCase();
  bool has(List<String> keys) => keys.any(n.contains);
  if (has(['opening', 'inaugur'])) return Icons.mic_rounded;
  if (has(['registration', 'check-in', 'check in'])) {
    return Icons.how_to_reg_rounded;
  }
  if (has(['breakfast'])) return Icons.bakery_dining_rounded;
  if (has(['lunch'])) return Icons.restaurant_rounded;
  if (has(['dinner'])) return Icons.dinner_dining_rounded;
  if (has(['tea', 'snack', 'break', 'coffee'])) return Icons.coffee_rounded;
  if (has(['closing', 'valedictory', 'prize', 'award'])) {
    return Icons.emoji_events_rounded;
  }
  if (has(['social', 'party', 'delegate night', 'night'])) {
    return Icons.celebration_rounded;
  }
  if (has(['cultural'])) return Icons.theater_comedy_rounded;
  if (has(['gbm', 'session', 'committee', 'crisis', 'debate'])) {
    return Icons.gavel_rounded;
  }
  return Icons.event_rounded;
}

/// One node of the roadmap: time | node on the line | title + venue.
class ScheduleSummary extends StatelessWidget {
  final Schedule schedule;
  final bool isFirst;
  final bool isLast;
  final String dateText;

  const ScheduleSummary(
    this.schedule, {
    this.isFirst = false,
    this.isLast = false,
    this.dateText = '',
    super.key,
  });

  bool get _isLive {
    final date = parseDisplayDate(dateText);
    final r = parseTimeRange(schedule.time);
    if (date == null || r == null) return false;
    final now = DateTime.now();
    final s = DateTime(date.year, date.month, date.day, r.sh, r.sm);
    var e = DateTime(date.year, date.month, date.day, r.eh, r.em);
    if (!e.isAfter(s)) e = e.add(const Duration(days: 1));
    return !now.isBefore(s) && now.isBefore(e);
  }

  @override
  Widget build(BuildContext context) {
    final nonPink = [kSwatches[0], kSwatches[2], kSwatches[3]];
    var h = 0;
    for (final c in schedule.name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    final swatch = nonPink[h % nonPink.length];
    final live = _isLive;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Split "9:00 - 10:30 AM" into start / end.
    final parts = schedule.time.split(RegExp(r'\s*[-–—]\s*'));
    var start = parts.first.trim();
    final end = parts.length > 1 ? parts.sublist(1).join(' - ').trim() : '';
    final mer = RegExp(r'(AM|PM)', caseSensitive: false);
    if (end.isNotEmpty && !mer.hasMatch(start)) {
      final m = mer.firstMatch(end);
      if (m != null) start = '$start ${m.group(1)!.toUpperCase()}';
    }

    const lineW = 3.0;
    final lineColor = onSurface.withValues(alpha: 0.18);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DetailPage(schedule),
            transitionsBuilder: (context, animation, secondaryAnimation,
                    child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 78,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 14, right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      start,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: onSurface,
                      ),
                    ),
                    if (end.isNotEmpty)
                      Text(
                        end,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: Neon.font,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 56,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: isFirst ? 36 : 0,
                    bottom: isLast ? null : 0,
                    height: isLast ? 36 : null,
                    child: Container(width: lineW, color: lineColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: swatch.colors,
                        ),
                        border: Border.all(
                          color: live ? Neon.pink : Colors.white,
                          width: live ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (live ? Neon.pink : swatch.colors[1])
                                .withValues(alpha: live ? 0.6 : 0.35),
                            blurRadius: live ? 14 : 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        scheduleIconFor(schedule.name),
                        size: 22,
                        color: swatch.nameColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 18, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (live)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Neon.pink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'HAPPENING NOW',
                          style: TextStyle(
                            fontFamily: Neon.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Text(
                      schedule.name,
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.2,
                        color: onSurface,
                      ),
                    ),
                    if (schedule.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.place_rounded,
                              size: 13,
                              color: onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              schedule.location,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Neon.font,
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
