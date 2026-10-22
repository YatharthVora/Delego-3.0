import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';
import 'package:delego/widgets/neon.dart';

/// Game-levels style winding roadmap for the selected day's schedule.
class SchedulePageBody extends StatelessWidget {
  final List<Schedule> schedules;
  final String dateText;

  const SchedulePageBody({
    required this.schedules,
    this.dateText = '',
    super.key,
  });

  static const double _rowHeight = 144.0;
  static const double _topPad = 24.0;
  static const double _bottomPad = 40.0;
  static const double _hPad = 18.0;
  static const double _badgeCenterOffset = 40.0; // half of 80px _LevelTile width

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (schedules.isEmpty) {
      return Expanded(
        child: Container(
          color: scheme.surface,
          child: Center(
            child: Text(
              'No events scheduled for this day.',
              style: TextStyle(fontSize: 16.0, color: scheme.onSurface),
            ),
          ),
        ),
      );
    }

    final totalHeight =
        _topPad + _bottomPad + schedules.length * _rowHeight;

    return Expanded(
      child: Container(
        color: scheme.surface,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final leftX = _hPad + _badgeCenterOffset;
              final rightX = width - _hPad - _badgeCenterOffset;

              // Center points of each level badge along the winding S-curve road
              final centers = <Offset>[
                for (var i = 0; i < schedules.length; i++)
                  Offset(
                    i.isEven ? leftX : rightX,
                    _topPad + i * _rowHeight + _rowHeight * 0.54,
                  ),
              ];

              return SizedBox(
                width: width,
                height: totalHeight,
                child: Stack(
                  children: [
                    // Subtle poster grid + rings backdrop
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(
                          color: scheme.onSurface
                              .withValues(alpha: isDark ? 0.045 : 0.06),
                          step: 20,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: RingsPainter(
                          color: Neon.pink.withValues(alpha: 0.14),
                          count: 22,
                          seed: schedules.length + 7,
                          radius: 5,
                        ),
                      ),
                    ),
                    // Winding serpentine game road connecting all level nodes
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _WindingRoadPainter(
                          centers: centers,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    // Level nodes + cards along the road
                    for (var i = 0; i < schedules.length; i++)
                      Positioned(
                        top: _topPad + i * _rowHeight,
                        left: _hPad,
                        right: _hPad,
                        height: _rowHeight,
                        child: ScheduleSummary(
                          schedules[i],
                          index: i,
                          isFirst: i == 0,
                          isLast: i == schedules.length - 1,
                          dateText: dateText,
                          nodeOnLeft: i.isEven,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Draws the winding S-curve road with neon edges and center lane dashes.
class _WindingRoadPainter extends CustomPainter {
  final List<Offset> centers;
  final bool isDark;

  const _WindingRoadPainter({
    required this.centers,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.isEmpty) return;

    final path = Path();
    final first = centers.first;
    path.moveTo(first.dx, 0);
    path.lineTo(first.dx, first.dy);

    for (var i = 0; i < centers.length - 1; i++) {
      final p0 = centers[i];
      final p1 = centers[i + 1];
      final midY = (p0.dy + p1.dy) / 2;
      path.cubicTo(
        p0.dx,
        midY,
        p1.dx,
        midY,
        p1.dx,
        p1.dy,
      );
    }

    final last = centers.last;
    path.lineTo(last.dx, size.height);

    // 1. Outer neon glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 42
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Neon.pink.withValues(alpha: isDark ? 0.22 : 0.16);
    canvas.drawPath(path, glowPaint);

    // 2. Road curb / shoulder in signature gradient
    final curbPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFEE1C9C);
    canvas.drawPath(path, curbPaint);

    // 3. Inner road surface
    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isDark ? const Color(0xFF19172B) : const Color(0xFF232038);
    canvas.drawPath(path, roadPaint);

    // 4. Dashed center lane line
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Neon.yellow.withValues(alpha: 0.78);

    const dashLen = 10.0;
    const gapLen = 10.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = (d + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, next), dashPaint);
        d += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindingRoadPainter oldDelegate) =>
      oldDelegate.centers != centers || oldDelegate.isDark != isDark;
}
