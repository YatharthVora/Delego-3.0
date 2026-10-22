import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delego/api/app_update_check.dart';
import 'package:delego/models/app_update.dart';
import 'package:delego/widgets/update_prompt.dart';

Map<String, dynamic> config({
  String latest = '3.1.0',
  String storeUrl = 'https://apps.apple.com/app/id1',
  String? message = 'Please update',
}) =>
    {
      if (message != null) 'message': message,
      'ios': {'latest': latest, 'store_url': storeUrl},
    };

UpdatePrompt? decide(Map<String, dynamic> config, String installed,
        {String platform = 'ios'}) =>
    decideUpdate(config: config, platform: platform, installed: installed);

const prompt = UpdatePrompt(
  latest: '3.1.0',
  message: 'Please update',
  storeUrl: 'https://apps.apple.com/app/id1',
);

void main() {
  group('parseVersion', () {
    test('reads x.y.z and ignores the build number', () {
      expect(parseVersion('3.0.3'), [3, 0, 3]);
      expect(parseVersion('3.0.3+6775'), [3, 0, 3]);
    });

    test('rejects anything else', () {
      for (final bad in [null, '', '3.0', '3.0.3.1', 'v3.0.3', '3.x.0', '3.0.-1']) {
        expect(parseVersion(bad), isNull, reason: '$bad');
      }
    });
  });

  test('versions compare as numbers, not text', () {
    expect(compareVersions([3, 0, 10], [3, 0, 9]), greaterThan(0));
    expect(compareVersions([3, 0, 9], [3, 1, 0]), lessThan(0));
    expect(compareVersions([3, 0, 3], [3, 0, 3]), 0);
  });

  group('decideUpdate', () {
    test('no prompt at or above latest', () {
      expect(decide(config(), '3.1.0'), isNull);
      expect(decide(config(), '3.2.0'), isNull);
    });

    test('a prompt below latest', () {
      final prompt = decide(config(), '3.0.3')!;
      expect(prompt.latest, '3.1.0');
      expect(prompt.message, 'Please update');
      expect(prompt.storeUrl, 'https://apps.apple.com/app/id1');
    });

    test('the first release ships silent: latest = installed', () {
      expect(decide(config(latest: '3.0.3'), '3.0.3+6775'), isNull);
    });

    test('an old min key is ignored: there is no forced update', () {
      final old = config(latest: '3.0.3');
      (old['ios'] as Map)['min'] = '9.9.9';
      expect(decide(old, '3.0.3'), isNull);
    });

    test('no prompt without an https store link', () {
      expect(decide(config(storeUrl: ''), '3.0.3'), isNull);
      expect(decide(config(storeUrl: 'http://x.com'), '3.0.3'), isNull);
    });

    test('no prompt for a platform the server left out', () {
      expect(decide(config(), '3.0.3', platform: 'android'), isNull);
      expect(decide({}, '3.0.3'), isNull);
    });

    test('no prompt when a version is malformed', () {
      expect(decide(config(latest: '3.1'), '3.0.3'), isNull);
      expect(decide(config(), 'unknown'), isNull);
      expect(
          decide({
            'ios': {'latest': 3, 'store_url': 'https://x.com'}
          }, '3.0.3'),
          isNull);
    });

    test('a missing message gets a default', () {
      expect(decide(config(message: null), '3.0.3')!.message,
          'A new version of Delego is available.');
    });
  });

  group('AppUpdateCheck', () {
    late Map<String, dynamic> served;
    late int requests;
    late bool failing;

    AppUpdateCheck checker() => AppUpdateCheck(
          baseUrl: 'https://server',
          client: MockClient((req) async {
            requests++;
            expect(req.url.toString(), 'https://server/public/app_config');
            if (failing) return http.Response('oops', 500);
            return http.Response(jsonEncode(served), 200);
          }),
        );

    setUp(() {
      served = config();
      requests = 0;
      failing = false;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'Delego',
        packageName: 'delego',
        version: '3.0.3',
        buildNumber: '6775',
        buildSignature: '',
      );
    });

    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('each version is offered once', () async {
      final first = await checker().check();
      expect(first?.latest, '3.1.0');
      await checker().markSeen(first!);

      expect(await checker().check(), isNull);

      served = config(latest: '3.1.1');
      expect((await checker().check())?.latest, '3.1.1');
    });

    test('an answered check is not repeated within the hour', () async {
      final updates = checker();
      expect(await updates.check(), isNotNull);
      expect(await updates.check(), isNull);
      expect(requests, 1);
    });

    test('a failed check means no prompt, and the next resume asks again',
        () async {
      final updates = checker();
      failing = true;
      expect(await updates.check(), isNull);
      failing = false;
      expect(await updates.check(), isNotNull);
      expect(requests, 2);
    });

    test('only iOS and Android ask', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(await checker().check(), isNull);
      expect(requests, 0);
    });
  });

  group('the dialog', () {
    Future<void> open(WidgetTester tester, StoreOpener opener) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showUpdatePrompt(context, prompt, openStore: opener),
            child: const Text('show'),
          ),
        ),
      ));
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();
      expect(find.text('Update available'), findsOneWidget);
    }

    testWidgets('"Not now" closes it', (tester) async {
      await open(tester, (_) async => true);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Update available'), findsNothing);
    });

    testWidgets('a tap outside closes it', (tester) async {
      await open(tester, (_) async => true);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Update available'), findsNothing);
    });

    testWidgets('"Update" opens the store link and closes it', (tester) async {
      Uri? opened;
      await open(tester, (url) async {
        opened = url;
        return true;
      });
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();
      expect(opened, Uri.parse(prompt.storeUrl));
      expect(find.text('Update available'), findsNothing);
    });

    for (final (name, StoreOpener opener) in [
      ('says no', (_) async => false),
      ('throws', (_) async => throw Exception('no store')),
    ]) {
      testWidgets('a store that $name: the link shows in the dialog',
          (tester) async {
        await open(tester, opener);
        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle();
        expect(find.text('Update available'), findsOneWidget);
        expect(find.textContaining("Couldn't open the store"), findsOneWidget);
        expect(find.text(prompt.storeUrl), findsOneWidget);
      });
    }
  });
}
