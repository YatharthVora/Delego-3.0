import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:delego/models/app_update.dart';

/// Opens the store at [url]; true if something opened it.
typedef StoreOpener = Future<bool> Function(Uri url);

/// Asks the user to update. "Not now", a tap outside and the back button all
/// close it; "Update" opens the store and closes it. If the store can't be
/// opened, the dialog stays and shows the link to copy instead (a snackbar
/// would sit behind the dialog's barrier).
Future<void> showUpdatePrompt(
  BuildContext context,
  UpdatePrompt prompt, {
  StoreOpener? openStore,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _UpdateDialog(prompt: prompt, openStore: openStore ?? _launchStore),
  );
}

// The App Store / Play Store app, not an in-app browser.
Future<bool> _launchStore(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.prompt, required this.openStore});

  final UpdatePrompt prompt;
  final StoreOpener openStore;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _failed = false;

  Future<void> _open() async {
    var ok = false;
    try {
      ok = await widget.openStore(Uri.parse(widget.prompt.storeUrl));
    } catch (_) {}
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Update available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.prompt.message),
          if (_failed) ...[
            const SizedBox(height: 16),
            Text("Couldn't open the store. Copy this link instead:",
                style: TextStyle(color: scheme.error)),
            const SizedBox(height: 4),
            SelectableText(widget.prompt.storeUrl),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: _open,
          child: const Text(
            'Update',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
