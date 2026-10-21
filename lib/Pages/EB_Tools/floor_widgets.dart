import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:delego/api/floor_client.dart';
import 'package:delego/models/floor_state.dart';

/// The brand colourway each floor view uses, the same as on the smartboard:
/// GSL pink, moderated caucus blue, unmoderated caucus green.
class FloorColourway {
  const FloorColourway(this.stops, this.positions, this.accent);

  final List<Color> stops;
  final List<double> positions;
  final Color accent;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: stops,
        stops: positions,
      );

  static const pink = FloorColourway(
    [Color(0xFFFF2BB4), Color(0xFFD6148C)],
    [0.0, 1.0],
    Color(0xFFFFFD2A),
  );
  static const blue = FloorColourway(
    [Color(0xFF005CFF), Color(0xFF0043C2)],
    [0.0, 1.0],
    Color(0xFFA9FF48),
  );
  static const green = FloorColourway(
    [Color(0xFF20BA6D), Color(0xFF159555)],
    [0.0, 1.0],
    Color(0xFF27FFFF),
  );

  static FloorColourway forView(String view) => switch (view) {
        'mod' => blue,
        'unmod' => green,
        _ => pink,
      };
}

const kFloorViewLabels = {
  'gsl': 'GSL',
  'mod': 'Mod',
  'unmod': 'Unmod',
};

/// Danger orange from the brand, for the last 10 seconds.
const kClockLow = Color(0xFFFF4E27);

/// Rebuilds a few times a second with the clock for [view], and buzzes the phone in the
/// last 10 seconds and when time is up.
class FloorClock extends StatefulWidget {
  const FloorClock({
    super.key,
    required this.client,
    required this.view,
    required this.builder,
  });

  final FloorClient client;
  final String view;
  final Widget Function(BuildContext context, ClockReading reading) builder;

  @override
  State<FloorClock> createState() => _FloorClockState();
}

class _FloorClockState extends State<FloorClock> {
  Timer? _ticker;
  ClockReading? _last;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  ClockReading? _read() {
    final s = widget.client.state;
    return s == null ? null : readClock(s, widget.view, widget.client.clock.nowMs());
  }

  void _tick() {
    final now = _read();
    final last = _last;
    if (now == null || !mounted) return;
    if (last != null && last.mode == ClockMode.running) {
      if (last.ms > 10000 && now.ms <= 10000 && now.ms > 0) HapticFeedback.lightImpact();
      if (last.ms > 0 && now.ms <= 0) HapticFeedback.heavyImpact();
    }
    if (last == null ||
        formatClock(last.ms) != formatClock(now.ms) ||
        last.mode != now.mode ||
        (last.progress - now.progress).abs() > 0.002) {
      setState(() => _last = now);
    } else {
      _last = now;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = _read() ?? const ClockReading(0, 0, ClockMode.idle);
    _last ??= reading;
    return widget.builder(context, reading);
  }
}

/// The big MM:SS readout.
class ClockText extends StatelessWidget {
  const ClockText(this.reading, {super.key, this.size = 72, this.color = Colors.white});

  final ClockReading reading;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        formatClock(reading.ms),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 1,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: reading.low
              ? kClockLow
              : color.withValues(alpha: reading.mode == ClockMode.idle ? 0.6 : 1),
        ),
      ),
    );
  }
}

/// A thin bar showing how much of the time is used.
class ClockBar extends StatelessWidget {
  const ClockBar(this.reading, {super.key, required this.color});

  final ClockReading reading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: reading.progress.clamp(0.0, 1.0),
        minHeight: 6,
        color: color,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
      ),
    );
  }
}

/// Minutes and seconds, 5 s to 99:59. Returns the seconds, or null if cancelled.
Future<int?> showDurationDialog(
  BuildContext context, {
  required String title,
  required int initialSeconds,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _DurationDialog(title: title, initialSeconds: initialSeconds),
  );
}

/// Owns its text controllers, so they are disposed only once the dialog has finished
/// closing (disposing them when showDialog returns crashes the closing animation).
class _DurationDialog extends StatefulWidget {
  const _DurationDialog({required this.title, required this.initialSeconds});

  final String title;
  final int initialSeconds;

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  late final _minutes = TextEditingController(text: '${widget.initialSeconds ~/ 60}');
  late final _seconds = TextEditingController(text: '${widget.initialSeconds % 60}');
  String? _error;

  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    super.dispose();
  }

  void _submit() {
    final total = (int.tryParse(_minutes.text) ?? 0) * 60 + (int.tryParse(_seconds.text) ?? 0);
    if (total < 5) {
      setState(() => _error = 'Enter at least 5 seconds.');
      return;
    }
    if (total > 99 * 60 + 59) {
      setState(() => _error = 'The maximum is 99:59.');
      return;
    }
    Navigator.pop(context, total);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minutes,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Minutes'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(':', style: TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: TextField(
                  controller: _seconds,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Seconds'),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Set')),
      ],
    );
  }
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  required String action,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
      ],
    ),
  );
  return ok ?? false;
}

void showFloorMessage(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}

/// Send an op that starts a timer; if another timer is running, ask before replacing it.
Future<FloorOpResult> startTimer(
  BuildContext context,
  FloorClient client,
  Map<String, dynamic> op,
) async {
  var res = await client.send({...op, 'replace': false});
  if (res.conflict && res.detail == 'Another timer is running' && context.mounted) {
    final ok = await confirm(
      context,
      title: 'Another timer is running',
      message: 'Stop it and start this one instead? Nobody is removed from a list.',
      action: 'Start this one',
    );
    if (!ok) return const FloorOpResult(200);
    res = await client.send({...op, 'replace': true});
  }
  if (!res.ok && context.mounted) {
    showFloorMessage(context, res.detail ?? 'That didn\'t work. Try again.');
  }
  return res;
}

/// Send an op and show the server's reason if it fails.
Future<FloorOpResult> sendOp(
  BuildContext context,
  FloorClient client,
  Map<String, dynamic> op,
) async {
  final res = await client.send(op);
  if (!res.ok && context.mounted) {
    showFloorMessage(context, res.detail ?? 'That didn\'t work. Try again.');
  }
  return res;
}
