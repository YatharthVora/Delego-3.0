import 'package:flutter_test/flutter_test.dart';

import 'package:delego/constants/portfolios.dart';
import 'package:delego/models/portfolio_search.dart';

List<String> names(String q, {List<String> taken = const []}) =>
    searchPortfolios(q, taken: taken).map((m) => m.portfolio.name).toList();

void main() {
  test('the list has every UN member and well-formed, unique flag codes', () {
    // 193 members + Holy See, Palestine, Kosovo, Taiwan, EU, UN.
    expect(kPortfolios.length, 199);
    expect(kPortfolios.map((p) => p.name).toSet().length, kPortfolios.length);
    expect(kPortfolios.map((p) => p.code).toSet().length, kPortfolios.length);
    for (final p in kPortfolios) {
      expect(RegExp(r'^[a-z]{2}$').hasMatch(p.code ?? ''), isTrue, reason: p.name);
    }
  });

  test('a name prefix ranks first, then word prefixes', () {
    expect(names('ind').take(2), ['India', 'Indonesia']);
    final kor = names('kor');
    expect(kor, containsAll(['DPRK', 'Republic of Korea']));
  });

  test('aliases find the official name', () {
    expect(names('usa').first, 'United States');
    expect(names('uk').first, 'United Kingdom');
    expect(names('ivory').first, "Côte d'Ivoire");
    expect(names('burma').first, 'Myanmar');
    expect(names('north korea').first, 'DPRK');
    expect(names('turkey').first, 'Türkiye');
  });

  test('accents, case and punctuation are ignored', () {
    expect(names('COTE D IVOIRE').first, "Côte d'Ivoire");
    expect(names('turkiye').first, 'Türkiye');
    expect(names('sao tome').first, 'São Tomé and Príncipe');
    expect(names('guinea bissau').first, 'Guinea-Bissau');
  });

  test('an exact match beats a prefix', () {
    expect(names('niger').first, 'Niger');
    expect(names('guinea').first, 'Guinea');
  });

  test('portfolios already on the list are marked, not hidden', () {
    final results = searchPortfolios('ind', taken: ['india']);
    expect(results.first.portfolio.name, 'India');
    expect(results.first.onList, isTrue);
    expect(results[1].onList, isFalse);
  });

  test('at most 8 suggestions, none for an empty query', () {
    expect(searchPortfolios('a').length, 8);
    expect(searchPortfolios('   '), isEmpty);
    expect(searchPortfolios('zzzz'), isEmpty);
  });

  test('exactPortfolio matches names and aliases only', () {
    expect(exactPortfolio('usa')?.code, 'us');
    expect(exactPortfolio('India')?.code, 'in');
    expect(exactPortfolio('ind'), isNull);
    expect(exactPortfolio('Mr Sharma'), isNull);
  });

  test('a matrix borrows the country nicknames and keeps party details', () {
    final m = matrixPortfolios([
      {'name': 'United States of America', 'code': 'us', 'tag': null, 'detail': null},
      {'name': 'Russian Federation', 'code': 'ru', 'tag': null, 'detail': null},
      {'name': 'Ajay Maken', 'code': null, 'tag': 'INC', 'detail': 'Indian National Congress'},
    ]);
    List<String> find(String q) =>
        searchPortfolios(q, portfolios: m).map((x) => x.portfolio.name).toList();
    expect(find('usa').first, 'United States of America');
    expect(find('russia').first, 'Russian Federation');
    expect(find('inc'), ['Ajay Maken']);
    expect(find('congress'), ['Ajay Maken']);
    expect(find('kenya'), isEmpty, reason: 'only the matrix');
    expect(m[2].code, isNull);
    expect(m[2].tag, 'INC');
  });
}
