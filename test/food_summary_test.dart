import 'package:flutter_test/flutter_test.dart';

import 'package:delego/models/food_summary.dart';

void main() {
  test('reads the day, the totals and the scanners', () {
    final page = FoodToday({
      'date': '2026-10-31',
      'total': 5,
      'veg': 3,
      'jain': 2,
      'non_veg': 0,
      'unspecified': 0,
      'scanners': [
        {'email': 'riya@x', 'name': 'Riya Shah', 'count': 3},
        {'email': 'gone@x', 'name': 'gone@x', 'count': 2},
      ],
    });
    expect(dateHeading(page.date), 'Saturday, 31 Oct');
    expect((page.total, page.veg, page.jain), (5, 3, 2));
    expect(page.scanners.map((s) => (s.name, s.count)),
        [('Riya Shah', 3), ('gone@x', 2)]);
  });

  test('an empty day', () {
    final page = FoodToday({'date': '2026-10-30', 'scanners': []});
    expect(dateHeading(page.date), 'Friday, 30 Oct');
    expect((page.total, page.veg, page.jain), (0, 0, 0));
    expect(page.scanners, isEmpty);
  });

  test('a scanned plate, in local time, with readable meal and diet', () {
    final plate = ScannedPlate({
      'delegate_id': 'd1',
      'name': 'Kabir Rao',
      'meal': 'hitea',
      'diet': 'jain',
      'at': '2026-10-31T10:12:00Z',
    });
    expect(plate.at.isUtc, isFalse);
    expect(plate.at, DateTime.utc(2026, 10, 31, 10, 12).toLocal());
    expect(mealLabel(plate.meal), 'High Tea');
    expect(dietLabel(plate.diet), 'Jain');
    expect(mealLabel('lunch'), 'Lunch');
    expect(dietLabel(null), 'No diet');
  });

  test('every date reads right', () {
    expect(dateHeading(DateTime(2026, 11, 1)), 'Sunday, 1 Nov');
  });
}
