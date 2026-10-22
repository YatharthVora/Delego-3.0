import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:delego/constants/sponsors.dart';

/// A row of sponsor logos that drifts sideways forever. It pauses while a finger is on
/// it, opens [onTap] when tapped, and holds still if the phone has animations turned
/// off (the logos are then laid out in a wrapped, centred group instead).
class SponsorMarquee extends StatefulWidget {
  const SponsorMarquee({
    super.key,
    this.onTap,
    this.speed = 36, // logical pixels per second
    this.height = 68,
  });

  final VoidCallback? onTap;
  final double speed;
  final double height;

  @override
  State<SponsorMarquee> createState() => _SponsorMarqueeState();
}

class _SponsorMarqueeState extends State<SponsorMarquee>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = (now - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = now;
    if (_paused || !_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.offset + widget.speed * dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _logo(Sponsor sponsor) {
    final baseLogoHeight = widget.height - 26;
    final logoHeight = (baseLogoHeight * sponsor.scale).clamp(24.0, widget.height - 10);
    final horizontalPad = sponsor.scale > 1.2
        ? 22.0
        : (sponsor.scale > 1.05 ? 18.0 : 14.0);

    return Center(
      child: Container(
        height: ( (widget.height - 12) * (sponsor.scale > 1.0 ? (0.92 + (sponsor.scale - 1.0) * 0.35) : 0.88) )
            .clamp(38.0, widget.height - 2),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 6),
        decoration: BoxDecoration(
          color: Color(sponsor.backgroundColorHex),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sponsor.scale > 1.2
                ? const Color(0xFFEE1C9C)
                : Colors.white.withValues(alpha: 0.18),
            width: sponsor.scale > 1.2 ? 1.8 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          sponsor.logo,
          height: logoHeight,
          fit: BoxFit.contain,
          cacheHeight: 200,
          excludeFromSemantics: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;

    final Widget body = still
        ? Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [for (final s in kSponsors) _logo(s)],
          )
        : SizedBox(
            height: widget.height,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0, 0.08, 0.92, 1],
              ).createShader(rect),
              child: Listener(
                onPointerDown: (_) => _paused = true,
                onPointerUp: (_) => _paused = false,
                onPointerCancel: (_) => _paused = false,
                child: ListView.builder(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  // No itemCount: the list repeats the sponsors for as long as it runs.
                  itemBuilder: (_, i) => _logo(kSponsors[i % kSponsors.length]),
                ),
              ),
            ),
          );

    return Semantics(
      button: widget.onTap != null,
      label: 'Our sponsors. Tap to see all.',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: body,
        ),
      ),
    );
  }
}
