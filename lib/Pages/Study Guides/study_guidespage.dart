import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:delego/Pages/Study Guides/PDF_viewers/UNODC_pdfviewer.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/widgets/neon.dart';

/// One agenda (study guide) of a committee.
///
/// Fill in EITHER [asset] (a PDF bundled in assets/pdfs/, e.g.
/// 'assets/pdfs/CCC.pdf') OR [url] (a direct link to a PDF).
/// Leave both null and the committee is hidden until the backend provides a URL.
class Agenda {
  const Agenda(this.title, {this.asset, this.url, this.page});
  final String title;
  final String? asset;
  final String? url;

  /// Optional custom viewer (used by the older per-committee viewers).
  final Widget Function()? page;

  bool get available =>
      (asset != null && asset!.isNotEmpty) ||
      (url != null && url!.isNotEmpty) ||
      page != null;
}

class _Guide {
  const _Guide(this.title, this.cover, this.agendas);
  final String title;
  final String cover;
  final List<Agenda> agendas;

  _Guide copyWith({List<Agenda>? agendas}) =>
      _Guide(title, cover, agendas ?? this.agendas);
}

const _dir = 'assets/images/committees';

// ============================================================================
// STUDY GUIDE DATA
//  * Bundled guides live in assets/pdfs/*.pdf for instant offline viewing.
//  * Late-arriving or updated guides (e.g. UNSC, IPC) can be hosted on the
//    backend in static/study_guides/<COMMITTEE>.pdf or configured in
//    data/study_guides.json via GET /study_guides without any app update.
// ============================================================================
final List<_Guide> _defaultGuides = [
  _Guide('UNSC', '$_dir/unsc.webp', const [Agenda('UNSC')]),
  _Guide('CCC', '$_dir/ccc.webp', const [
    Agenda('CCC', asset: 'assets/pdfs/CCC.pdf'),
  ]),
  _Guide('WTO', '$_dir/wto.webp', const [
    Agenda('WTO', asset: 'assets/pdfs/WTO.pdf'),
  ]),
  _Guide('PSC', '$_dir/psc.webp', const [
    Agenda('PSC', asset: 'assets/pdfs/PSC.pdf'),
  ]),
  _Guide('UNODC', '$_dir/unodc.webp', [
    Agenda('UNODC', page: () => const UnodcPdfviewer()),
  ]),
  _Guide('UNICEF', '$_dir/unicef.webp', const [
    Agenda('UNICEF', asset: 'assets/pdfs/UNICEF.pdf'),
  ]),
  _Guide('ECOSOC', '$_dir/ecosoc.webp', const [
    Agenda('ECOSOC', asset: 'assets/pdfs/ECOSOC.pdf'),
  ]),
  _Guide('IPC', '$_dir/ipc.webp', const [Agenda('IPC')]),
  _Guide('DISEC', '$_dir/disec.webp', const [
    Agenda('DISEC', asset: 'assets/pdfs/DISEC.pdf'),
  ]),
];

String _resolveRemoteUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '${Backend.baseUrl}$path';
}

void _soon(BuildContext context, String title) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$title study guide is coming soon.')));
}

void _openAgenda(BuildContext context, Agenda a, String title) {
  if (!a.available) return _soon(context, title);
  final Widget Function() builder = a.page ?? () => _GenericPdfViewer(a);
  Navigator.push(context, MaterialPageRoute(builder: (_) => builder()));
}

class _GenericPdfViewer extends StatelessWidget {
  const _GenericPdfViewer(this.agenda);
  final Agenda agenda;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasUrl = agenda.url != null && agenda.url!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        centerTitle: true,
        title: Text(
          agenda.title,
          style: TextStyle(color: scheme.onPrimary),
        ),
      ),
      body: hasUrl
          ? SfPdfViewer.network(agenda.url!)
          : SfPdfViewer.asset(agenda.asset!),
    );
  }
}

class StudyGuidespage extends StatefulWidget {
  const StudyGuidespage({super.key});

  @override
  State<StudyGuidespage> createState() => _StudyGuidespageState();
}

