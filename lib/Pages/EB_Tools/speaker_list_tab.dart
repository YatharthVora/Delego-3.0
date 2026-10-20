import 'package:flutter/material.dart';

import 'package:delego/api/floor_client.dart';
import 'package:delego/constants/portfolios.dart';
import 'package:delego/models/floor_state.dart';
import 'package:delego/models/portfolio_search.dart';
import 'package:delego/Pages/EB_Tools/floor_widgets.dart';
import 'package:delego/widgets/portfolio_flag.dart';

/// One speakers' list (the GSL or the moderated caucus list): search to add with flags,
/// drag to reorder, and the speaker timer pinned at the bottom. Everything is the shared
/// floor, so the other EB's phone and the smartboard change with it.
class SpeakerListTab extends StatefulWidget {
  const SpeakerListTab({
    super.key,
    required this.client,
    required this.listName,
    this.matrix,
    this.matrixUnavailable = false,
  });

  final FloorClient client;

  /// 'gsl' or 'mod'.
  final String listName;

  /// The committee's portfolio matrix: when it has one, only these are offered (plus a
  /// free "Add other"). Null or empty: free entry (every country, or a person).
  final List<Portfolio>? matrix;

  /// The matrix couldn't be loaded (no network and nothing cached): free entry for now.
  final bool matrixUnavailable;

  @override
  State<SpeakerListTab> createState() => _SpeakerListTabState();
}

/// A search suggestion: a portfolio, or what was typed added as a person.
class _Option {
  const _Option.portfolio(PortfolioMatch this.match) : person = null;
  const _Option.person(String this.person) : match = null;

  final PortfolioMatch? match;
  final String? person;

  String get name => match?.portfolio.name ?? person!;
  String? get code => match?.portfolio.code;
  String? get tag => match?.portfolio.tag;
  bool get onList => match?.onList ?? false;
}

