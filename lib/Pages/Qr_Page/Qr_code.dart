import 'package:delego/widgets/mun_logo.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delego/widgets/neon.dart';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  String? _id;
  String _name = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Saved at login, so the badge still works with no connection.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final id = prefs.getString('id');
    final first = prefs.getString('firstname') ?? '';
    final last = prefs.getString('lastname') ?? '';
    setState(() {
      _id = (id == null || id.isEmpty) ? null : id;
      _name = '$first $last'.trim();
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(centerTitle: false, title: const Text('My QR Badge')),
      body: !_loaded
          ? const SizedBox.shrink()
          : _id == null
              ? _Empty(scheme: scheme)
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    // Slightly inset from the screen edges while still filling the page.
                    child: LayoutBuilder(
                      builder: (context, c) => Center(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: (c.maxHeight * 0.94).clamp(500.0, 680.0),
                            child: _Ticket(id: _id!, name: _name),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_rounded,
              size: 90, color: scheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No QR code available.',
              style: TextStyle(
                  fontFamily: Neon.font,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: scheme.onSurface)),
          const SizedBox(height: 8),
          Text('Sign in again, or contact the Organizing Committee.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

/// Clips one half of the ticket: rounded outer corners, semicircle bites where the
/// two halves meet.
class _HalfClipper extends CustomClipper<Path> {
  _HalfClipper({required this.top});
  final bool top;

  static const _r = 26.0;
  static const _notch = 14.0;

  @override
  Path getClip(Size s) {
    final rect = top
        ? RRect.fromRectAndCorners(Offset.zero & s,
            topLeft: const Radius.circular(_r),
            topRight: const Radius.circular(_r))
        : RRect.fromRectAndCorners(Offset.zero & s,
            bottomLeft: const Radius.circular(_r),
            bottomRight: const Radius.circular(_r));
    var path = Path()..addRRect(rect);
    final y = top ? s.height : 0.0;
    for (final x in [0.0, s.width]) {
      path = Path.combine(
          PathOperation.difference,
          path,
          Path()
            ..addOval(Rect.fromCircle(center: Offset(x, y), radius: _notch)));
    }
    return path;
  }

  @override
  bool shouldReclip(_HalfClipper old) => old.top != top;
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (double x = 22; x < size.width - 22; x += 12) {
      canvas.drawLine(Offset(x, 1), Offset(x + 6, 1), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _Ticket extends StatelessWidget {
  const _Ticket({required this.id, required this.name});
  final String id;
  final String name;

  @override
  Widget build(BuildContext context) {
    final sw = swatchFor(id);
    final mid = Color.lerp(sw.colors.first, sw.colors.last, 0.5)!;
    final shown = name.isEmpty ? 'Delegate' : name;

    Widget texture(Widget child, int seed) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter:
                    GridPainter(color: Colors.black.withValues(alpha: 0.08)),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: RingsPainter(
                    color: sw.accent.withValues(alpha: 0.55),
                    count: 10,
                    seed: seed),
              ),
            ),
            child,
          ],
        );

    final top = ClipPath(
      clipper: _HalfClipper(top: true),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [sw.colors.first, mid],
          ),
        ),
        child: texture(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('DELEGATE PASS',
                    style: Neon.label(sw.accent, size: 11.5, spacing: 3)),
                const SizedBox(height: 6),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: MunLogoLink(
                      child: FractionallySizedBox(
                        widthFactor: 0.85,
                        heightFactor: 0.88,
                        child: Image.asset(
                          'assets/images/logo_solid.webp',
                          fit: BoxFit.contain,
                          color: sw.accent,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  flex: 4,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Text(
                        shown,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: Neon.font,
                          fontWeight: FontWeight.w700,
                          fontSize: 38,
                          height: 1.05,
                          color: sw.nameColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          2,
        ),
      ),
    );

    final bottom = ClipPath(
      clipper: _HalfClipper(top: false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mid, sw.colors.last],
          ),
        ),
        child: texture(
          Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 2,
                child: CustomPaint(painter: _DashPainter(sw.accent)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Column(
                  children: [
                    Text('SHOW THIS AT THE FOOD COUNTER',
                        textAlign: TextAlign.center,
                        style: Neon.label(sw.accent, size: 11.5, spacing: 2)),
                    const SizedBox(height: 8),
                    // White plate + dark modules keep the code readable by the
                    // scanner; only the finder squares carry the ticket colour.
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final side = [
                            c.maxWidth * 0.72,
                            c.maxHeight * 0.94,
                          ].reduce((a, b) => a < b ? a : b);
                          return Center(
                            child: Container(
                              width: side,
                              height: side,
                              padding: EdgeInsets.all(side * 0.055),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Semantics(
                                label: 'Your food QR code',
                                child: QrImageView(
                                  data: id,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.Q,
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.circle,
                                    color: sw.eye,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ID: $id',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 13,
                          letterSpacing: 1,
                          color: sw.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Bon app\u00e9tit! Enjoy your meal',
                        style: TextStyle(
                          fontFamily: Neon.font,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.5,
                          color: sw.nameColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          9,
        ),
      ),
    );

    // stretch: both halves must take the full width, not the width of their content.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 4, child: top),
        Expanded(flex: 7, child: bottom),
      ],
    );
  }
}
