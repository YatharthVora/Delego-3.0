import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:delego/api/api_client.dart';
import 'package:delego/models/floor_state.dart';

/// The outcome of one floor op. [status] is the HTTP code (0 when the request failed).
class FloorOpResult {
  const FloorOpResult(this.status, [this.detail]);

  final int status;
  final String? detail;

  bool get ok => status == 200;
  bool get conflict => status == 409;
}

/// One committee's live floor for EB Tools (mundra floor.py).
///
/// Changes go to POST /committees/{id}/floor/ops and the reply is applied straight away;
/// every change (from either EB's phone, or the server when a speaker's time runs out)
/// also arrives on WS /ws/committees/{id}/floor. Frames older than what we have are
/// ignored, so the order they arrive in doesn't matter.
///
/// A dead link must not look alive (a phone that switched Wi-Fi or was locked can keep a
/// half-open socket that never errors): the socket sends pings, and the server sends the
/// state at least every 20 s, so no frame for [staleAfter] means the link is dead and we
/// reconnect.
class FloorClient extends ChangeNotifier {
  /// Reconnect when nothing has arrived for this long (the server's heartbeat is 20 s).
  static const staleAfter = Duration(seconds: 45);

  /// How long an op or a read waits for the server before giving up.
  static const requestTimeout = Duration(seconds: 12);

  FloorClient(this._api, this.committeeId);

  final ApiClient _api;
  final int committeeId;
  final ServerClock clock = ServerClock();

  FloorState? state;

  /// The live socket is open and has sent the state.
  bool connected = false;

  /// The committee no longer exists: retrying won't help.
  bool closedForGood = false;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _retry;
  int _retryCount = 0;
  int _session = 0;
  bool _disposed = false;
  Timer? _watchdog;
  DateTime _lastFrameAt = DateTime.now();

  void start() {
    _refresh();
    _connect();
    _watchdog = Timer.periodic(const Duration(seconds: 5), (_) => _checkStale());
  }

  /// Reconnect now (the app came back to the foreground, the link went stale, or the
  /// user asked). Editing pauses until the new socket has sent the state.
  void reconnect() {
    if (_disposed || closedForGood) return;
    _retryCount = 0;
    connected = false;
    _notify();
    _connect();
    _refresh();
  }

  void _checkStale() {
    if (connected && DateTime.now().difference(_lastFrameAt) > staleAfter) reconnect();
  }

  void _apply(Map<String, dynamic> frame, {int? sentAt}) {
    final received = DateTime.now().millisecondsSinceEpoch;
    final serverNow = frame['server_now'] as int;
    if (sentAt != null) {
      clock.sampleRequest(serverNow, sentAt, received);
    } else {
      clock.samplePush(serverNow, received);
    }
    final next = FloorState.fromJson(frame['state'] as Map<String, dynamic>);
    if (state != null && next.version < state!.version) return;
    state = next;
    _notify();
  }

  Future<void> _refresh() async {
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    try {
      final res = await _api.get('/committees/$committeeId/floor').timeout(requestTimeout);
      if (res.statusCode == 200) {
        _apply(jsonDecode(res.body) as Map<String, dynamic>, sentAt: sentAt);
      } else if (res.statusCode == 404) {
        closedForGood = true;
        _notify();
      }
    } catch (_) {
      // The socket's reconnect loop retries.
    }
  }

  /// Send one op (see mundra models.FloorOp). Never throws.
  Future<FloorOpResult> send(Map<String, dynamic> op) async {
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    try {
      // Without a timeout a request on a dead network can hang for minutes.
      final res = await _api
          .postJson('/committees/$committeeId/floor/ops', op)
          .timeout(requestTimeout);
      if (res.statusCode == 200) {
        _apply(jsonDecode(res.body) as Map<String, dynamic>, sentAt: sentAt);
        return const FloorOpResult(200);
      }
      return FloorOpResult(res.statusCode, _detail(res.body));
    } on SessionExpired {
      return const FloorOpResult(401, 'Your session expired. Please log in again.');
    } on Forbidden {
      return const FloorOpResult(403, 'Your account can no longer change the floor.');
    } on TimeoutException {
      // It may still have reached the server: show what the floor really is now.
      _refresh();
      return const FloorOpResult(
        0,
        'No reply from the server, so that may not have gone through. Check the list before trying again.',
      );
    } catch (_) {
      return const FloorOpResult(0, 'No connection. Check the network and try again.');
    }
  }

  static String? _detail(String body) {
    try {
      final detail = (jsonDecode(body) as Map<String, dynamic>)['detail'];
      if (detail is String) return detail;
    } catch (_) {}
    return null;
  }

  // ------------------------------------------------------------------ live feed

  void _connect() {
    final session = ++_session;
    _retry?.cancel();
    _sub?.cancel();
    _channel?.sink.close();

    // https -> wss, http -> ws.
    final base = _api.baseUrl.replaceFirst('http', 'ws');
    // Pings make a half-open socket fail within seconds instead of never; the connect
    // timeout stops a handshake from hanging (a cold-starting server, a dead Wi-Fi).
    final WebSocketChannel channel = IOWebSocketChannel.connect(
      Uri.parse('$base/ws/committees/$committeeId/floor'),
      pingInterval: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 15),
    );
    _lastFrameAt = DateTime.now();
    _channel = channel;
    // A failed handshake also ends the stream below (which retries); don't let it escape
    // as an uncaught error too.
    channel.ready.catchError((_) {});
    _sub = channel.stream.listen(
      (data) {
        if (session != _session) return;
        try {
          final frame = jsonDecode(data as String) as Map<String, dynamic>;
          if (frame['type'] != 'state') return;
          _retryCount = 0;
          _lastFrameAt = DateTime.now();
          if (!connected) connected = true;
          _apply(frame);
        } catch (_) {}
      },
      onDone: () => _onClosed(session, channel.closeCode),
      onError: (_) => _onClosed(session, null),
      cancelOnError: true,
    );
  }

  void _onClosed(int session, int? code) {
    if (_disposed || session != _session) return;
    connected = false;
    if (code == 4404) {
      closedForGood = true;
      _notify();
      return;
    }
    _notify();
    final wait = Duration(seconds: 1 << _retryCount.clamp(0, 4)); // 1, 2, 4, 8, 16 s
    _retryCount++;
    _retry = Timer(wait, () {
      if (_disposed || session != _session) return;
      _connect();
      _refresh(); // catch up on anything missed while offline
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _session++;
    _watchdog?.cancel();
    _retry?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
