/// One sponsor: shown as a logo in the home marquee and as an ad card (video, title,
/// tap-to-open link) on the Sponsors page.
class Sponsor {
  const Sponsor({
    required this.name,
    required this.logo,
    this.url,
    this.videoAsset,
    this.scale = 1.0,
    this.tier,
    this.backgroundColorHex = 0xFFFFFFFF,
  });

  /// Title shown under the video/logo.
  final String name;

  /// Logo asset (marquee, and the card media when there is no video).
  final String logo;

  /// Optional external page opened when the card is tapped.
  final String? url;

  /// Optional mp4 asset. When null or missing the card shows the logo instead.
  final String? videoAsset;

  /// Relative visual scale (e.g. >1.0 for Title / Associate sponsors).
  final double scale;

  /// Optional tier badge shown on the Sponsors page (e.g. 'TITLE SPONSOR').
  final String? tier;

  /// Background colour behind the logo in the marquee and sponsor card.
  final int backgroundColorHex;
}

/// Sponsors, in the order they are shown (home marquee and Sponsors page).
const kSponsors = <Sponsor>[
  Sponsor(
    name: 'Coway',
    logo: 'assets/icons/coway.png',
    url: 'https://cowayindia.in',
    videoAsset: 'assets/videos/sponsor_video.mp4',
    scale: 1.38,
    tier: 'TITLE SPONSOR',
    backgroundColorHex: 0xFFFFFFFF,
  ),
  Sponsor(
    name: 'Unrush',
    logo: 'assets/icons/unrush.png',
    url: 'https://shopunrush.com',
    scale: 1.18,
    backgroundColorHex: 0xFF000000,
  ),
  Sponsor(
    name: 'Gokyo',
    logo: 'assets/icons/gokyo.png',
    url: 'https://gokyo.in',
    scale: 1.0,
    backgroundColorHex: 0xFF0F172A,
  ),
  Sponsor(
    name: "Gamer's Street",
    logo: 'assets/icons/gamers_street.png',
    url: 'https://gamersstreet.info',
    scale: 1.0,
    backgroundColorHex: 0xFF000000,
  ),
  Sponsor(
    name: 'Alibaug Stays',
    logo: 'assets/icons/alibaug_stays.png',
    url: 'https://alibaugstays.com',
    scale: 1.0,
    backgroundColorHex: 0xFF7B0C2E,
  ),
];
