import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';
import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/constants/separator.dart';

class DetailPage extends StatelessWidget {
  final Schedule schedule;
  const DetailPage(this.schedule, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: scheme.surface,
        child: Stack(
          children: <Widget>[
            _getBackground(),
            _getGradient(scheme),
            _getContent(context, scheme, textTheme),
            _getToolbar(context, scheme),
          ],
        ),
      ),
    );
  }

  Container _getBackground() {
    return Container(
      constraints: const BoxConstraints.expand(height: 295.0),
      child: Image.network(
        schedule.imageUrl,
        fit: BoxFit.cover,
        height: 300.0,
      ),
    );
  }

  Container _getGradient(ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.surface.withValues(alpha: 0.0),
            scheme.surface.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.9],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
        ),
      ),
    );
  }

  Widget _getContent(BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    final overviewTitle = "Overview".toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 20.0),
      children: <Widget>[
        ScheduleSummary(
          schedule,
          isFirst: true,
          isLast: true,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                overviewTitle,
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Separator(),
              Text(
                schedule.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _getToolbar(BuildContext context, ColorScheme scheme) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: BackButton(color: scheme.onPrimary),
    );
  }
}