class _StudyGuidespageState extends State<StudyGuidespage> {
  late List<_Guide> _guides = List<_Guide>.from(_defaultGuides);
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _fetchRemoteGuides();
  }

  Future<void> _fetchRemoteGuides() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final updatedByKey = <String, List<Agenda>>{};

    // 1. Check GET /study_guides from backend
    try {
      final response = await http
          .get(Uri.parse('${Backend.baseUrl}/study_guides'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final rawList = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> ? decoded['guides'] : null);
        if (rawList is List) {
          for (final item in rawList) {
            if (item is! Map) continue;
            final committee = (item['committee'] ?? item['title'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            if (committee.isEmpty) continue;

            final agendasJson = item['agendas'];
            final remoteAgendas = <Agenda>[];
            if (agendasJson is List) {
              for (final a in agendasJson) {
                if (a is! Map) continue;
                final rawUrl = (a['url'] ?? '').toString();
                final resolved = _resolveRemoteUrl(rawUrl);
                if (resolved.isNotEmpty) {
                  final title = (a['title'] ?? committee).toString().trim();
                  remoteAgendas.add(
                    Agenda(title.isEmpty ? committee : title, url: resolved),
                  );
                }
              }
            } else if (item['url'] != null) {
              final resolved = _resolveRemoteUrl(item['url'].toString());
              if (resolved.isNotEmpty) {
                remoteAgendas.add(Agenda(committee, url: resolved));
              }
            }

            if (remoteAgendas.isNotEmpty) {
              updatedByKey[committee] = remoteAgendas;
            }
          }
        }
      }
    } catch (_) {
      // Ignore network/endpoint errors; fallback checks below still run.
    }

    // 2. Fallback: for any committee without a bundled asset or remote URL yet
    //    (e.g. UNSC, IPC), probe /static/study_guides/<COMMITTEE>.pdf directly.
    for (final g in _defaultGuides) {
      final key = g.title.toUpperCase();
      final alreadyAvailable =
          g.agendas.any((a) => a.available) || updatedByKey.containsKey(key);
      if (alreadyAvailable) continue;
      final staticUrl = '${Backend.baseUrl}/static/study_guides/${g.title}.pdf';
      try {
        final headRes = await http
            .head(Uri.parse(staticUrl))
            .timeout(const Duration(seconds: 5));
        if (headRes.statusCode == 200) {
          updatedByKey[key] = [Agenda(g.title, url: staticUrl)];
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _guides = _defaultGuides.map((g) {
        final remote = updatedByKey[g.title.toUpperCase()];
        if (remote != null && remote.isNotEmpty) {
          return g.copyWith(agendas: remote);
        }
        return g;
      }).toList();
      _isSyncing = false;
    });
  }

  void _open(BuildContext context, _Guide g) {
    if (g.agendas.length > 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _AgendaListPage(guide: g)),
      );
      return;
    }
    _openAgenda(context, g.agendas.first, g.title);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shownGuides =
        _guides.where((g) => g.agendas.any((a) => a.available)).toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        centerTitle: false,
        title: const Text('STUDY GUIDES'),
        actions: [
          IconButton(
            onPressed: _isSyncing ? null : _fetchRemoteGuides,
            tooltip: 'Check for new guides',
            icon: _isSyncing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onSurface,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRemoteGuides,
        child: _FolderGrid(
          count: shownGuides.length,
          builder: (context, i) {
            final g = shownGuides[i];
            final multi = g.agendas.length > 1;
            final ready = g.agendas.any((a) => a.available);
            return FolderCard(
              title: g.title,
              cover: g.cover,
              tag: multi
                  ? '${g.agendas.length} AGENDAS'
                  : (ready ? 'PDF' : 'SOON'),
              onTap: () => _open(context, g),
            );
          },
        ),
      ),
    );
  }
}

class _AgendaListPage extends StatelessWidget {
  const _AgendaListPage({required this.guide});
  final _Guide guide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(centerTitle: false, title: Text(guide.title)),
      body: _FolderGrid(
        count: guide.agendas.length,
        builder: (context, i) {
          final a = guide.agendas[i];
          return Stack(
            fit: StackFit.expand,
            children: [
              FolderCard(
                title: a.title,
                cover: guide.cover,
                tag: a.available ? 'PDF' : 'SOON',
                onTap: () =>
                    _openAgenda(context, a, '${guide.title} - ${a.title}'),
              ),
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 28, 12, 0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Neon.pink,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x88000000), blurRadius: 6),
                      ],
                    ),
                    child: Text(
                      a.title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: Neon.font,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FolderGrid extends StatelessWidget {
  const _FolderGrid({required this.count, required this.builder});
  final int count;
  final Widget Function(BuildContext, int) builder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemBuilder: builder,
    );
  }
}