class _SpeakerListTabState extends State<SpeakerListTab>
    with AutomaticKeepAliveClientMixin {
  final _search = TextEditingController();
  final _focus = FocusNode();
  TabController? _tabs;

  // Reorders show at once; the server's next state replaces this.
  List<FloorEntry>? _localOrder;
  int? _localOrderVersion;

  /// Controls whose op is in flight, so a double tap can't send it twice (two Nexts, a
  /// Pause that turns into a Resume, a second remove landing on the row that moved up).
  final Set<String> _busy = {};

  FloorClient get _client => widget.client;
  String get _list => widget.listName;

  bool get _hasMatrix => widget.matrix?.isNotEmpty ?? false;

  /// What the search runs over: the committee's matrix, or every country.
  List<Portfolio> get _pool => _hasMatrix ? widget.matrix! : kPortfolios;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabs = DefaultTabController.maybeOf(context);
    if (tabs != _tabs) {
      _tabs?.removeListener(_onTab);
      _tabs = tabs?..addListener(_onTab);
    }
  }

  // The tabs are kept alive, so a hidden tab's search field would keep the keyboard:
  // typing on Mod caucus would add to the GSL.
  void _onTab() {
    if (_focus.hasFocus) _focus.unfocus();
  }

  // The panel shrinks while typing.
  void _onFocus() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs?.removeListener(_onTab);
    _focus.removeListener(_onFocus);
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _isBusy(String key) => _busy.contains(key);

  /// Run [action] unless [key] is already running; [hold] keeps the control off a little
  /// longer (after a remove the next row slides under the finger).
  Future<void> _guard(String key, Future<void> Function() action,
      {Duration hold = Duration.zero}) async {
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    try {
      await action();
      if (hold > Duration.zero) await Future<void>.delayed(hold);
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  // ------------------------------------------------------------------ list edits

  /// What was typed, the way the server will store it (whitespace collapsed).
  static String _typed(String text) =>
      text.trim().split(RegExp(r'\s+')).join(' ');

  static bool _nameFits(String name) => name.runes.length <= 80;

  List<_Option> _options(String text, List<FloorEntry> entries) {
    final typed = _typed(text);
    if (typed.isEmpty) {
      // The drop down: with a matrix, the whole of it that isn't on the list yet.
      if (!_hasMatrix) return const [];
      final taken = entries.map((e) => foldName(e.name)).toSet();
      return [
        for (final p in _pool)
          if (!taken.contains(foldName(p.name)))
            _Option.portfolio(PortfolioMatch(p, onList: false, rank: 9)),
      ];
    }
    final matches = searchPortfolios(typed,
        taken: entries.map((e) => e.name), portfolios: _pool);
    return [
      for (final m in matches) _Option.portfolio(m),
      // Always offered, even when a portfolio matches: a person can be called Jordan,
      // and a matrix committee may need someone off the sheet ("Add other").
      if (_nameFits(typed)) _Option.person(typed),
    ];
  }

  Future<void> _add(_Option option) async {
    if (option.onList) {
      showFloorMessage(context, '${option.name} is already on the list.');
      return;
    }
    if (!_client.connected) {
      showFloorMessage(context, 'Reconnecting… Try again in a moment.');
      return;
    }
    _search.clear();
    _focus.requestFocus(); // keep typing the next one
    await sendOp(context, _client, {
      'op': 'add',
      'list': _list,
      'name': option.name,
      'code': option.code,
    });
  }

  /// Enter adds only when it's clear what was meant: an exact name or alias ("usa"), or
  /// the one portfolio whose name (or a word of it) starts with what was typed ("fra").
  /// With several ("ind": India, Indonesia) the suggestions stay open for a tap; with
  /// none, it's a person. It never falls through to a different country ("niger" when
  /// Niger is already on the list says so instead of adding Nigeria).
  void _submit(List<FloorEntry> entries) {
    final typed = _typed(_search.text);
    if (typed.isEmpty) return;
    final matches = searchPortfolios(typed,
        taken: entries.map((e) => e.name), portfolios: _pool);
    final top = matches.firstOrNull;
    if (top != null && top.exact) {
      _add(_Option.portfolio(top));
      return;
    }
    final strong = matches.where((m) => m.strong).toList();
    if (strong.length == 1) {
      _add(_Option.portfolio(strong.single));
    } else if (matches.isEmpty && !_hasMatrix) {
      // Off a matrix, Enter never adds on its own: "Add other" is a deliberate tap.
      if (_nameFits(typed)) {
        _add(_Option.person(typed));
      } else {
        showFloorMessage(context, 'Names can be at most 80 characters.');
      }
    } else {
      _focus
          .requestFocus(); // several candidates: pick one from the suggestions
    }
  }

  Future<void> _remove(FloorEntry entry, int index) => _guard(
        'remove',
        () => _doRemove(entry, index),
        hold: const Duration(milliseconds: 400),
      );

  Future<void> _doRemove(FloorEntry entry, int index) async {
    final res = await sendOp(context, _client, {
      'op': 'remove',
      'list': _list,
      'entry_id': entry.id,
    });
    if (!res.ok || !mounted) return;
    showFloorMessage(
      context,
      'Removed ${entry.name}',
      action: SnackBarAction(
          label: 'Undo', onPressed: () => _restore(entry, index)),
    );
  }

  Future<void> _restore(FloorEntry entry, int index) async {
    final res = await _client.send({
      'op': 'add',
      'list': _list,
      'name': entry.name,
      'code': entry.code,
    });
    if (!res.ok) return;
    final added = _client.state?.list(_list).entries.lastOrNull;
    if (added == null) return;
    await _client.send({
      'op': 'move',
      'list': _list,
      'entry_id': added.id,
      'to_index': index,
    });
  }

  /// [newIndex] is where the entry ends up once taken out (onReorderItem's meaning, and
  /// the server's to_index).
  void _reorder(List<FloorEntry> entries, int oldIndex, int newIndex) {
    if (newIndex == oldIndex) return;
    final order = [...entries];
    final entry = order.removeAt(oldIndex);
    order.insert(newIndex, entry);
    setState(() {
      _localOrder = order;
      _localOrderVersion = _client.state?.version;
    });
    sendOp(context, _client, {
      'op': 'move',
      'list': _list,
      'entry_id': entry.id,
      'to_index': newIndex,
    });
  }

  Future<void> _clear() async {
    final ok = await confirm(
      context,
      title: 'Clear the ${kFloorViewLabels[_list]} list?',
      message:
          'Everyone on it is removed, for both EB phones and the smartboard.',
      action: 'Clear',
    );
    if (ok && mounted) sendOp(context, _client, {'op': 'clear', 'list': _list});
  }

  // ------------------------------------------------------------------ timer

  Future<void> _startOrPause(FloorState s) => _guard('timer', () async {
        final timing = s.timesList(_list);
        if (timing && s.timer.running) {
          await sendOp(context, _client, {'op': 'pause'});
        } else {
          // Starting a paused speaker resumes them.
          await startTimer(
              context, _client, {'op': 'start_speaker', 'list': _list});
        }
      });

  Future<void> _reset() =>
      _guard('timer', () => sendOp(context, _client, {'op': 'reset'}));

  Future<void> _next(FloorEntry speaker) =>
      _guard('next', () => _doNext(speaker));

  Future<void> _doNext(FloorEntry speaker) async {
    final ok = await confirm(
      context,
      title: 'End ${speaker.name}\'s speech?',
      message: 'They are removed from the list and the next delegate is up.',
      action: 'Next speaker',
    );
    if (!ok || !mounted) return;
    // Name the speaker: if their time ran out (or the other EB moved on) while the dialog
    // was open, the server must not take the next delegate off instead.
    final res = await _client
        .send({'op': 'next', 'list': _list, 'entry_id': speaker.id});
    if (!res.ok && mounted) {
      showFloorMessage(
        context,
        res.conflict
            ? '${speaker.name} has already finished.'
            : (res.detail ?? 'That didn\'t work. Try again.'),
      );
    }
  }

  Future<void> _editSpeakingTime(FloorState s) async {
    final seconds = await showDurationDialog(
      context,
      title: 'Speaking time',
      initialSeconds: s.list(_list).speakerSeconds,
    );
    if (seconds != null && mounted) {
      sendOp(context, _client,
          {'op': 'set_speaker_time', 'list': _list, 'seconds': seconds});
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: _client,
      builder: (context, _) {
        final s = _client.state;
        if (s == null) return const Center(child: CircularProgressIndicator());
        if (_localOrderVersion != s.version) _localOrder = null;
        final entries = _localOrder ?? s.list(_list).entries;
        final enabled = _client.connected;
        // Large accessibility text is honoured up to 1.3x here, beyond which the panel
        // and the list no longer both fit on a phone.
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Typing (keyboard up), landscape or a short screen: the one-row panel, so
              // the list stays visible.
              final compact = _focus.hasFocus || constraints.maxHeight < 440;
              return Column(
                children: [
                  _searchField(entries, enabled),
                  Expanded(child: _listView(s, entries, enabled)),
                  compact
                      ? _compactPanel(s, enabled)
                      : _controlPanel(s, enabled),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _searchField(List<FloorEntry> entries, bool enabled) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: RawAutocomplete<_Option>(
              textEditingController: _search,
              focusNode: _focus,
              displayStringForOption: (_) => '',
              optionsBuilder: (value) => _options(value.text, entries),
              onSelected: _add,
              fieldViewBuilder: (context, controller, focusNode, _) =>
                  TextField(
                controller: controller,
                focusNode: focusNode,
                // Stays usable while reconnecting (disabling it would close the keyboard
                // mid-word); adding waits for the link.
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Add a portfolio',
                  hintText: _hasMatrix
                      ? 'Tap to see the matrix, or type a few letters'
                      : 'Type a few letters: "fra", "usa", "kor"…',
                  helperText: widget.matrixUnavailable
                      ? "Couldn't load the committee's matrix: showing all countries"
                      : null,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(entries),
                onEditingComplete:
                    () {}, // keep the keyboard up for the next one
              ),
              optionsViewBuilder: (context, onSelected, options) =>
                  _optionsView(context, onSelected, options),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            enabled: enabled,
            onSelected: (v) {
              if (v == 'clear') _clear();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear list')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optionsView(
    BuildContext context,
    AutocompleteOnSelected<_Option> onSelected,
    Iterable<_Option> options,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 320,
            maxWidth: MediaQuery.sizeOf(context).width - 72,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, i) {
              final o = options.elementAt(i);
              final muted =
                  o.onList ? scheme.onSurface.withValues(alpha: 0.4) : null;
              return ListTile(
                dense: true,
                leading: Opacity(
                  opacity: o.onList ? 0.4 : 1,
                  child: PortfolioFlag(code: o.code, tag: o.tag, width: 32),
                ),
                title: Text(
                  o.match == null
                      ? (_hasMatrix
                          ? 'Add other: "${o.name}"'
                          : 'Add "${o.name}" as a person')
                      : o.name,
                  style: TextStyle(color: muted),
                ),
                subtitle: o.onList
                    ? Text('Already on the list',
                        style: TextStyle(color: muted))
                    : (o.match?.portfolio.detail != null
                        ? Text(o.match!.portfolio.detail!) // the party (PSC)
                        : null),
                onTap: () => onSelected(o),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _listView(FloorState s, List<FloorEntry> entries, bool enabled) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No speakers yet.\nAdd portfolios above, in the order they will speak.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    final current = s.currentSpeaker(_list);
    final timing = s.timesList(_list);
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: entries.length,
      buildDefaultDragHandles: enabled,
      onReorderItem: (a, b) => _reorder(entries, a, b),
      itemBuilder: (context, i) {
        final e = entries[i];
        final isCurrent = current?.id == e.id;
        return Padding(
          key: ValueKey(e.id),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Material(
            color: isCurrent
                ? scheme.secondaryContainer
                : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PortfolioFlag(code: e.code, tag: e.tag),
                ],
              ),
              title: Text(
                e.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle:
                  isCurrent ? Text(timing ? 'Speaking' : 'Up next') : null,
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.close),
                onPressed:
                    enabled && !_isBusy('remove') ? () => _remove(e, i) : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _controlPanel(FloorState s, bool enabled) {
    final colours = FloorColourway.forView(_list);
    final speaker = s.currentSpeaker(_list);
    final timing = s.timesList(_list);
    final running = timing && s.timer.running;
    const ink = Colors.white;
    final roundButton = IconButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      foregroundColor: ink,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
      disabledForegroundColor: ink.withValues(alpha: 0.35),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: colours.gradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 12 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  speaker == null
                      ? 'LIST EMPTY'
                      : (timing ? 'NOW SPEAKING' : 'UP NEXT'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colours.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: ink, visualDensity: VisualDensity.compact),
                onPressed: enabled ? () => _editSpeakingTime(s) : null,
                icon: const Icon(Icons.timer_outlined, size: 18),
                label: Text(
                    '${formatClock(s.list(_list).speakerSeconds * 1000)} each'),
              ),
            ],
          ),
          Row(
            children: [
              if (speaker != null) ...[
                PortfolioFlag(code: speaker.code, tag: speaker.tag, width: 32),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  speaker?.name ?? 'Add speakers to start',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: ink, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FloorClock(
            client: _client,
            view: _list,
            builder: (context, reading) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClockText(reading, size: 64))),
                    if (reading.mode == ClockMode.paused)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('PAUSED',
                            style: TextStyle(
                                color: ink,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClockBar(reading, color: colours.accent),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                style: roundButton,
                tooltip: 'Reset the timer',
                onPressed:
                    enabled && timing && !_isBusy('timer') ? _reset : null,
                icon: const Icon(Icons.replay),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: enabled && speaker != null && !_isBusy('timer')
                      ? () => _startOrPause(s)
                      : null,
                  icon: Icon(running ? Icons.pause : Icons.play_arrow),
                  label:
                      Text(running ? 'Pause' : (timing ? 'Resume' : 'Start')),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                style: roundButton,
                tooltip: 'Next speaker',
                onPressed: enabled && speaker != null && !_isBusy('next')
                    ? () => _next(speaker)
                    : null,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// One row: current speaker, countdown, Start/Pause and Next. Used while typing and on
  /// short screens, so the list keeps most of the height.
  Widget _compactPanel(FloorState s, bool enabled) {
    final colours = FloorColourway.forView(_list);
    final speaker = s.currentSpeaker(_list);
    final timing = s.timesList(_list);
    final running = timing && s.timer.running;
    const ink = Colors.white;
    final round = IconButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      foregroundColor: ink,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
      disabledForegroundColor: ink.withValues(alpha: 0.35),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: colours.gradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 8, 12, 8 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          if (speaker != null) ...[
            PortfolioFlag(code: speaker.code, tag: speaker.tag, width: 28),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              speaker?.name ?? 'List empty',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: ink, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          FloorClock(
            client: _client,
            view: _list,
            builder: (context, reading) => ClockText(reading, size: 28),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
            tooltip: running ? 'Pause' : (timing ? 'Resume' : 'Start'),
            onPressed: enabled && speaker != null && !_isBusy('timer')
                ? () => _startOrPause(s)
                : null,
            icon: Icon(running ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(width: 6),
          IconButton(
            style: round,
            tooltip: 'Next speaker',
            onPressed: enabled && speaker != null && !_isBusy('next')
                ? () => _next(speaker)
                : null,
            icon: const Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }
}
