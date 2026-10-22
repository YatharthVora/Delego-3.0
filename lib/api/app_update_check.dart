import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delego/constants/backend.dart';
import 'package:delego/models/app_update.dart';

/// Asks the server whether this version of the app should be updated
/// (`GET /public/app_config`, public, so it works before login).
///
/// Every failure (offline, a sleeping server, a bad response) means "no prompt":
/// this check must never slow down or block opening the app.
class AppUpdateCheck {
  AppUpdateCheck({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? Backend.baseUrl;

  final http.Client _client;
  final String _base;

  /// Short, so a sleeping Render instance (~50s to wake) is skipped, not waited on.
  static const _timeout = Duration(seconds: 4);

  /// After a successful check, foreground resumes don't ask again for this long.
  static const _recheckAfter = Duration(hours: 1);

  /// The last `latest` the user was shown a prompt for.
  static const _seenKey = 'update_prompt_seen';

  DateTime? _lastChecked;

  /// The prompt to show now, or null. Each `latest` version is offered once
  /// (see [markSeen]).
  Future<UpdatePrompt?> check() async {
    final platform = _platform();
    if (platform == null) return null;
    final last = _lastChecked;
    if (last != null && DateTime.now().difference(last) < _recheckAfter) {
      return null;
    }

    try {
      final res = await _client
          .get(Uri.parse('$_base/public/app_config'))
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic>) return null;
      _lastChecked = DateTime.now();

      final info = await PackageInfo.fromPlatform();
      final prompt = decideUpdate(
          config: body, platform: platform, installed: info.version);
      if (prompt == null) return null;

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_seenKey) == prompt.latest) return null;
      return prompt;
    } catch (_) {
      return null;
    }
  }

  /// Don't offer this version again, however the prompt was closed (a newer
  /// `latest` will be offered).
  Future<void> markSeen(UpdatePrompt prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenKey, prompt.latest);
  }

  static String? _platform() {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => null,
    };
  }
}
