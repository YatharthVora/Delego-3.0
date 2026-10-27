import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/models/schedule_now.dart';
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

/// Checks if [schedule] on [dateText] is currently happening or already completed.
enum ScheduleLevelState { upcoming, live, completed }

ScheduleLevelState scheduleStateFor(Schedule schedule, String dateText) {
  final date = parseDisplayDate(dateText);
  final r = parseTimeRange(schedule.time);
  if (date == null || r == null) return ScheduleLevelState.upcoming;
  final now = DateTime.now();
  final s = DateTime(date.year, date.month, date.day, r.sh, r.sm);
  var e = DateTime(date.year, date.month, date.day, r.eh, r.em);
  if (!e.isAfter(s)) e = e.add(const Duration(days: 1));
  if (now.isAfter(e)) return ScheduleLevelState.completed;
  if (!now.isBefore(s) && now.isBefore(e)) return ScheduleLevelState.live;
  return ScheduleLevelState.upcoming;
}

/// Game-level node + floating event card positioned along the winding roadmap.
class ScheduleSummary extends StatelessWidget {
  final Schedule schedule;
  final int index;
  final bool isFirst;
  final bool isLast;
  final String dateText;
  final bool nodeOnLeft;

  const ScheduleSummary(
    this.schedule, {
    this.index = 0,
    this.isFirst = false,
    this.isLast = false,
    this.dateText = '',
    this.nodeOnLeft = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final swatch = kSwatches[index % kSwatches.length];
    final state = scheduleStateFor(schedule, dateText);
    final live = state == ScheduleLevelState.live;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Split "9:00 - 10:30 AM" into start / end.
    final parts = schedule.time.split(RegExp(r'\s*[-–—]\s*'));
    var start = parts.first.trim();
    final end = parts.length > 1 ? parts.sublist(1).join(' - ').trim() : '';
    final mer = RegExp(r'(AM|PM)', caseSensitive: false);
    if (end.isNotEmpty && !mer.hasMatch(start)) {
      final m = mer.firstMatch(end);
      if (m != null) start = '$start ${m.group(1)!.toUpperCase()}';
    }

    final badge = _LevelTile(
      index: index,
      swatch: swatch,
      icon: scheduleIconFor(schedule.name),
      state: state,
    );

    final card = Expanded(
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151426) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: live
                  ? Neon.pink
                  : swatch.colors.first.withValues(alpha: 0.65),
              width: live ? 2.2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (live ? Neon.pink : swatch.colors.last)
                    .withValues(alpha: live ? 0.35 : 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (live ? Neon.pink : swatch.colors.last)
                  .withValues(alpha: live ? 0.35 : 0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: swatch.colors),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    end.isNotEmpty ? '$start – $end' : start,
                    style: TextStyle(
                      fontFamily: Neon.font,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: swatch.nameColor,
                    ),
                  ),
                ),
                if (live)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Neon.pink,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'LIVE NOW',
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              schedule.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: Neon.font,
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
                height: 1.2,
                color: scheme.onSurface,
              ),
            ),
            if (schedule.location.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 13,
                    color: swatch.colors.first,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      schedule.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                        color: scheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: nodeOnLeft
          ? [
              badge,
              const SizedBox(width: 14),
              card,
            ]
          : [
              card,
              const SizedBox(width: 14),
              badge,
            ],
    );
  }
}

/// Chunky 3D game-level tile (matching the game roadmap style).
class _LevelTile extends StatelessWidget {
  final int index;
  final NeonSwatch swatch;
  final IconData icon;
  final ScheduleLevelState state;

  const _LevelTile({
    required this.index,
    required this.swatch,
    required this.icon,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final live = state == ScheduleLevelState.live;

    return GestureDetector(
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arched 3-star game level crown above the tile
            SizedBox(
              height: 22,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GridPainter(
                        color: Colors.black.withValues(alpha: 0.12),
                        step: 10,
                      ),
                    ),
                  ),
                  // Top glossy highlight
                  Positioned(
                    top: 3,
                    left: 6,
                    right: 6,
                    height: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 28,
                        color: swatch.nameColor,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: Neon.font,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 1.0,
                          color: swatch.nameColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
