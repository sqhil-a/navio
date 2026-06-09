import 'package:flutter/material.dart';
import 'package:navio/widgets/navio_theme.dart';

class PortfolioCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const PortfolioCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 90,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: NavioTheme.surfaceDecoration(
          active: isPrimary,
          glow: isPrimary,
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "SF-Pro",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontSize: 13,
                    color: NavioTheme.textSecondary(),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: NavioTheme.textSecondary(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
