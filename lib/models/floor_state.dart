import 'dart:math';

import 'package:delego/constants/portfolios.dart';

/// A committee's live floor, as the server sends it (mundra floor.py): the GSL and the
/// moderated caucus list, the timer, and what the smartboard shows.
class FloorState {
  FloorState({
    required this.version,
    required this.updatedBy,
    required this.display,
    required this.lists,
    required this.timer,
  });

  final int version;
  final String? updatedBy;

  /// What the smartboard shows: 'gsl', 'mod' or 'unmod'.
  final String display;
  final Map<String, FloorList> lists;
  final FloorTimer timer;

  factory FloorState.fromJson(Map<String, dynamic> j) {
    final lists = (j['lists'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, FloorList.fromJson(v as Map<String, dynamic>)),
    );
    return FloorState(
      version: j['version'] as int,
      updatedBy: j['updated_by'] as String?,
      display: j['display'] as String,
      lists: lists,
      timer: FloorTimer.fromJson(j['timer'] as Map<String, dynamic>),
    );
  }

  FloorList list(String name) =>
      lists[name] ?? const FloorList(speakerSeconds: 60, entries: []);

  /// Whether the timer is for a speaker on this list (running or paused).
  bool timesList(String name) => timer.kind == 'speaker' && timer.list == name;

  /// The speaker being timed on this list, or else the first on it.
  FloorEntry? currentSpeaker(String name) {
    final entries = list(name).entries;
    if (timesList(name)) {
      for (final e in entries) {
        if (e.id == timer.speakerId) return e;
      }
    }
    return entries.isEmpty ? null : entries.first;
  }
}

class FloorList {
  const FloorList({required this.speakerSeconds, required this.entries});

  final int speakerSeconds;
  final List<FloorEntry> entries;

  factory FloorList.fromJson(Map<String, dynamic> j) => FloorList(
        speakerSeconds: j['speaker_seconds'] as int,
        entries: [
          for (final e in j['entries'] as List)
            FloorEntry.fromJson(e as Map<String, dynamic>),
        ],
      );
}

class FloorEntry {
  const FloorEntry({required this.id, required this.name, this.code, this.tag});

  final String id;
  final String name;

  /// Flag code (ISO alpha-2, lower case); null for a person.
  final String? code;

  /// A person's party abbreviation (PSC), shown as a badge.
  final String? tag;

  factory FloorEntry.fromJson(Map<String, dynamic> j) {
    final name = j['name'] as String;
    final rawCode = j['code'] as String?;
    final rawTag = j['tag'] as String?;
    return FloorEntry(
      id: j['id'] as String,
      name: name,
      code: (rawCode != null && rawCode.isNotEmpty)
          ? rawCode
          : cccCodeForName(name),
      tag: (rawTag != null && rawTag.isNotEmpty)
          ? rawTag
          : pscTagForName(name),
    );
  }
}

class FloorTimer {
  const FloorTimer({
    required this.kind,
    required this.list,
    required this.speakerId,
    required this.duration,
    required this.running,
    required this.endsAt,
    required this.remainingMs,
  });

  /// 'idle', 'speaker' or 'unmod'.
  final String kind;
  final String? list;
  final String? speakerId;

  /// Seconds the timer was started with.
  final int duration;
  final bool running;

  /// Epoch ms on the server clock, while running.
  final int? endsAt;

  /// While paused (0 once an unmod has run out).
  final int remainingMs;

  factory FloorTimer.fromJson(Map<String, dynamic> j) => FloorTimer(
        kind: j['kind'] as String,
        list: j['list'] as String?,
        speakerId: j['speaker_id'] as String?,
        duration: j['duration'] as int,
        running: j['running'] as bool,
        endsAt: j['ends_at'] as int?,
        remainingMs: j['remaining_ms'] as int,
      );

  bool get isIdle => kind == 'idle';

  /// Running, or paused with time left.
  bool get isActive => kind != 'idle' && (running || remainingMs > 0);

  bool get isPaused => !running && kind != 'idle' && remainingMs > 0;

  /// Time left at [serverNowMs] (server clock).
  int remainingAt(int serverNowMs) =>
      running && endsAt != null ? max(0, endsAt! - serverNowMs) : remainingMs;
}

/// The server's clock as seen from here: every countdown is drawn from the server's
/// ends_at, so phones and the board agree even if this phone's clock is off.
class ServerClock {
  int _offsetMs = 0;
  int? _bestRttMs;

  int get offsetMs => _offsetMs;

  /// A sample from a request: the server's time against the middle of the round trip.
  /// The fastest round trip seen so far is the most accurate, so it wins.
  void sampleRequest(int serverNowMs, int sentAtMs, int receivedAtMs) {
    final rtt = receivedAtMs - sentAtMs;
    if (_bestRttMs != null && rtt > _bestRttMs! * 2 + 50) return;
    if (_bestRttMs == null || rtt < _bestRttMs!) _bestRttMs = rtt;
    _offsetMs = serverNowMs - (sentAtMs + receivedAtMs) ~/ 2;
  }

  /// A sample from a pushed frame (one-way, so only used until a request sample exists).
  void samplePush(int serverNowMs, int receivedAtMs) {
    if (_bestRttMs == null) _offsetMs = serverNowMs - receivedAtMs;
  }

  int nowMs([int? localMs]) =>
      (localMs ?? DateTime.now().millisecondsSinceEpoch) + _offsetMs;
}

/// "01:30" for 90 000 ms, rounding up so the clock reads 00:00 exactly when time is up.
String formatClock(int ms) {
  final s = (ms / 1000).ceil();
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

enum ClockMode { idle, running, paused, done }

/// What a clock for [view] ('gsl', 'mod' or 'unmod') shows at [serverNowMs]. A list's
/// clock idles at its speaking time until a speaker on it is being timed.
class ClockReading {
  const ClockReading(this.ms, this.totalMs, this.mode);

  final int ms;
  final int totalMs;
  final ClockMode mode;

  /// 0..1, how much of the time is used.
  double get progress =>
      mode == ClockMode.idle || totalMs <= 0 ? 0 : 1 - ms / totalMs;

  bool get low => mode != ClockMode.idle && ms <= 10000;
}

ClockReading readClock(FloorState s, String view, int serverNowMs) {
  final t = s.timer;
  final forView = view == 'unmod' ? t.kind == 'unmod' : s.timesList(view);
  if (!forView) {
    final ms = view == 'unmod' ? 0 : s.list(view).speakerSeconds * 1000;
    return ClockReading(ms, ms, ClockMode.idle);
  }
  final ms = t.remainingAt(serverNowMs);
  final mode = ms <= 0
      ? ClockMode.done
      : (t.running ? ClockMode.running : ClockMode.paused);
  return ClockReading(ms, t.duration * 1000, mode);
}
