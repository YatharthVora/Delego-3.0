import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:delego/api/api_client.dart';

/// A list of the conference's committees to choose one from. EB Tools reads the public
/// list (an EB has no chat access); Break Coordination reads `/committees`, which only
/// holds the committees the caller may coordinate.
class CommitteePicker extends StatefulWidget {
  const CommitteePicker({
    super.key,
    required this.api,
    required this.onPicked,
    this.selectedId,
    this.endpoint = '/public/committees',
    this.question = 'Which committee are you chairing?',
    this.icon = Icons.gavel,
    this.ensureDisec = false,
  });

  final ApiClient api;
  final int? selectedId;
  final String endpoint;
  final String question;
  final IconData icon;

  /// EB Tools only: list DISEC even when the server has no row for it yet.
  final bool ensureDisec;
  final void Function(int id, String name) onPicked;

  @override
  State<CommitteePicker> createState() => _CommitteePickerState();
}

class _CommitteePickerState extends State<CommitteePicker> {
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
      final res = await widget.api.get(widget.endpoint);
      if (res.statusCode != 200) throw Exception(res.statusCode);
      final list = [
        for (final c in jsonDecode(res.body) as List)
          ((c as Map<String, dynamic>)['id'] as int, c['name'] as String),
      ];
      if (widget.ensureDisec &&
          !list.any((c) => c.$2.toUpperCase() == 'DISEC')) {
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
        Text(widget.question, style: Theme.of(context).textTheme.titleLarge),
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
              leading: Icon(widget.icon),
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
