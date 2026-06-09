import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:navio/widgets/navio_theme.dart';

class SendButton extends StatefulWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onTap;

  const SendButton({
    super.key,
    required this.isLoading,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  bool _pressed = false;

  void _handleTapDown(_) {
    if (widget.enabled) {
      setState(() => _pressed = true);
    }
  }

  void _handleTapUp(_) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.enabled && !widget.isLoading;

    return GestureDetector(
      onTap: canSend ? widget.onTap : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeInOut,
        child: MouseRegion(
          cursor: canSend ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: 44,
            height: 44,
            decoration: NavioTheme.surfaceDecoration(
              active: canSend,
              pressed: _pressed,
              disabled: !canSend,
              glow: canSend,
              radius: NavioTheme.radiusMedium,
            ),
            child: Center(
              child: widget.isLoading
                  ? Lottie.asset(
                      'assets/animations/loading.json',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      size: 20,
                      color: canSend
                          ? NavioTheme.accent
                          : NavioTheme.textMuted(alpha: 0.25),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
