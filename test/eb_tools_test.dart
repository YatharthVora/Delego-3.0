// EB Tools screens with a fake floor (no network): adding, removing, the duration
// dialogs (which once crashed while closing because their controllers were disposed
// too early), and the committee picker flow.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Pages/EB_Tools/eb_tools_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delego/api/api_client.dart';
import 'package:delego/api/floor_client.dart';
import 'package:delego/constants/portfolios.dart';
import 'package:delego/models/floor_state.dart';
import 'package:delego/Pages/EB_Tools/speaker_list_tab.dart';
import 'package:delego/Pages/EB_Tools/session_timer_tab.dart';
import 'package:delego/Theme/app_theme.dart';

class FakeFloor extends FloorClient {
  FakeFloor() : super(ApiClient(baseUrl: 'http://x'), 1) {
    connected = true;
    state = make();
  }
  final List<Map<String, dynamic>> gsl = [];
  final List<Map<String, dynamic>> sent = [];

  /// Every op, in the order it reached the "server".
  final List<String> ops = [];
  Map<String, dynamic> timer = {
    'kind': 'idle',
    'list': null,
    'speaker_id': null,
    'duration': 0,
    'running': false,
    'ends_at': null,
    'remaining_ms': 0
  };
  int v = 1;
  int n = 0;
  FloorState make() => FloorState.fromJson({
        'version': v,
        'updated_by': null,
        'display': 'gsl',
        'lists': {
          'gsl': {'speaker_seconds': 90, 'entries': gsl},
          'mod': {'speaker_seconds': 60, 'entries': []},
        },
        'timer': timer,
      });
  @override
  Future<FloorOpResult> send(Map<String, dynamic> op) async {
    ops.add(op['op'] as String);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final now = DateTime.now().millisecondsSinceEpoch;
    if (op['op'] == 'start_speaker' && gsl.isNotEmpty) {
      timer = {
        ...timer,
        'kind': 'speaker',
        'list': 'gsl',
        'speaker_id': gsl.first['id'],
        'duration': 90,
        'running': true,
        'ends_at': now + 90000,
        'remaining_ms': 90000,
      };
    }
    if (op['op'] == 'pause') {
      timer = {...timer, 'running': false, 'ends_at': null, 'remaining_ms': 60000};
    }
    if (op['op'] == 'add') {
      gsl.add({'id': 'e${n++}', 'name': op['name'], 'code': op['code']});
    }
    if (op['op'] == 'remove') gsl.removeWhere((e) => e['id'] == op['entry_id']);
    if (op['op'] == 'next') {
      sent.add(op);
      final before = gsl.length;
      gsl.removeWhere((e) => e['id'] == op['entry_id']);
      if (gsl.length == before) {
        return const FloorOpResult(409, 'That speaker has already finished');
      }
    }
    v++;
    state = make();
    notifyListeners();
    return const FloorOpResult(200);
  }
}

Widget app(FloorClient c, {List<Portfolio>? matrix}) => MaterialApp(
      theme: getDarkTheme(),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              bottom: const TabBar(tabs: [Tab(text: 'GSL'), Tab(text: 'T')])),
          body: TabBarView(children: [
            SpeakerListTab(client: c, listName: 'gsl', matrix: matrix),
            SessionTimerTab(client: c),
          ]),
        ),
      ),
    );

class FakeApi extends ApiClient {
  FakeApi() : super(baseUrl: 'http://127.0.0.1:1');
  @override
  Future<http.Response> get(String path) async {
    if (path.endsWith('/portfolios')) {
      return http.Response('[]', 200); // free entry in the page tests
    }
    if (path == '/public/committees') {
      return http.Response(
          jsonEncode([
            {'id': 1, 'name': 'UNSC', 'event_id': 1, 'status': 'in_session'},
            {'id': 2, 'name': 'IPC', 'event_id': 1, 'status': 'in_session'}
          ]),
          200);
    }
    return http.Response(
        jsonEncode({
          'type': 'state',
          'server_now': DateTime.now().millisecondsSinceEpoch,
          'state': {
            'version': 1,
            'updated_by': null,
            'display': 'gsl',
            'lists': {
              'gsl': {'speaker_seconds': 90, 'entries': []},
              'mod': {'speaker_seconds': 60, 'entries': []}
            },
            'timer': {
              'kind': 'idle',
              'list': null,
              'speaker_id': null,
              'duration': 0,
              'running': false,
              'ends_at': null,
              'remaining_ms': 0
            }
          },
        }),
        200);
  }
}

