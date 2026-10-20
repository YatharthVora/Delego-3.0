import 'package:delego/constants/portfolios.dart';

/// One suggestion for the EB's search box.
class PortfolioMatch {
  const PortfolioMatch(this.portfolio, {required this.onList, this.rank = 0});

  final Portfolio portfolio;

  /// Already on the list being edited (shown greyed out, can't be added twice).
  final bool onList;

  /// How well it matched (lower is better): 0 exact name or alias, 1 name prefix, 2 a
  /// word of the name, 3 alias prefix, 4 a word of an alias, 5 and up: somewhere inside.
  final int rank;

  /// Typed exactly (a name or an alias).
  bool get exact => rank == 0;

  /// Starts the name or a word of it (or of an alias): what the EB is likely typing.
  /// Matches only somewhere inside ("ali" in Australia) are not strong.
  bool get strong => rank <= 4;
}

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n',
};

/// Lower case, accents dropped, apostrophes and dots removed, hyphens as spaces, so
/// "cote d'ivoire", "Côte d’Ivoire" and "COTE DIVOIRE" all compare equal.
String foldName(String s) {
  final out = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    if (ch == "'" || ch == '’' || ch == '.') continue;
    out.write(ch == '-' ? ' ' : (_accents[ch] ?? ch));
  }
  return out.toString().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).join(' ');
}

/// How well a folded name matches the folded query: lower is better, null is no match.
int? _rank(String name, String q, {required bool alias}) {
  if (name == q) return 0;
  final base = alias ? 3 : 1;
  if (name.startsWith(q)) return base;
  if (name.split(' ').any((w) => w.startsWith(q))) return base + 1;
  if (name.contains(q)) return 5;
  // Spacing typed differently: "cote d ivoire", "newzealand".
  final squashed = q.replaceAll(' ', '');
  if (squashed.length >= 3 && name.replaceAll(' ', '').contains(squashed)) return 6;
  return null;
}

/// The best portfolios for what the EB typed, best first: an exact name or alias, then
/// names starting with it, then a word starting with it ("kor" finds both Koreas), then
/// aliases ("usa", "uk", "ivory"), then anything containing it. Portfolios already on the
/// list (by name, in [taken]) stay in place but are marked [PortfolioMatch.onList].
List<PortfolioMatch> searchPortfolios(
  String query, {
  Iterable<String> taken = const [],
  int limit = 8,
  List<Portfolio> portfolios = kPortfolios,
}) {
  final q = foldName(query);
  if (q.isEmpty) return const [];
  final takenFolded = taken.map(foldName).toSet();

  final scored = <(int, int, Portfolio)>[];
  for (var i = 0; i < portfolios.length; i++) {
    final p = portfolios[i];
    int? best = _rank(foldName(p.name), q, alias: false);
    for (final a in p.aliases) {
      final r = _rank(foldName(a), q, alias: true);
      if (r != null && (best == null || r < best)) best = r;
    }
    if (best != null) scored.add((best, i, p));
  }
  scored.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
  return [
    for (final s in scored.take(limit))
      PortfolioMatch(s.$3, onList: takenFolded.contains(foldName(s.$3.name)), rank: s.$1),
  ];
}

/// The portfolio whose name or alias is exactly [query] (after folding), if any.
Portfolio? exactPortfolio(String query, {List<Portfolio> portfolios = kPortfolios}) {
  final q = foldName(query);
  if (q.isEmpty) return null;
  for (final p in portfolios) {
    if (foldName(p.name) == q || p.aliases.any((a) => foldName(a) == q)) return p;
  }
  return null;
}
