/// One sponsor: shown as a logo in the home marquee and as an ad card (video, title,
/// tap-to-open link) on the Sponsors page.
class Sponsor {
  const Sponsor({
    required this.name,
    required this.logo,
    required this.url,
    this.videoAsset,
  });

  /// Title shown under the video.
  final String name;

  /// Logo asset (marquee, and the placeholder when there is no video).
  final String logo;

  /// Page opened when the card is tapped.
  final String url;

  /// Optional mp4 asset. When null or missing the card shows the logo instead.
  final String? videoAsset;
}

/// Sponsors, in the order they are shown (home marquee and Sponsors page).
/// TODO: replace every placeholder url below with the sponsor's real page, and drop
/// each sponsor's mp4 into assets/videos/ then set its videoAsset.
const kSponsors = <Sponsor>[
  Sponsor(
    name: 'Toshiba',
    logo: 'assets/icons/toshiba.png',
    url: 'https://www.toshiba.com', // TODO: real sponsor URL
    videoAsset: 'assets/videos/sponsor_video.mp4',
  ),
  Sponsor(
    name: 'BAE Systems',
    logo: 'assets/icons/bae.png',
    url: 'https://www.baesystems.com', // TODO: real sponsor URL
  ),
  Sponsor(
    name: 'Basant',
    logo: 'assets/icons/basant.png',
    url: 'https://example.com/basant', // TODO: real sponsor URL
  ),
  Sponsor(
    name: 'Citrus',
    logo: 'assets/icons/citrus.png',
    url: 'https://example.com/citrus', // TODO: real sponsor URL
  ),
  Sponsor(
    name: 'T-Park',
    logo: 'assets/icons/tpark.png',
    url: 'https://example.com/tpark', // TODO: real sponsor URL
  ),
];
