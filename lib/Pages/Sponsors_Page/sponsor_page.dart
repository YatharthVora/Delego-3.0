import 'package:flutter/material.dart';
import 'package:delego/Theme/theme_controller.dart';


class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SPONSORS",
          style: textTheme.titleLarge?.copyWith(
            color: scheme.onPrimary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      backgroundColor: scheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Image.asset("assets/img/lydas_logo.png"),
            height: 250.0,
          ),
          Container(
            child: Image.asset("assets/img/RiseUp_Logo.png"),
            height: 250.0,
          ),
          Container(
            child: Image.asset("assets/img/tiirva_logo.png"),
            height: 250.0,
          ),
        ],
      ),
    );
  }
}
