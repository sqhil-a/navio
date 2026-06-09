import 'package:flutter/material.dart';
import 'package:navio/widgets/navio_theme.dart';

class LineSeparator extends StatelessWidget {
  final LinearGradient? gradient;

  const LineSeparator({super.key, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                NavioTheme.accent.withValues(alpha: 0.16),
                NavioTheme.textMuted(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
      ),
    );
  }
}
