/// Break coordination between a committee room's OC and Hospitality.
///
/// The room asks for a break at a clock time (`free`) or says it is running late
/// (`late`). Hospitality accepts (`accept`, now or in a few minutes) or rejects with a
/// time to come instead (`reject`). When Hospitality names a time, the room agrees to
/// it (`agree`) or declines with a time of its own (`decline`). A time travels in the
/// message payload as `at` (ISO, UTC).
library;

/// The room's side of the conversation.
const roomActions = {'free', 'late', 'agree', 'decline'};

/// Hospitality's side.
const hospitalityActions = {'accept', 'reject'};

/// The delays offered on the split buttons.
const breakDelays = [5, 10, 15];

/// An offer older than this is no longer waiting for an answer.
const offerLifetime = Duration(hours: 1);

class BreakMsg {
  BreakMsg(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        sender = '${j['sender']}',
        senderName = '${j['sender_name']}',
        type = '${j['type']}',
        body = '${j['body']}',
        at = _time((j['payload'] as Map?)?['at']),
        createdAt = _time(j['created_at']);

  final int id;
  final String sender;
  final String senderName;
  final String type;
  final String body;

  /// The time this message names (break at, come at), local; null when it names none.
  final DateTime? at;
  final DateTime? createdAt;

  static DateTime? _time(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;
}

/// `at` as the app sends it.
String atPayload(DateTime at) => at.toUtc().toIso8601String();

/// 24 hour "HH:mm".
String hhmm(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}

/// Today at the picked clock time, but never before [now] (a time already gone means now).
DateTime breakTimeFor(int hour, int minute, DateTime now) {
  final at = DateTime(now.year, now.month, now.day, hour, minute);
  return at.isBefore(now) ? now : at;
}

/// [now] rounded up to the next 5 minutes, the time picker's starting point.
DateTime nextFiveMinutes(DateTime now) {
  final add = 5 - now.minute % 5;
  final t = now.add(Duration(minutes: add));
  return DateTime(t.year, t.month, t.day, t.hour, t.minute);
}

String requestText(DateTime at) => 'Free for a break at ${hhmm(at)}';

String acceptText(int? delay, DateTime now) => delay == null
    ? 'Accepted - come down now'
    : 'Accepted - come in $delay min (${hhmm(now.add(Duration(minutes: delay)))})';

String rejectText(int delay, DateTime now) =>
    'Canteen full - come in $delay min (${hhmm(now.add(Duration(minutes: delay)))})';

String agreeText(DateTime at) => "Offer accepted - we'll come at ${hhmm(at)}";

String declineText(int delay, DateTime now) =>
    "Declined - we'll be free in $delay min (${hhmm(now.add(Duration(minutes: delay)))})";

/// Hospitality's latest offer of a time, if the room has not answered it yet: the newest
/// break message, when it is an accept or reject that names a time no more than
/// [offerLifetime] ago. Anything the room sends after it (including a new request)
/// answers it. Messages are oldest first.
BreakMsg? pendingOffer(List<BreakMsg> messages, DateTime now) {
  for (final m in messages.reversed) {
    if (roomActions.contains(m.type)) return null;
    if (hospitalityActions.contains(m.type)) {
      final at = m.at;
      if (at == null || now.difference(at) > offerLifetime) return null;
      return m;
    }
  }
  return null;
}
