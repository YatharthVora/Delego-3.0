/// The update prompt, decided from the server's `GET /public/app_config` and the
/// installed version. Pure, so it can be tested without a device.
///
/// There is only one kind of prompt, and it can always be dismissed: a forced update
/// would lock delegates out of their offline QR badge on the venue's Wi-Fi.
library;

/// What to show, once [decideUpdate] says to show something.
class UpdatePrompt {
  const UpdatePrompt({
    required this.latest,
    required this.message,
    required this.storeUrl,
  });

  /// The version being offered; the prompt is shown once per value.
  final String latest;
  final String message;
  final String storeUrl;
}

/// `x.y.z` as numbers, or null (also for a non-string). A build suffix
/// (`3.0.3+6775`) is ignored.
List<int>? parseVersion(Object? value) {
  if (value is! String) return null;
  final parts = value.split('+').first.trim().split('.');
  if (parts.length != 3) return null;
  final numbers = <int>[];
  for (final part in parts) {
    if (!RegExp(r'^\d+$').hasMatch(part)) return null;
    numbers.add(int.parse(part));
  }
  return numbers;
}

/// Negative when [a] is older than [b], zero when equal, positive when newer.
/// Compares numbers, so 3.0.10 is newer than 3.0.9.
int compareVersions(List<int> a, List<int> b) {
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] - b[i];
  }
  return 0;
}

/// The prompt for [installed] on [platform] (`ios` or `android`), or null for none.
/// Anything missing or malformed means no prompt: the check must never get in the way.
UpdatePrompt? decideUpdate({
  required Map<String, dynamic> config,
  required String platform,
  required String installed,
}) {
  final entry = config[platform];
  if (entry is! Map) return null;

  final current = parseVersion(installed);
  final latest = parseVersion(entry['latest']);
  final storeUrl = entry['store_url'];
  if (current == null || latest == null) return null;
  // Nowhere to send them, so don't ask.
  if (storeUrl is! String || !storeUrl.startsWith('https://')) return null;
  if (compareVersions(current, latest) >= 0) return null;

  final message = config['message'];
  return UpdatePrompt(
    latest: entry['latest'] as String,
    message: message is String && message.trim().isNotEmpty
        ? message
        : 'A new version of Delego is available.',
    storeUrl: storeUrl,
  );
}
