import 'package:flutter_test/flutter_test.dart';

import 'package:delego/models/floor_state.dart';

Map<String, dynamic> timerJson({
  String kind = 'idle',
  String? list,
  String? speakerId,
  int duration = 0,
  bool running = false,
  int? endsAt,
  int remainingMs = 0,
}) =>
    {
      'kind': kind,
      'list': list,
      'speaker_id': speakerId,
      'duration': duration,
      'running': running,
      'ends_at': endsAt,
      'remaining_ms': remainingMs,
    };

FloorState stateWith(Map<String, dynamic> timer, {String display = 'gsl'}) =>
    FloorState.fromJson({
      'version': 3,
      'updated_by': 'eb@example.com',
      'display': display,
      'lists': {
        'gsl': {
          'speaker_seconds': 90,
          'entries': [
            {'id': 'a', 'name': 'India', 'code': 'in'},
            {'id': 'b', 'name': 'Ms Rao', 'code': null, 'tag': 'INC'},
          ],
        },
        'mod': {'speaker_seconds': 60, 'entries': []},
      },
      'timer': timer,
    });

void main() {
  test('parses the server state', () {
    final s = stateWith(timerJson());
    expect(s.version, 3);
    expect(s.list('gsl').entries.map((e) => e.name), ['India', 'Ms Rao']);
    expect(s.list('gsl').entries[1].code, isNull);
    expect(s.list('gsl').entries[1].tag, 'INC');
    expect(s.list('gsl').entries[0].tag, isNull);
    expect(s.list('mod').speakerSeconds, 60);
    expect(s.timer.isIdle, isTrue);
  });

  test('the current speaker is the timed one, else the first', () {
    expect(stateWith(timerJson()).currentSpeaker('gsl')?.id, 'a');
    final timed = stateWith(timerJson(
      kind: 'speaker', list: 'gsl', speakerId: 'b', duration: 90, running: true, endsAt: 1000,
    ));
    expect(timed.currentSpeaker('gsl')?.id, 'b');
    expect(timed.currentSpeaker('mod'), isNull);
  });

  test('an idle list clock shows its speaking time', () {
    final r = readClock(stateWith(timerJson()), 'gsl', 0);
    expect(r.mode, ClockMode.idle);
    expect(formatClock(r.ms), '01:30');
    expect(r.progress, 0);
  });

  test('a running clock counts down from ends_at on the server clock', () {
    final s = stateWith(timerJson(
      kind: 'speaker', list: 'gsl', speakerId: 'a', duration: 90, running: true,
      endsAt: 100000, remainingMs: 90000,
    ));
    final r = readClock(s, 'gsl', 100000 - 45000);
    expect(r.mode, ClockMode.running);
    expect(formatClock(r.ms), '00:45');
    expect(r.progress, closeTo(0.5, 0.001));
    expect(readClock(s, 'gsl', 100000 - 9000).low, isTrue);
    final done = readClock(s, 'gsl', 100500);
    expect(done.mode, ClockMode.done);
    expect(formatClock(done.ms), '00:00');
    // The other list's clock is not this timer.
    expect(readClock(s, 'mod', 0).mode, ClockMode.idle);
  });

  test('a paused clock holds its time left', () {
    final s = stateWith(timerJson(
      kind: 'speaker', list: 'gsl', speakerId: 'a', duration: 90, remainingMs: 30500,
    ));
    final r = readClock(s, 'gsl', 999999999);
    expect(r.mode, ClockMode.paused);
    expect(formatClock(r.ms), '00:31');
    expect(s.timer.isPaused, isTrue);
  });

  test('an unmod clock', () {
    final s = stateWith(
      timerJson(kind: 'unmod', duration: 600, running: true, endsAt: 600000, remainingMs: 600000),
      display: 'unmod',
    );
    expect(formatClock(readClock(s, 'unmod', 0).ms), '10:00');
    expect(readClock(s, 'gsl', 0).mode, ClockMode.idle);
  });

  test('formatClock rounds up', () {
    expect(formatClock(0), '00:00');
    expect(formatClock(1), '00:01');
    expect(formatClock(59001), '01:00');
    expect(formatClock(5999000), '99:59');
  });

  group('ServerClock', () {
    test('uses the middle of the round trip', () {
      final c = ServerClock();
      c.sampleRequest(10000, 1000, 1200); // server 10 000 at local 1 100
      expect(c.offsetMs, 8900);
      expect(c.nowMs(2000), 10900);
    });

    test('a push only counts before any request sample', () {
      final c = ServerClock();
      c.samplePush(5000, 1000);
      expect(c.offsetMs, 4000);
      c.sampleRequest(10000, 1000, 1200);
      c.samplePush(50000, 1000);
      expect(c.offsetMs, 8900);
    });

    test('a much slower round trip is ignored', () {
      final c = ServerClock();
      c.sampleRequest(10000, 1000, 1100);
      c.sampleRequest(20000, 1000, 3000);
      expect(c.offsetMs, 10000 - 1050);
    });
  });
}
