import 'package:flutter/material.dart';

import 'package:delego/api/floor_client.dart';
import 'package:delego/models/floor_state.dart';
import 'package:delego/Pages/EB_Tools/floor_widgets.dart';

/// The unmoderated caucus timer. It runs on the server like the speaker timer, so both EB
/// phones and the smartboard (which shows it full screen) count down together.
class SessionTimerTab extends StatefulWidget {
  const SessionTimerTab({super.key, required this.client});

  final FloorClient client;

  @override
  State<SessionTimerTab> createState() => _SessionTimerTabState();
}

class _SessionTimerTabState extends State<SessionTimerTab>
    with AutomaticKeepAliveClientMixin {
  static const _presets = [5 * 60, 10 * 60, 15 * 60, 20 * 60];

  FloorClient get _client => widget.client;

  /// An op is in flight: the buttons wait for it, so a double tap can't pause and then
  /// resume, or start the unmod twice.
  bool _busy = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _guard(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start(FloorState s, int seconds) =>
      _guard(() => _doStart(s, seconds));

  Future<void> _doStart(FloorState s, int seconds) async {
    if (s.timer.kind == 'unmod' && s.timer.isActive) {
      final ok = await confirm(
        context,
        title: 'Restart the unmod?',
        message:
            'The running unmod is replaced with ${formatClock(seconds * 1000)}.',
        action: 'Restart',
      );
      if (!ok || !mounted) return;
    }
    await startTimer(
        context, _client, {'op': 'start_unmod', 'seconds': seconds});
  }

  Future<void> _custom(FloorState s) async {
    final seconds = await showDurationDialog(
      context,
      title: 'Unmod length',
      initialSeconds: s.timer.kind == 'unmod' && s.timer.duration > 0
          ? s.timer.duration
          : 600,
    );
    if (seconds != null && mounted) await _start(s, seconds);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    const colours = FloorColourway.green;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: ListenableBuilder(
        listenable: _client,
        builder: (context, _) {
          final s = _client.state;
          if (s == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final enabled = _client.connected && !_busy;
          final unmod = s.timer.kind == 'unmod';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: colours.gradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: FloorClock(
                  client: _client,
                  view: 'unmod',
                  builder: (context, reading) => Column(
                    children: [
                      Text(
                        'UNMODERATED CAUCUS',
                        style: TextStyle(
                          color: colours.accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClockText(reading, size: 88),
                      const SizedBox(height: 4),
                      Text(
                        switch (reading.mode) {
                          ClockMode.paused => 'PAUSED',
                          ClockMode.done => 'TIME',
                          ClockMode.running => 'RUNNING',
                          ClockMode.idle => 'PICK A LENGTH BELOW',
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClockBar(reading, color: colours.accent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (unmod)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: enabled
                            ? () => _guard(
                                () => sendOp(context, _client, {'op': 'reset'}))
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('End'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: enabled && s.timer.isActive
                            ? () => _guard(() => sendOp(context, _client,
                                {'op': s.timer.running ? 'pause' : 'resume'}))
                            : null,
                        icon: Icon(
                            s.timer.running ? Icons.pause : Icons.play_arrow),
                        label: Text(s.timer.running ? 'Pause' : 'Resume'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Text('Start an unmod',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'The smartboard switches to a full-screen countdown.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final secs in _presets)
                    ActionChip(
                      label: Text(
                        formatClock(secs * 1000),
                        style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                      onPressed: enabled ? () => _start(s, secs) : null,
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 18),
                    label: const Text('Custom'),
                    onPressed: enabled ? () => _custom(s) : null,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
