import 'package:flutter_test/flutter_test.dart';

import 'package:delego/models/break_coordination.dart';

int _id = 0;

BreakMsg msg(String type, {DateTime? at}) => BreakMsg({
      'id': ++_id,
      'sender': 'x@y.z',
      'sender_name': 'X',
      'type': type,
      'body': '',
      'payload': {'type': type, if (at != null) 'at': atPayload(at)},
      'created_at': '2026-10-30T07:00:00Z',
    });

void main() {
  final now = DateTime(2026, 10, 30, 12, 40);

  group('text', () {
    test('names clock times on a 12 hour clock, like the picker', () {
      expect(requestText(DateTime(2026, 10, 30, 13, 5)),
          'Free for a break at 1:05 PM');
      expect(acceptText(null, now), 'Accepted - come down now');
      expect(acceptText(10, now), 'Accepted - come in 10 min (12:50 PM)');
      expect(rejectText(5, now), 'Rejected - come in 5 min (12:45 PM)');
      expect(agreeText(DateTime(2026, 10, 30, 12, 50)),
          "Offer accepted - we'll come at 12:50 PM");
      expect(declineText(15, now),
          "Declined - we'll be free in 15 min (12:55 PM)");
    });

    test('noon, midnight and the morning', () {
      expect(clockTime(DateTime(2026, 10, 30, 12, 0)), '12:00 PM');
      expect(clockTime(DateTime(2026, 10, 30, 0, 5)), '12:05 AM');
      expect(clockTime(DateTime(2026, 10, 30, 9, 0)), '9:00 AM');
      expect(clockTime(DateTime(2026, 10, 30, 23, 59)), '11:59 PM');
    });
  });

  group('times', () {
    test('the picked time is sent exactly, never swapped for now', () {
      expect(breakTimeFor(12, 45, now), DateTime(2026, 10, 30, 12, 45));
      expect(breakTimeFor(23, 59, now), DateTime(2026, 10, 30, 23, 59));
      // Seconds into the current minute: that minute is still "now", not the past.
      final late = DateTime(2026, 10, 30, 12, 40, 59);
      expect(breakTimeFor(12, 40, late), DateTime(2026, 10, 30, 12, 40));
    });

    test('a time already gone is refused, not replaced', () {
      expect(breakTimeFor(12, 39, now), isNull);
      expect(
          breakTimeFor(2, 30, now), isNull); // 2:30 picked when 14:30 was meant
      expect(breakTimeFor(0, 0, now), isNull);
    });

    test('the picker always opens on PM', () {
      // Afternoon: the next 5 minutes, already PM.
      expect(pickerStart(now), DateTime(2026, 10, 30, 12, 45));
      expect(pickerStart(DateTime(2026, 10, 30, 15, 2)),
          DateTime(2026, 10, 30, 15, 5));
      // Morning: 12:00 PM, not the same numbers at night.
      expect(pickerStart(DateTime(2026, 10, 30, 10, 31)),
          DateTime(2026, 10, 30, 12));
      // 11:57 rounds to 12:00, which is PM.
      expect(pickerStart(DateTime(2026, 10, 30, 11, 57)),
          DateTime(2026, 10, 30, 12));
    });

    test('the picker starts at the next 5 minutes', () {
      expect(nextFiveMinutes(DateTime(2026, 10, 30, 12, 41, 30)),
          DateTime(2026, 10, 30, 12, 45));
      expect(nextFiveMinutes(now), DateTime(2026, 10, 30, 12, 45));
    });

    test('at survives the round trip through the payload', () {
      final at = DateTime(2026, 10, 30, 12, 50);
      expect(msg('reject', at: at).at, at);
      expect(msg('free').at, isNull);
    });
  });

  group('pendingOffer', () {
    final come = now.add(const Duration(minutes: 10));

    test('none without an offer', () {
      expect(pendingOffer([], now), isNull);
      expect(pendingOffer([msg('free', at: come)], now), isNull);
    });

    test('a reject or a later accept waits for the room', () {
      expect(pendingOffer([msg('free'), msg('reject', at: come)], now)?.type,
          'reject');
      expect(pendingOffer([msg('free'), msg('accept', at: come)], now)?.type,
          'accept');
    });

    test('accepting for now needs no answer', () {
      expect(pendingOffer([msg('free'), msg('accept')], now), isNull);
    });

    test('anything the room sends next answers it', () {
      for (final type in ['agree', 'decline', 'free', 'late']) {
        expect(pendingOffer([msg('reject', at: come), msg(type)], now), isNull,
            reason: type);
      }
    });

    test('ordinary messages after the offer do not hide it', () {
      expect(pendingOffer([msg('reject', at: come), msg('text')], now)?.type,
          'reject');
    });

    test('an offer from long ago is dropped', () {
      final old = now.subtract(const Duration(hours: 2));
      expect(pendingOffer([msg('reject', at: old)], now), isNull);
    });
  });
}
