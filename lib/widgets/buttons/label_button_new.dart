import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
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
    final foreground = _isEnabled
        ? NavioTheme.textPrimary(alpha: _pressed ? 0.78 : 0.96)
        : NavioTheme.textMuted();

    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_isEnabled) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        onTapDown: (_) {
          if (_isEnabled) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          if (_isEnabled) setState(() => _pressed = false);
        },
        onTapCancel: () {
          if (_isEnabled) setState(() => _pressed = false);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: widget.height,
            width: widget.width,
            decoration: NavioTheme.surfaceDecoration(
              active: _isEnabled,
              hovered: _hovered && _isEnabled,
              pressed: _pressed,
              disabled: !_isEnabled,
              glow: _isEnabled,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: Lottie.asset(
                          'assets/animations/loading.json',
                          fit: BoxFit.contain,
                        ),
                      )
                    : Text(
                        widget.text ?? '',
                        key: const ValueKey('text'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF-Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.4,
                          color: foreground,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
