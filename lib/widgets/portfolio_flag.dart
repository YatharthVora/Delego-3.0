import 'dart:math' as math;

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// A portfolio's flag (bundled, works offline); for a person, their party badge when
/// they have one (PSC), else a person icon.
class PortfolioFlag extends StatelessWidget {
  const PortfolioFlag(
      {super.key, required this.code, this.tag, this.width = 36});

  /// ISO alpha-2, lower case (as stored on the floor), or custom historical/faction
  /// codes ('cn-ccp', 'tw-kmt', 'de-imp'); null for a person.
  final String? code;

  /// A person's party abbreviation ("BJP", "SS(UBT)").
  final String? tag;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 3 / 4;
    final theme = ImageTheme(
      width: width,
      height: height,
      shape: const RoundedRectangle(4),
    );
    final code = this.code;
    final Widget flag;
    if (code == null && tag != null) {
      // As wide as the abbreviation needs: "SS(UBT)" stays as legible as "BJP".
      return ExcludeSemantics(
          child: _TagBadge(width: width, height: height, tag: tag!));
    } else if (code == null) {
      flag = _Box(width: width, height: height, icon: Icons.person);
    } else if (code == 'eu') {
      // The package maps the EU flag from its currency, not a country code.
      flag = CountryFlag.fromCurrencyCode('EUR', theme: theme);
    } else if (code == 'un') {
      flag = _Box(width: width, height: height, icon: Icons.public);
    } else if (code == 'cn-ccp') {
      flag = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          size: Size(width, height),
          painter: const _CcpFlagPainter(),
        ),
      );
    } else if (code == 'tw-kmt') {
      flag = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          size: Size(width, height),
          painter: const _KmtFlagPainter(),
        ),
      );
    } else if (code == 'de-imp') {
      flag = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          size: Size(width, height),
          painter: const _DeImpFlagPainter(),
        ),
      );
    } else {
      flag = CountryFlag.fromCountryCode(code, theme: theme);
    }
    return ExcludeSemantics(
        child: SizedBox(width: width, height: height, child: flag));
  }
}

/// Chinese Communist Party flag: red field with golden hammer & sickle in top-left canton.
class _CcpFlagPainter extends CustomPainter {
  const _CcpFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEE1C25);
    canvas.drawRect(Offset.zero & size, bg);

    final tp = TextPainter(
      text: TextSpan(
        text: '\u262D',
        style: TextStyle(
          color: const Color(0xFFFFDE00),
          fontSize: size.height * 0.52,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(size.width * 0.09, size.height * 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant _CcpFlagPainter oldDelegate) => false;
}

/// Kuomintang (Blue Sky with a White Sun) flag: navy blue field with 12-ray white sun.
class _KmtFlagPainter extends CustomPainter {
  const _KmtFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const blue = Color(0xFF000095);
    canvas.drawRect(Offset.zero & size, Paint()..color = blue);

    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.height * 0.36;
    final innerR = size.height * 0.19;
    final starPath = Path();
    for (int i = 0; i < 24; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / 12) - (math.pi / 2);
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        starPath.moveTo(pt.dx, pt.dy);
      } else {
        starPath.lineTo(pt.dx, pt.dy);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = Colors.white);
    canvas.drawCircle(center, size.height * 0.175, Paint()..color = blue);
    canvas.drawCircle(
        center, size.height * 0.145, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _KmtFlagPainter oldDelegate) => false;
}

/// German horizontal tricolour (Black - White - Red) for Dr. Oskar Trautmann.
class _DeImpFlagPainter extends CustomPainter {
  const _DeImpFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, h),
      Paint()..color = const Color(0xFF111111),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h, size.width, h),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 2, size.width, h),
      Paint()..color = const Color(0xFFDD0000),
    );
  }

  @override
  bool shouldRepaint(covariant _DeImpFlagPainter oldDelegate) => false;
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.icon});

  final double width;
  final double height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: height * 0.8, color: scheme.onSurfaceVariant),
    );
  }
}

/// A party abbreviation in a neutral badge the size of a flag (no party colours or logos:
/// the chrome stays monochrome, and logos would be trademarked downloads).
class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.width, required this.height, required this.tag});

  /// The flag's size: the badge is at least this wide and exactly this tall.
  final double width;
  final double height;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(minWidth: width, minHeight: height, maxHeight: height),
      padding: EdgeInsets.symmetric(horizontal: height * 0.15),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      // widthFactor 1: as wide as the text (not the whole slot), centred in the height.
      child: Center(
        widthFactor: 1,
        child: Text(
          tag,
          maxLines: 1,
          softWrap: false,
          textScaler: TextScaler.noScaling, // sized to the flag box, like a flag
          style: TextStyle(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.w700,
            fontSize: height * 0.48,
            height: 1,
          ),
        ),
      ),
    );
  }
}