Widget pageApp() => Provider<ApiClient>.value(
      value: FakeApi(),
      child: MaterialApp(
          theme: getDarkTheme(),
          home: Builder(
              builder: (context) => Scaffold(
                    body: Center(
                        child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EBToolsPage())),
                      child: const Text('open'),
                    )),
                  ))),
    );

void main() {
  testWidgets('pick a suggestion', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.enterText(find.byType(TextField), 'ind');
    await t.pumpAndSettle();
    await t.tap(find.text('India').last);
    await t.pumpAndSettle();
    expect(c.gsl.length, 1);
  });

  testWidgets('submit with enter', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.enterText(find.byType(TextField), 'fra');
    await t.pumpAndSettle();
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    expect(c.gsl.length, 1);
  });

  testWidgets('add as a person', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.enterText(find.byType(TextField), 'Mr Shah');
    await t.pumpAndSettle();
    await t.tap(find.textContaining('as a person'));
    await t.pumpAndSettle();
    expect(c.gsl.single['code'], isNull);
  });

  testWidgets('add then remove then switch tabs', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    for (final q in ['india', 'jap']) {
      await t.enterText(find.byType(TextField), q);
      await t.pumpAndSettle();
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
    }
    await t.tap(find.byTooltip('Remove').first);
    await t.pumpAndSettle();
    await t.tap(find.text('T'));
    await t.pumpAndSettle();
    await t.tap(find.text('GSL'));
    await t.pumpAndSettle();
  });

  testWidgets('connection drops while typing', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.enterText(find.byType(TextField), 'ind');
    await t.pumpAndSettle();
    c.connected = false;
    c.notifyListeners();
    await t.pumpAndSettle();
    c.connected = true;
    c.notifyListeners();
    await t.pumpAndSettle();
  });

  testWidgets('Next names the speaker, so a speaker whose time ran out meanwhile '
      'does not cost the next delegate their turn', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    for (final q in ['india', 'brazil']) {
      await t.enterText(find.byType(TextField), q);
      await t.pumpAndSettle();
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
    }
    expect(c.gsl.map((e) => e['name']), ['India', 'Brazil']);

    await t.tap(find.byTooltip('Next speaker'));
    await t.pumpAndSettle();
    expect(find.text("End India's speech?"), findsOneWidget);

    // While the dialog is open, India's time runs out and the server removes them.
    c.gsl.removeAt(0);
    c.v++;
    c.state = c.make();
    c.notifyListeners();
    await t.pump();

    await t.tap(find.text('Next speaker').last);
    await t.pumpAndSettle();
    expect(c.sent.single['entry_id'], 'e0');
    expect(c.gsl.map((e) => e['name']), ['Brazil']);
    expect(find.text('India has already finished.'), findsOneWidget);
  });

  Future<void> type(WidgetTester t, String q) async {
    await t.enterText(find.byType(TextField), q);
    await t.pumpAndSettle();
  }

  Future<void> enter(WidgetTester t) async {
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
  }

  testWidgets('Enter with several candidates waits for a tap', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await type(t, 'ind'); // India and Indonesia
    await enter(t);
    expect(c.gsl, isEmpty);
    expect(find.text('Indonesia'), findsOneWidget); // suggestions still open
    await t.tap(find.text('India').last);
    await t.pumpAndSettle();
    expect(c.gsl.map((e) => e['name']), ['India']);
  });

  testWidgets('Enter never falls through to a different country', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await type(t, 'niger');
    await enter(t);
    expect(c.gsl.map((e) => e['name']), ['Niger']);
    await type(t, 'niger'); // Niger is on the list now
    await enter(t);
    expect(c.gsl.map((e) => e['name']), ['Niger'], reason: 'not Nigeria');
    expect(find.text('Niger is already on the list.'), findsOneWidget);
  });

  testWidgets('Enter: a single strong match adds; a loose one does not', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await type(t, 'usa'); // an exact alias
    await enter(t);
    await type(t, 'fra'); // only France starts with it
    await enter(t);
    await type(t, 'ali'); // only inside names (Australia, Mali…): no guess
    await enter(t);
    expect(c.gsl.map((e) => e['name']), ['United States', 'France']);
  });

  testWidgets('a person named like a country can still be added', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await type(t, 'Jordan');
    await t.tap(find.text('Add "Jordan" as a person'));
    await t.pumpAndSettle();
    expect(c.gsl.single['name'], 'Jordan');
    expect(c.gsl.single['code'], isNull);
  });

  testWidgets('switching tabs drops the search focus', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    FocusNode node() => t
        .widget<TextField>(find.byType(TextField, skipOffstage: false))
        .focusNode!;
    expect(node().hasFocus, isTrue);
    await t.tap(find.text('T'));
    await t.pumpAndSettle();
    expect(node().hasFocus, isFalse);
  });

  testWidgets('a double tap on remove removes one speaker', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    for (final q in ['india', 'brazil', 'chile']) {
      await type(t, q);
      await enter(t);
    }
    await t.tap(find.byTooltip('Remove').first);
    await t.pump(const Duration(milliseconds: 20));
    await t.tap(find.byTooltip('Remove').first, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 100)); // Brazil now under the finger
    await t.tap(find.byTooltip('Remove').first, warnIfMissed: false);
    await t.pumpAndSettle();
    expect(c.gsl.map((e) => e['name']), ['Brazil', 'Chile']);
    await t.pump(const Duration(seconds: 5)); // let the "Removed" message expire
  });

  testWidgets('a double tap on Pause sends one pause', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await type(t, 'india');
    await enter(t);
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    await t.tap(find.text('Start'));
    await t.pump(const Duration(milliseconds: 200));
    await t.tap(find.text('Pause'));
    await t.pump(const Duration(milliseconds: 20));
    await t.tap(find.text('Pause'), warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 200));
    expect(c.ops.where((o) => o == 'pause').length, 1);
    expect(c.ops.where((o) => o == 'start_speaker').length, 1);
    c.dispose();
  });

  group('phones', () {
    Future<void> phone(WidgetTester t, Size size, {double text = 1}) async {
      t.view.physicalSize = size * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      final c = FakeFloor();
      for (final name in ['India', 'Brazil', 'Chile', 'Denmark', 'Egypt']) {
        c.gsl.add({'id': name, 'name': name, 'code': null});
      }
      c.state = c.make();
      await t.pumpWidget(MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(text)),
        child: app(c),
      ));
      await t.pumpAndSettle();
    }

    double listHeight(WidgetTester t) =>
        t.getSize(find.byType(ReorderableListView)).height;

    testWidgets('iPhone SE: the full panel, rows visible', (t) async {
      await phone(t, const Size(375, 667));
      expect(find.byTooltip('Reset the timer'), findsOneWidget);
      expect(listHeight(t), greaterThan(120));
      expect(t.takeException(), isNull);
    });

    testWidgets('iPhone SE while typing: the one-row panel', (t) async {
      await phone(t, const Size(375, 667));
      await t.tap(find.byType(TextField));
      await t.pumpAndSettle();
      expect(find.byTooltip('Reset the timer'), findsNothing);
      expect(find.byTooltip('Next speaker'), findsOneWidget);
      expect(listHeight(t), greaterThan(250));
      expect(t.takeException(), isNull);
    });

    testWidgets('iPhone SE with 2x text: nothing overflows', (t) async {
      await phone(t, const Size(375, 667), text: 2);
      expect(t.takeException(), isNull);
      await t.tap(find.byType(TextField));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });

    testWidgets('landscape: the one-row panel', (t) async {
      await phone(t, const Size(667, 375));
      expect(find.byTooltip('Reset the timer'), findsNothing);
      expect(t.takeException(), isNull);
    });
  });

  group('a committee with a matrix', () {
    final unsc = matrixPortfolios([
      {'name': 'China', 'code': 'cn', 'tag': null, 'detail': null},
      {'name': 'United States of America', 'code': 'us', 'tag': null, 'detail': null},
      {'name': "Côte d'Ivoire", 'code': 'ci', 'tag': null, 'detail': null},
    ]);
    final psc = matrixPortfolios([
      for (final (name, tag, party) in [
        ('Sanjay Raut', 'SS(UBT)', 'Shiv Sena (Uddhav Balasaheb Thackeray)'),
        ('Sanjay Singh', 'AAP', 'Aam Aadmi Party'),
        ('Sanjay Yadav', 'RJD', 'Rashtriya Janata Dal'),
        ('Mahua Moitra', 'AITC', 'All India Trinamool Congress'),
      ])
        {'name': name, 'code': null, 'tag': tag, 'detail': party},
    ]);

    testWidgets('tapping the empty box drops down the whole matrix', (t) async {
      final c = FakeFloor();
      await t.pumpWidget(app(c, matrix: unsc));
      await t.tap(find.byType(TextField));
      await t.pumpAndSettle();
      for (final name in ['China', 'United States of America', "Côte d'Ivoire"]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('India'), findsNothing); // not in this matrix
      await t.tap(find.text('China'));
      await t.pumpAndSettle();
      expect(c.gsl.single['name'], 'China');
    });

    testWidgets('a nickname finds the matrix name', (t) async {
      final c = FakeFloor();
      await t.pumpWidget(app(c, matrix: unsc));
      await type(t, 'usa');
      await enter(t);
      await type(t, 'ivory');
      await enter(t);
      expect(c.gsl.map((e) => e['name']), ['United States of America', "Côte d'Ivoire"]);
      expect(c.gsl.map((e) => e['code']), ['us', 'ci']);
    });

    testWidgets('off the matrix: only a deliberate "Add other"', (t) async {
      final c = FakeFloor();
      await t.pumpWidget(app(c, matrix: unsc));
      await type(t, 'Brazil');
      // No country outside the matrix among the suggestions.
      expect(find.widgetWithText(ListTile, 'Brazil'), findsNothing);
      await enter(t);
      expect(c.gsl, isEmpty, reason: 'Enter never adds off the matrix');
      await t.tap(find.text('Add other: "Brazil"'));
      await t.pumpAndSettle();
      expect(c.gsl.single['name'], 'Brazil');
      expect(c.gsl.single['code'], isNull);
    });

    testWidgets('PSC: members by name or party, with their party', (t) async {
      final c = FakeFloor();
      await t.pumpWidget(app(c, matrix: psc));
      await type(t, 'sanjay');
      for (final name in ['Sanjay Raut', 'Sanjay Singh', 'Sanjay Yadav']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Aam Aadmi Party'), findsOneWidget); // the party under the name
      expect(find.text('AAP'), findsOneWidget); // the badge
      await enter(t);
      expect(c.gsl, isEmpty, reason: 'three Sanjays: pick one');
      await type(t, 'aitc');
      await enter(t);
      expect(c.gsl.single['name'], 'Mahua Moitra');
    });
  });

  testWidgets('the speaking time dialog closes cleanly (Set and Cancel)',
      (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    for (final button in ['Set', 'Cancel']) {
      await t.tap(find.textContaining('each'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, '30');
      await t.tap(find.text(button));
      for (var i = 0; i < 20; i++) {
        await t.pump(const Duration(
            milliseconds: 16)); // every frame of the closing animation
      }
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('the unmod custom dialog closes cleanly', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.tap(find.text('T'));
    await t.pumpAndSettle();
    await t.tap(find.text('Custom'));
    await t.pumpAndSettle();
    await t.tap(find.text('Set'));
    for (var i = 0; i < 20; i++) {
      await t.pump(const Duration(milliseconds: 16));
    }
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('too short a time is refused in the dialog', (t) async {
    final c = FakeFloor();
    await t.pumpWidget(app(c));
    await t.tap(find.textContaining('each'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(1), '0');
    await t.enterText(find.byType(TextField).at(2), '3');
    await t.tap(find.text('Set'));
    await t.pumpAndSettle();
    expect(find.text('Enter at least 5 seconds.'), findsOneWidget);
  });

  testWidgets('first entry, pick, change, leave', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.runAsync(() async {
      await t.pumpWidget(pageApp());
      await t.tap(find.text('open'));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      await t.tap(find.text('UNSC'));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(find.text('Mod'), findsWidgets);
      await t.tap(find.byTooltip('Menu'));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      await t.tap(find.text('Change committee'));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      await t.tap(find.text('IPC'));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(find.text('IPC'), findsWidgets);
      await t.tap(find.text('Timer'));
      await t.pump(const Duration(milliseconds: 500));
      await t.pageBack();
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    });
  });
}
