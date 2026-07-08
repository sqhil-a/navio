import 'package:flutter/material.dart';
import 'package:navio/widgets/navio_theme.dart';

class TopFadeOverlay extends StatelessWidget {
  final double height;

  const TopFadeOverlay({
    super.key,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NavioTheme.background,
              NavioTheme.background.withValues(alpha: 0.94),
              NavioTheme.background.withValues(alpha: 0.72),
              NavioTheme.background.withValues(alpha: 0.36),
              NavioTheme.background.withValues(alpha: 0),
            ],
            stops: const [0, 0.22, 0.46, 0.72, 1],
          ),
        ),
      ),
    );
  }
}
