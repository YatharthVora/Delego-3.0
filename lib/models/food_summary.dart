/// What the admin's Food page shows (server: GET /food/today and
/// GET /food/today/scans?scanner=): today's plates across all meals, by diet, and how
/// many each person scanned, with the delegates they scanned.
library;

class ScannerCount {
  ScannerCount(Map<String, dynamic> j)
      : email = '${j['email']}',
        name = '${j['name']}',
        count = (j['count'] as num).toInt();

  final String email;
  final String name;
  final int count;
}

class FoodToday {
  FoodToday(Map<String, dynamic> j)
      : date = DateTime.parse('${j['date']}'),
        total = (j['total'] as num? ?? 0).toInt(),
        veg = (j['veg'] as num? ?? 0).toInt(),
        jain = (j['jain'] as num? ?? 0).toInt(),
        scanners = [
          for (final s in (j['scanners'] as List? ?? const []))
            ScannerCount(s as Map<String, dynamic>),
        ];

  /// The conference's date the numbers are for (a date only, no time).
  final DateTime date;
  final int total;
  final int veg;
  final int jain;
  final List<ScannerCount> scanners; // most plates first
}

class ScannedPlate {
  ScannedPlate(Map<String, dynamic> j)
      : delegateId = '${j['delegate_id']}',
        name = '${j['name']}',
        meal = '${j['meal']}',
        diet = j['diet'] as String?,
        at = DateTime.parse('${j['at']}').toLocal();

  final String delegateId;
  final String name;
  final String meal;
  final String? diet;
  final DateTime at;
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Saturday, 31 Oct": the date the page's numbers are for.
String dateHeading(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// The server's meal names ("hitea" for high tea) as the scanner labels them.
String mealLabel(String meal) => switch (meal) {
      'breakfast' => 'Breakfast',
      'lunch' => 'Lunch',
      'hitea' || 'high_tea' => 'High Tea',
      _ => meal,
    };

String dietLabel(String? diet) => switch (diet) {
      'veg' => 'Veg',
      'jain' => 'Jain',
      'non_veg' => 'Non-veg',
      _ => 'No diet',
    };
