part of 'portfolio_home.dart';

class _DashboardHeroCard extends StatelessWidget {
  final bool compact;
  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final String primaryValue;
  final String primaryLabel;
  final String secondaryValue;
  final String secondaryLabel;

  const _DashboardHeroCard({
    this.compact = false,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.primaryValue,
    required this.primaryLabel,
    required this.secondaryValue,
    required this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 14 : 18,
        18,
        compact ? 13 : 16,
      ),
      decoration: NavioTheme.surfaceDecoration(active: true, glow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoScaleText(
                      title,
                      maxLines: 1,
                      minFontSize: 12,
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: NavioTheme.textPrimary(alpha: 0.92),
                      ),
                    ),
                    SizedBox(height: compact ? 5 : 7),
                    AutoScaleText(
                      subtitle,
                      maxLines: 2,
                      minFontSize: 9,
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: 12,
                        height: 1.35,
                        color: NavioTheme.textMuted(alpha: 0.52),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _DashboardValuePill(value: primaryValue, label: primaryLabel),
            ],
          ),
          SizedBox(height: compact ? 13 : 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: clampedProgress),
                    duration: NavioTheme.slow,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 5,
                        backgroundColor: NavioTheme.textMuted(alpha: 0.12),
                        color: NavioTheme.accent,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AutoScaleText(
                progressLabel,
                maxLines: 1,
                minFontSize: 8,
                style: TextStyle(
                  fontFamily: "SF-Pro",
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: NavioTheme.textMuted(alpha: 0.48),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Row(
            children: [
              Expanded(
                child: _DashboardMiniStat(
                  label: secondaryLabel,
                  value: secondaryValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardMiniStat(
                  label: "focus",
                  value: clampedProgress >= 1 ? "Plan" : "Tasks",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardValuePill extends StatelessWidget {
  final String value;
  final String label;

  const _DashboardValuePill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 78),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: NavioTheme.textPrimary(alpha: 0.055),
        borderRadius: BorderRadius.circular(NavioTheme.radiusSmall),
        border: Border.all(color: NavioTheme.textPrimary(alpha: 0.08)),
      ),
      child: Column(
        children: [
          AutoScaleText(
            value,
            maxLines: 1,
            minFontSize: 16,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "New-York",
              fontSize: 26,
              color: NavioTheme.textPrimary(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 2),
          AutoScaleText(
            label,
            maxLines: 1,
            minFontSize: 7,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: NavioTheme.textMuted(alpha: 0.46),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _DashboardMiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(NavioTheme.radiusSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: AutoScaleText(
              label,
              maxLines: 1,
              minFontSize: 8,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: NavioTheme.textMuted(alpha: 0.44),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AutoScaleText(
            value,
            maxLines: 1,
            minFontSize: 8,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: NavioTheme.textSecondary(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioButton extends StatefulWidget {
  final bool compact;
  final double? height;
  final bool showSubtitle;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PortfolioButton({
    this.compact = false,
    this.height,
    this.showSubtitle = true,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_PortfolioButton> createState() => _PortfolioButtonState();
}

class _PortfolioButtonState extends State<_PortfolioButton> {
  bool _pressed = false;
  bool _hovered = false;

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = NavioTheme.textPrimary(alpha: _pressed ? 0.62 : 0.92);
    final subtitleColor = NavioTheme.textMuted(alpha: _pressed ? 0.3 : 0.46);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            height: widget.height ?? (widget.compact ? 66 : 76),
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 16 : 20),
            decoration: NavioTheme.surfaceDecoration(
              hovered: _hovered,
              pressed: _pressed,
              glow: _hovered,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoScaleText(
                        widget.title,
                        maxLines: 1,
                        minFontSize: 10,
                        style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontSize: widget.compact ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      if (widget.showSubtitle) ...[
                        const SizedBox(height: 3),
                        AutoScaleText(
                          widget.subtitle,
                          maxLines: 1,
                          minFontSize: 8,
                          style: TextStyle(
                            fontFamily: "SF-Pro",
                            fontSize: widget.compact ? 11 : 12,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSlide(
                  offset: _pressed ? const Offset(0.08, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  child: Icon(
                    widget.icon,
                    color: NavioTheme.textSecondary(alpha: 0.7),
                    size: 20,
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
