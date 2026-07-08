import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:navio/widgets/auto_scale_text.dart';
import 'package:navio/widgets/navio_theme.dart';

class LabelButton extends StatefulWidget {
  final double height;
  final double width;
  final bool? enabled;
  final bool isLoading;
  final bool centerText;
  final bool emphasized;
  final String? text;
  final String? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const LabelButton({
    super.key,
    required this.height,
    required this.width,
    this.text,
    this.icon,
    this.trailingIcon,
    this.onTap,
    this.enabled,
    this.isLoading = false,
    this.centerText = false,
    this.emphasized = false,
  });

  @override
  State<LabelButton> createState() => _LabelButtonState();
}

class _LabelButtonState extends State<LabelButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _isEnabled => widget.enabled == true && !widget.isLoading;

  void _handleTap() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isEnabled
        ? NavioTheme.textPrimary(
            alpha: widget.emphasized
                ? (_pressed ? 0.78 : 0.98)
                : (_pressed ? 0.62 : 0.92),
          )
        : NavioTheme.textMuted(alpha: 0.24);

    final radius = NavioTheme.isApple
        ? NavioTheme.radiusLarge + 6
        : NavioTheme.radiusLarge;
    final decoration = widget.emphasized
        ? BoxDecoration(
            color: _isEnabled ? null : NavioTheme.surfaceColor(disabled: true),
            gradient: _isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _pressed
                        ? const [Color(0xFF5F50F0), Color(0xFF4934D3)]
                        : const [Color(0xFF8A7CFF), Color(0xFF624CFF)],
                  )
                : null,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: _isEnabled
                  ? NavioTheme.accent.withValues(alpha: 0.48)
                  : Colors.white.withValues(alpha: 0.06),
              width: NavioTheme.borderWidth,
            ),
            boxShadow: _isEnabled
                ? [
                    BoxShadow(
                      color: NavioTheme.accent.withValues(
                        alpha: _hovered ? 0.24 : 0.16,
                      ),
                      blurRadius: _hovered ? 28 : 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 18,
                      spreadRadius: -10,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : const [],
          )
        : NavioTheme.surfaceDecoration(
            hovered: _hovered && _isEnabled,
            pressed: _pressed,
            disabled: !_isEnabled,
            glow: _hovered && _isEnabled,
          );

    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? (NavioTheme.isApple ? 0.965 : 0.97) : 1.0,
          duration: NavioTheme.fast,
          curve: NavioTheme.isApple ? Curves.easeOutCubic : Curves.easeOut,
          child: AnimatedContainer(
            duration: NavioTheme.normal,
            curve: NavioTheme.isApple ? Curves.easeOutCubic : Curves.easeOut,
            height: widget.height,
            width: widget.width,
            padding: EdgeInsets.symmetric(
              horizontal: NavioTheme.isApple ? 18 : 20,
            ),
            alignment: widget.centerText
                ? Alignment.center
                : Alignment.centerLeft,
            decoration: decoration,
            child: widget.isLoading
                ? Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: AutoScaleText(
                          widget.text ?? '',
                          maxLines: 1,
                          minFontSize: 10,
                          textAlign: widget.centerText
                              ? TextAlign.center
                              : TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'SF-Pro',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          widget.icon!,
                          style: TextStyle(
                            fontSize: 15,
                            color: NavioTheme.textSecondary(alpha: 0.7),
                          ),
                        ),
                      ] else if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          widget.trailingIcon,
                          size: 17,
                          color: widget.emphasized
                              ? NavioTheme.textPrimary(alpha: 0.88)
                              : NavioTheme.textSecondary(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
