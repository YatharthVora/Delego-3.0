import 'package:flutter_test/flutter_test.dart';

import 'package:delego/Pages/Qr_Page/Qr_scanner.dart';

List<String> meals(DateTime day) => mealsOn(day).map((m) => m.value).toList();

void main() {
  test('no breakfast on day 1 (30 Oct)', () {
    expect(meals(DateTime(2026, 10, 30, 7)), ['lunch', 'high_tea']);
    expect(meals(DateTime(2026, 10, 30, 23, 59)), ['lunch', 'high_tea']);
  });

  test('all three meals on the other days', () {
    for (final day in [
      DateTime(2026, 10, 29, 23, 59),
      DateTime(2026, 10, 31),
      DateTime(2026, 11, 1),
    ]) {
      expect(meals(day), ['breakfast', 'lunch', 'high_tea'], reason: '$day');
    }
  });
}
