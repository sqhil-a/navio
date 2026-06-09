part of 'portfolio_home.dart';

class _SkillsRadarCard extends StatelessWidget {
  final List<_SkillItem> skills;

  const _SkillsRadarCard({required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: NavioTheme.surfaceDecoration(active: true, glow: true),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: NavioTheme.slow,
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _RadarChartPainter(skills, progress),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Target level: 4/5",
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 12,
              color: NavioTheme.textMuted(alpha: 0.42),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<_SkillItem> skills;
  final double progress;

  _RadarChartPainter(this.skills, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (skills.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radius = math.min(size.width, size.height) * 0.31;
    final count = skills.length;
    const startAngle = -math.pi / 2;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = NavioTheme.accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = NavioTheme.accent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var ring = 1; ring <= 5; ring++) {
      final path = Path();
      final ringRadius = radius * ring / 5;
      for (var i = 0; i < count; i++) {
        final angle = startAngle + (math.pi * 2 * i / count);
        final point = Offset(
          center.dx + math.cos(angle) * ringRadius,
          center.dy + math.sin(angle) * ringRadius,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < count; i++) {
      final angle = startAngle + (math.pi * 2 * i / count);
      final outer = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(center, outer, axisPaint);
      _drawLabel(canvas, size, center, radius, angle, skills[i].label);
    }

    final valuePath = Path();
    for (var i = 0; i < count; i++) {
      final angle = startAngle + (math.pi * 2 * i / count);
      final valueRadius = radius * skills[i].score / 5 * progress;
      final point = Offset(
        center.dx + math.cos(angle) * valueRadius,
        center.dy + math.sin(angle) * valueRadius,
      );
      if (i == 0) {
        valuePath.moveTo(point.dx, point.dy);
      } else {
        valuePath.lineTo(point.dx, point.dy);
      }
    }
    valuePath.close();
    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    double angle,
    String label,
  ) {
    final labelRadius = radius + 34;
    final point = Offset(
      center.dx + math.cos(angle) * labelRadius,
      center.dy + math.sin(angle) * labelRadius,
    );
    final labelText = _shortLabel(label);
    var fontSize = 10.0;
    late TextPainter painter;

    for (var candidate = 10.0; candidate >= 7.0; candidate -= 0.5) {
      painter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            fontFamily: "SF-Pro",
            fontSize: candidate,
            fontWeight: FontWeight.w700,
            color: NavioTheme.textSecondary(alpha: 0.64),
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: 76);

      fontSize = candidate;
      if (!painter.didExceedMaxLines) break;
    }

    painter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          fontFamily: "SF-Pro",
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: NavioTheme.textSecondary(alpha: 0.64),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: 76);

    final dx = (point.dx - painter.width / 2)
        .clamp(0.0, size.width - painter.width)
        .toDouble();
    final dy = (point.dy - painter.height / 2)
        .clamp(0.0, size.height - painter.height)
        .toDouble();
    painter.paint(canvas, Offset(dx, dy));
  }

  String _shortLabel(String label) {
    return label.replaceAll("Communication", "Comm.");
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    if (oldDelegate.skills.length != skills.length) return true;
    if (oldDelegate.progress != progress) return true;
    for (var i = 0; i < skills.length; i++) {
      if (oldDelegate.skills[i].score != skills[i].score ||
          oldDelegate.skills[i].label != skills[i].label) {
        return true;
      }
    }
    return false;
  }
}

class _SkillSection extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<Widget> children;

  const _SkillSection({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: NavioTheme.surfaceDecoration(border: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: NavioTheme.textPrimary(),
            ),
          ),
          const SizedBox(height: 12),
          if (children.isEmpty)
            Text(
              emptyText,
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 13,
                color: NavioTheme.textMuted(alpha: 0.42),
                height: 1.45,
              ),
            )
          else
            Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: NavioTheme.surfaceDecoration(
        active: true,
        radius: NavioTheme.radiusSmall,
        border: false,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: NavioTheme.textSecondary(alpha: 0.78),
        ),
      ),
    );
  }
}

class _SkillGapTile extends StatelessWidget {
  final _SkillItem skill;
  final VoidCallback onImprove;

  const _SkillGapTile({required this.skill, required this.onImprove});

  @override
  Widget build(BuildContext context) {
    final progress = skill.score / skill.target;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: NavioTheme.surfaceDecoration(
        radius: NavioTheme.radiusMedium,
        border: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.label,
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: NavioTheme.textSecondary(alpha: 0.78),
                  ),
                ),
              ),
              Text(
                "${skill.score}/${skill.target}",
                style: TextStyle(
                  fontFamily: "SF-Pro",
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: NavioTheme.textMuted(alpha: 0.46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 4,
              backgroundColor: NavioTheme.textMuted(alpha: 0.12),
              color: NavioTheme.accent,
            ),
          ),
          const SizedBox(height: 10),
          _ImproveButton(onTap: onImprove),
        ],
      ),
    );
  }
}

class _ImproveButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ImproveButton({required this.onTap});

  @override
  State<_ImproveButton> createState() => _ImproveButtonState();
}

class _ImproveButtonState extends State<_ImproveButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: NavioTheme.fast,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: NavioTheme.normal,
            curve: Curves.easeOut,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: NavioTheme.surfaceDecoration(
              hovered: _hovered,
              pressed: _pressed,
              glow: _hovered,
              radius: NavioTheme.radiusSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Improve",
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: NavioTheme.textPrimary(alpha: _pressed ? 0.62 : 0.9),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: NavioTheme.textSecondary(alpha: 0.68),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

