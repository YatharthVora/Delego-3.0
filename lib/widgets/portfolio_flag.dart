import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// A portfolio's flag (bundled, works offline); for a person, their party badge when
/// they have one (PSC), else a person icon.
class PortfolioFlag extends StatelessWidget {
  const PortfolioFlag(
      {super.key, required this.code, this.tag, this.width = 36});

  /// ISO alpha-2, lower case (as stored on the floor); null for a person.
  final String? code;

  /// A person's party abbreviation ("BJP", "SS(UBT)").
  final String? tag;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 3 / 4;
    final theme = ImageTheme(
      width: width,
      height: height,
      shape: const RoundedRectangle(4),
    );
    final code = this.code;
    final Widget flag;
    if (code == null && tag != null) {
      // As wide as the abbreviation needs: "SS(UBT)" stays as legible as "BJP".
      return ExcludeSemantics(
          child: _TagBadge(width: width, height: height, tag: tag!));
    } else if (code == null) {
      flag = _Box(width: width, height: height, icon: Icons.person);
    } else if (code == 'eu') {
      // The package maps the EU flag from its currency, not a country code.
      flag = CountryFlag.fromCurrencyCode('EUR', theme: theme);
    } else if (code == 'un') {
      flag = _Box(width: width, height: height, icon: Icons.public);
    } else {
      flag = CountryFlag.fromCountryCode(code, theme: theme);
    }
    return ExcludeSemantics(
        child: SizedBox(width: width, height: height, child: flag));
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.icon});

  final double width;
  final double height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: height * 0.8, color: scheme.onSurfaceVariant),
    );
  }
}

/// A party abbreviation in a neutral badge the size of a flag (no party colours or logos:
/// the chrome stays monochrome, and logos would be trademarked downloads).
class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.width, required this.height, required this.tag});

  /// The flag's size: the badge is at least this wide and exactly this tall.
  final double width;
  final double height;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(minWidth: width, minHeight: height, maxHeight: height),
      padding: EdgeInsets.symmetric(horizontal: height * 0.15),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      // widthFactor 1: as wide as the text (not the whole slot), centred in the height.
      child: Center(
        widthFactor: 1,
        child: Text(
          tag,
          maxLines: 1,
          softWrap: false,
          textScaler: TextScaler.noScaling, // sized to the flag box, like a flag
          style: TextStyle(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.w700,
            fontSize: height * 0.48,
            height: 1,
          ),
        ),
      ),
    );
  }
}
