import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delego/api/api_client.dart';
import 'package:delego/api/floor_client.dart';
import 'package:delego/constants/portfolios.dart';
import 'package:delego/Pages/EB_Tools/floor_widgets.dart';
import 'package:delego/Pages/EB_Tools/session_timer_tab.dart';
import 'package:delego/Pages/EB_Tools/speaker_list_tab.dart';

/// EB Tools: the chair and vice chair run their committee's floor from here (the GSL, the
/// moderated caucus list and the timers), and the room's smartboard follows it live.
///
/// The committee picked on first entry is remembered on this phone (prefs
/// `eb_committee_id`/`eb_committee_name`), so the EB goes straight to it next time.
class EBToolsPage extends StatefulWidget {
  const EBToolsPage({super.key});

  @override
  State<EBToolsPage> createState() => _EBToolsPageState();
}

class _EBToolsPageState extends State<EBToolsPage> with WidgetsBindingObserver {
  static const _prefId = 'eb_committee_id';
  static const _prefName = 'eb_committee_name';

  late final ApiClient _api;
  bool _initDone = false;
  bool _prefsLoaded = false;
  int? _committeeId;
  String? _committeeName;

  /// The committee's portfolio matrix ([] when it has none); null until loaded.
  List<Portfolio>? _matrix;
  bool _matrixFailed = false;
  FloorClient? _client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      _initDone = true;
      _api = context.read<ApiClient>();
      _loadSaved();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The socket may have died while the phone was locked; catch up at once.
    if (state == AppLifecycleState.resumed) {
      _client?.reconnect();
      final id = _committeeId;
      if (_matrixFailed && id != null) _loadMatrix(id);
    }
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_prefId);
    final name = prefs.getString(_prefName);
    if (!mounted) return;
    setState(() => _prefsLoaded = true);
    if (id != null) _open(id, name ?? 'Committee');
  }

  void _open(int id, String name) {
    _client?.dispose();
    setState(() {
      _committeeId = id;
      _committeeName = name;
      _client = FloorClient(_api, id)..start();
      _matrix = null;
      _matrixFailed = false;
    });
    _loadMatrix(id);
  }

  /// The committee's portfolio matrix, kept on the phone (prefs `eb_portfolios_<id>`) so a
  /// cold-starting server or a dead Wi-Fi still has it. With neither, free entry for now.
  Future<void> _loadMatrix(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'eb_portfolios_$id';
    List<dynamic>? json;
    try {
      final res = await _api
          .get('/public/committees/$id/portfolios')
          .timeout(FloorClient.requestTimeout);
      if (res.statusCode == 200) {
        json = jsonDecode(res.body) as List<dynamic>;
        await prefs.setString(key, res.body);
      }
    } catch (_) {
      // fall back to the copy on the phone
    }
    if (json == null) {
      try {
        final cached = prefs.getString(key);
        if (cached != null) json = jsonDecode(cached) as List<dynamic>;
      } catch (_) {}
    }
    if (!mounted || id != _committeeId) return;
    final upper = (_committeeName ?? '').toUpperCase();
    final fallback = upper == 'DISEC'
        ? kDisecMatrix
        : (upper == 'CCC'
            ? kCccMatrix
            : (upper == 'PSC' ? kPscMatrix : null));
    final parsed = json == null ? null : matrixPortfolios(json);
    setState(() {
      if (fallback != null && (parsed == null || parsed.isEmpty)) {
        _matrix = fallback;
        _matrixFailed = false;
      } else {
        _matrix = parsed;
        _matrixFailed = json == null;
      }
    });
  }

  Future<void> _pick(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefId, id);
    await prefs.setString(_prefName, name);
    if (mounted) _open(id, name);
  }

  Future<void> _changeCommittee() async {
    final picked = await Navigator.push<(int, String)>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Change committee')),
          body: _CommitteePicker(
            api: _api,
            selectedId: _committeeId,
            onPicked: (id, name) => Navigator.pop(context, (id, name)),
          ),
        ),
      ),
    );
    if (picked != null && picked.$1 != _committeeId) {
      await _pick(picked.$1, picked.$2);
    }
  }

  void _showBoardLink() {
    final url = '${_api.baseUrl}/static/live_gsl.html?committee=$_committeeId';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Smartboard link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Open this on the room\'s smartboard to show $_committeeName\'s lists and timer.'),
            const SizedBox(height: 12),
            SelectableText(url,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(ctx);
              showFloorMessage(context, 'Link copied');
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _client?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    if (!_prefsLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('EB Tools')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('EB Tools')),
        body: _CommitteePicker(api: _api, onPicked: _pick),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_committeeName ?? 'EB Tools'),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Menu',
              onSelected: (v) {
                if (v == 'change') _changeCommittee();
                if (v == 'board') _showBoardLink();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'board', child: Text('Smartboard link')),
                PopupMenuItem(value: 'change', child: Text('Change committee')),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'GSL'),
              Tab(text: 'Mod'),
              Tab(text: 'Timer'),
            ],
          ),
        ),
        body: Column(
          children: [
            _StatusStrip(client: client),
            Expanded(
              child: TabBarView(
                children: [
                  SpeakerListTab(
                    client: client,
                    listName: 'gsl',
                    matrix: _matrix,
                    matrixUnavailable: _matrixFailed,
                  ),
                  SpeakerListTab(
                    client: client,
                    listName: 'mod',
                    matrix: _matrix,
                    matrixUnavailable: _matrixFailed,
                  ),
                  SessionTimerTab(client: client),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The connection state, and what the smartboard is showing (tap to switch it).
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.client});

  final FloorClient client;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Copied from the theme's label style so the segments keep the brand font.
    final segmentText = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: ListenableBuilder(
        listenable: client,
        builder: (context, _) {
          final s = client.state;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (client.closedForGood)
                _Banner(
                  color: scheme.errorContainer,
                  onColor: scheme.onErrorContainer,
                  icon: Icons.error_outline,
                  text:
                      'This committee no longer exists. Pick another from the menu.',
                )
              else if (!client.connected)
                _Banner(
                  color: scheme.surfaceContainerHighest,
                  onColor: scheme.onSurface,
                  icon: Icons.cloud_off,
                  text:
                      'Reconnecting… Editing is paused until the live link is back.',
                  action: TextButton(
                      onPressed: client.reconnect, child: const Text('Retry')),
                ),
              if (s != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                  child: Row(
                    children: [
                      Tooltip(
                        message: 'What the smartboard shows',
                        child: Icon(Icons.tv,
                            size: 24, color: scheme.onSurfaceVariant),
                      ),
                      // The label only where there is room (narrow phones, large text).
                      if (MediaQuery.sizeOf(context).width >= 400) ...[
                        const SizedBox(width: 8),
                        Text('On screen',
                            style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(width: 12),
                      Expanded(
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          // 48 high: 1.5x the compact 32. Standard density so desktop's
                          // compact default doesn't shrink it again.
                          style: ButtonStyle(
                            visualDensity: VisualDensity.standard,
                            minimumSize: const WidgetStatePropertyAll(
                                Size.fromHeight(48)),
                            textStyle: WidgetStatePropertyAll(segmentText),
                          ),
                          segments: [
                            for (final e in kFloorViewLabels.entries)
                              ButtonSegment(
                                value: e.key,
                                // Shrinks rather than clips on a narrow phone with large
                                // text. One line: the capsule takes its height from the
                                // label's, and a wrapping label would make it taller.
                                label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(e.value,
                                        maxLines: 1, softWrap: false)),
                              ),
                          ],
                          selected: {s.display},
                          onSelectionChanged: client.connected
                              ? (v) => sendOp(context, client,
                                  {'op': 'set_display', 'view': v.first})
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.onColor,
    required this.icon,
    required this.text,
    this.action,
  });

  final Color color;
  final Color onColor;
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: onColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: onColor))),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// The conference's committees (public list, so an EB without chat access sees them too).
class _CommitteePicker extends StatefulWidget {
  const _CommitteePicker(
      {required this.api, required this.onPicked, this.selectedId});

  final ApiClient api;
  final int? selectedId;
  final void Function(int id, String name) onPicked;

  @override
  State<_CommitteePicker> createState() => _CommitteePickerState();
}

class _CommitteePickerState extends State<_CommitteePicker> {
  List<(int, String)>? _committees;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final res = await widget.api.get('/public/committees');
      if (res.statusCode != 200) throw Exception(res.statusCode);
      final list = [
        for (final c in jsonDecode(res.body) as List)
          ((c as Map<String, dynamic>)['id'] as int, c['name'] as String),
      ];
      if (!list.any((c) => c.$2.toUpperCase() == 'DISEC')) {
        final nextId = list.isEmpty
            ? 9
            : (list.map((c) => c.$1).reduce((a, b) => a > b ? a : b) + 1);
        list.add((nextId, 'DISEC'));
        list.sort((a, b) => a.$2.compareTo(b.$2));
      }
      if (mounted) setState(() => _committees = list);
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = 'Could not load the committees. Check your connection.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final committees = _committees;
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      );
    }
    if (committees == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Which committee are you chairing?',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final (id, name) in committees)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: id == widget.selectedId
                  ? scheme.secondaryContainer
                  : scheme.surfaceContainerHigh,
              leading: const Icon(Icons.gavel),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: id == widget.selectedId
                  ? const Icon(Icons.check)
                  : const Icon(Icons.chevron_right),
              onTap: () => widget.onPicked(id, name),
            ),
          ),
      ],
    );
  }
}
