import 'package:flutter/material.dart';

import 'package:delego/constants/sponsors.dart';
import 'package:delego/widgets/sponsor_video.dart';

class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          "SPONSORS",
          style: textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ListView.separated(
            itemCount: kSponsors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) =>
                SponsorVideoCard(sponsor: kSponsors[index]),
          ),
        ),
      ),
    );
  }
}
