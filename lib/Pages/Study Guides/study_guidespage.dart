import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:delego/Pages/Study Guides/PDF_viewers/IPC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNODC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNSC_pdfviewer.dart';
import 'package:delego/widgets/neon.dart';

/// One agenda (study guide) of a committee.
///
/// Fill in EITHER [asset] (a PDF bundled in assets/pdfs/, e.g.
/// 'assets/pdfs/CCC_Agenda1.pdf') OR [url] (a direct link to a PDF).
/// Leave both null and the folder shows a 'SOON' tag.
class Agenda {
  const Agenda(this.title, {this.asset, this.url, this.page});
  final String title;
  final String? asset;
  final String? url;

  /// Optional custom viewer (used by the older per-committee viewers).
  final Widget Function()? page;

  bool get available => asset != null || url != null || page != null;
}

class _Guide {
  const _Guide(this.title, this.cover, this.agendas);
  final String title;
  final String cover;
  final List<Agenda> agendas;
}

const _dir = 'assets/images/committees';

// ============================================================================
// STUDY GUIDE DATA - EDIT HERE as new guides are received.
//  * One agenda  -> tapping the folder opens the PDF directly.
//  * 2+ agendas  -> tapping the folder opens a page with one folder per agenda.
//  * To add a PDF: copy it into assets/pdfs/ (make sure that folder is declared
//    in pubspec.yaml) and set asset: 'assets/pdfs/X.pdf', or set url: 'https://...'.
// ============================================================================
final List<_Guide> _guides = [
  _Guide('UNSC', '$_dir/unsc.webp', [Agenda('UNSC', page: () => UnscPdfviewer())]),
  _Guide('CCC', '$_dir/ccc.webp', const [
    Agenda('Agenda 1'), // e.g. Agenda('Agenda 1', asset: 'assets/pdfs/CCC_1.pdf')
    Agenda('Agenda 2'), // e.g. Agenda('Agenda 2', url: 'https://...')
  ]),
  _Guide('WTO', '$_dir/wto.webp', const [Agenda('WTO')]),
  _Guide('PSC', '$_dir/psc.webp', const [Agenda('PSC')]),
  _Guide('UNODC', '$_dir/unodc.webp', [Agenda('UNODC', page: () => UnodcPdfviewer())]),
  _Guide('UNICEF', '$_dir/unicef.webp', const [Agenda('UNICEF')]),
  _Guide('ECOSOC', '$_dir/ecosoc.webp', const [Agenda('ECOSOC')]),
  _Guide('IPC', '$_dir/ipc.webp', [Agenda('IPC', page: () => IpcPdfviewer())]),
];

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
    return Scaffold(
      appBar: AppBar(title: Text(agenda.title)),
      body: agenda.asset != null
          ? SfPdfViewer.asset(agenda.asset!)
          : SfPdfViewer.network(agenda.url!),
    );
  }
}

class StudyGuidespage extends StatelessWidget {
  const StudyGuidespage({super.key});

  void _open(BuildContext context, _Guide g) {
    if (g.agendas.length > 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => _AgendaListPage(guide: g)));
      return;
    }
    _openAgenda(context, g.agendas.first, g.title);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        centerTitle: false,
        title: const Text('STUDY GUIDES'),
      ),
      body: _FolderGrid(
        count: _guides.length,
        builder: (context, i) {
          final g = _guides[i];
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
