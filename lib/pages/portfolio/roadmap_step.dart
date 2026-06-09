import 'package:flutter/material.dart';
import 'package:navio/widgets/navio_theme.dart';

class RoadmapStep extends StatefulWidget {
  final int number;
  final String title;
  final String description;
  final bool isLast;
  final bool isExpanded;
  final VoidCallback onTap;

  const RoadmapStep({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.isLast,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<RoadmapStep> createState() => _RoadmapStepState();
}

class _RoadmapStepState extends State<RoadmapStep> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConnector(),
        const SizedBox(width: 12),
        Expanded(child: _buildCard()),
      ],
    );
  }

  Widget _buildConnector() {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NavioTheme.surfaceColor(active: widget.isExpanded),
              border: Border.all(
                color: NavioTheme.borderColor(active: true),
                width: NavioTheme.borderWidth,
              ),
              boxShadow: NavioTheme.glow(
                active: widget.isExpanded,
                alpha: 0.05,
              ),
            ),
            child: Text(
              "${widget.number}",
              style: const TextStyle(
                fontFamily: "SF-Pro",
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: NavioTheme.accent,
              ),
            ),
          ),
          if (!widget.isLast)
            Container(
              width: 1.5,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    NavioTheme.accent.withValues(alpha: 0.24),
                    NavioTheme.accent.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: NavioTheme.surfaceDecoration(
              active: widget.isExpanded,
              pressed: _pressed,
              glow: widget.isExpanded,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTitle(), _buildDescription()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: NavioTheme.textPrimary(),
            ),
          ),
        ),
        AnimatedRotation(
          turns: widget.isExpanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: NavioTheme.textMuted(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        opacity: widget.isExpanded ? 1.0 : 0.0,
        child: widget.isExpanded
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontSize: 12,
                    color: NavioTheme.textSecondary(alpha: 0.58),
                    height: 1.5,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
