import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delego/api/api_client.dart';
import 'package:delego/models/break_coordination.dart' show clockTime;
import 'package:delego/models/food_summary.dart';
import 'package:delego/widgets/neon.dart';

/// Admins only: today's plates across all meals (total, veg, jain) and a card for each
/// person who scanned, which opens the delegates they scanned.
///
/// The numbers are fetched when the page opens and when the admin refreshes (pull down
/// or the refresh button), never in the background, so an open page costs the server
/// nothing. "Updated" says how fresh they are.
class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late final ApiClient _api;
  FoodToday? _data;
  DateTime? _updatedAt;
  String? _error; // only shown while there is nothing on screen
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    String? problem;
    try {
      final res = await _api.get('/food/today');
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = FoodToday(jsonDecode(res.body) as Map<String, dynamic>);
        setState(() {
          _data = data;
          _updatedAt = DateTime.now();
          _error = null;
        });
      } else {
        problem = _detail(res.body) ?? 'Could not load (${res.statusCode}).';
      }
    } on Forbidden {
      problem = 'Only admins can see the food numbers.';
    } on SessionExpired {
      // ApiClient already sent the user back to login.
    } catch (_) {
      problem = 'Could not reach the server.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (problem == null || !mounted) return;
    if (_data == null) {
      setState(() => _error = problem);
    } else {
      // Keep the last numbers on screen; "Updated" shows they are older.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Not refreshed. $problem')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: data == null
          ? _empty()
          : RefreshIndicator(onRefresh: _load, child: _content(data)),
    );
  }

  Widget _empty() {
    if (_error == null) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _load,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(FoodToday data) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(color: scheme.onSurface.withValues(alpha: 0.6));
    return ListView(
      // Pull to refresh needs the list to scroll even when it is short.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(dateHeading(data.date),
            style: Theme.of(context).textTheme.headlineSmall),
        if (_updatedAt != null) ...[
          const SizedBox(height: 4),
          Text('Updated ${clockTime(_updatedAt!)} · all meals today',
              style: muted),
        ],
        const SizedBox(height: 16),
        Row(children: [
          _stat('Total', data.total, kSwatches[1]),
          const SizedBox(width: 10),
          _stat('Veg', data.veg, kSwatches[3]),
          const SizedBox(width: 10),
          _stat('Jain', data.jain, kSwatches[0]),
        ]),
        const SizedBox(height: 24),
        Text('Scanned by', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (data.scanners.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No plates scanned yet today.',
                textAlign: TextAlign.center, style: muted),
          ),
        for (final s in data.scanners)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: scheme.surfaceContainerHigh,
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${s.count}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScannerPlatesPage(scanner: s),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stat(String label, int value, NeonSwatch swatch) {
    final fg = swatch.nameColor;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: swatch.colors.first,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: Neon.label(fg, size: 11, spacing: 1.5)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('$value',
                  style: TextStyle(
                      color: fg, fontSize: 28, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The delegates one person scanned today, newest first. Loaded when it opens and on
/// refresh, like the Food page.
class ScannerPlatesPage extends StatefulWidget {
  const ScannerPlatesPage({super.key, required this.scanner});

  final ScannerCount scanner;

  @override
  State<ScannerPlatesPage> createState() => _ScannerPlatesPageState();
}

class _ScannerPlatesPageState extends State<ScannerPlatesPage> {
  late final ApiClient _api;
  List<ScannedPlate>? _plates;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    String? problem;
    try {
      final scanner = Uri.encodeQueryComponent(widget.scanner.email);
      final res = await _api.get('/food/today/scans?scanner=$scanner');
      if (!mounted) return;
      if (res.statusCode == 200) {
        final plates = [
          for (final p in jsonDecode(res.body) as List)
            ScannedPlate(p as Map<String, dynamic>),
        ];
        setState(() {
          _plates = plates;
          _error = null;
        });
      } else {
        problem = _detail(res.body) ?? 'Could not load (${res.statusCode}).';
      }
    } on Forbidden {
      problem = 'Only admins can see this.';
    } on SessionExpired {
      // handled by ApiClient
    } catch (_) {
      problem = 'Could not reach the server.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (problem == null || !mounted) return;
    if (_plates == null) {
      setState(() => _error = problem);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Not refreshed. $problem')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final plates = _plates;
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(color: scheme.onSurface.withValues(alpha: 0.6));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scanner.name),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: plates == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _loading ? null : _load,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    '${plates.length} ${plates.length == 1 ? 'plate' : 'plates'} today',
                    style: muted,
                  ),
                  const SizedBox(height: 8),
                  if (plates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('No plates scanned yet today.',
                          textAlign: TextAlign.center, style: muted),
                    ),
                  for (final p in plates)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle:
                          Text('${mealLabel(p.meal)} · ${dietLabel(p.diet)}'),
                      trailing: Text(clockTime(p.at), style: muted),
                    ),
                ],
              ),
            ),
    );
  }
}

/// The server's `detail` message, when it sent one.
String? _detail(String body) {
  try {
    final detail = (jsonDecode(body) as Map)['detail'];
    return detail is String ? detail : null;
  } catch (_) {
    return null;
  }
}
