import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navio/widgets/auto_scale_text.dart';
import 'package:navio/widgets/navio_theme.dart';

class LabelButton extends StatefulWidget {
  final double height;
  final double width;
  final bool? enabled;
  final bool isLoading;
  final String? text;
  final String? icon;
  final VoidCallback? onTap;

  const LabelButton({
    super.key,
    required this.height,
    required this.width,
    this.text,
    this.icon,
    this.onTap,
    this.enabled,
    this.isLoading = false,
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
        ? NavioTheme.textPrimary(alpha: _pressed ? 0.62 : 0.92)
        : NavioTheme.textMuted(alpha: 0.24);

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
            alignment: Alignment.centerLeft,
            decoration: NavioTheme.surfaceDecoration(
              hovered: _hovered && _isEnabled,
              pressed: _pressed,
              disabled: !_isEnabled,
              glow: _hovered && _isEnabled,
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: NavioTheme.textSecondary(alpha: 0.7),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: AutoScaleText(
                          widget.text ?? '',
                          maxLines: 1,
                          minFontSize: 10,
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
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
