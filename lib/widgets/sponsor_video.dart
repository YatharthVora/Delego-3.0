import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:delego/constants/sponsors.dart';
import 'package:delego/widgets/neon.dart';

/// Default sponsor video location. Drop the file here (same name) and rebuild:
///   assets/videos/sponsor_video.mp4
/// Each sponsor's own video is set in lib/constants/sponsors.dart. Until a file
/// exists the card shows the sponsor's logo instead.
const kSponsorVideoAsset = 'assets/videos/sponsor_video.mp4';

/// Sponsor ad card: video (or logo placeholder) on top, the sponsor's name directly
/// below it. The whole card is a link that opens [Sponsor.url] in the browser.
class SponsorVideoCard extends StatefulWidget {
  const SponsorVideoCard({super.key, required this.sponsor});

  final Sponsor sponsor;

  @override
  State<SponsorVideoCard> createState() => _SponsorVideoCardState();
}

class _SponsorVideoCardState extends State<SponsorVideoCard> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final asset = widget.sponsor.videoAsset;
    if (asset == null) return;
    final c = VideoPlayerController.asset(asset);
    try {
      await c.initialize(); // throws if the file is not there yet
      await c.setLooping(true);
      await c.setVolume(0); // ad plays silently; the card tap opens the link
      if (!mounted) {
        await c.dispose();
        return;
      }
      await c.play();
      setState(() => _controller = c);
    } catch (_) {
      await c.dispose();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final rawUrl = widget.sponsor.url;
    if (rawUrl == null || rawUrl.trim().isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(rawUrl.trim());
    var ok = false;
    if (uri != null) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    if (!ok) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not open the link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = _controller;
    final s = widget.sponsor;
    final isTitle = s.scale > 1.25;
    final isSecond = !isTitle && s.scale > 1.1;

    final double mediaHeight = isTitle ? 210 : (isSecond ? 175 : 145);
    final double logoPadding = isTitle ? 18 : (isSecond ? 22 : 28);

    final Widget media;
    if (c != null && c.value.isInitialized) {
      media = SizedBox(
        height: mediaHeight,
        child: AspectRatio(
          aspectRatio: c.value.aspectRatio,
          child: VideoPlayer(c),
        ),
      );
    } else {
      // No video yet (or still loading): show the logo as the ad image.
      media = Container(
        height: mediaHeight,
        color: Color(s.backgroundColorHex),
        padding: EdgeInsets.all(logoPadding),
        alignment: Alignment.center,
        child: Image.asset(s.logo, fit: BoxFit.contain),
      );
    }

    return Semantics(
      link: true,
      button: true,
      label: '${s.name}. Opens the sponsor website.',
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: isTitle ? 6 : 4,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isTitle
                ? const BorderSide(color: Neon.pink, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: _open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                media,
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: Neon.font,
                                  fontWeight: isTitle
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: isTitle ? 21 : (isSecond ? 19 : 17),
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            if (s.tier != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Neon.pink,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.tier!,
                                  style: const TextStyle(
                                    fontFamily: Neon.font,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (s.url != null && s.url!.isNotEmpty)
                        Icon(Icons.open_in_new_rounded,
                            size: 18, color: scheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
