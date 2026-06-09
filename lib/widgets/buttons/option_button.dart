import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:navio/widgets/auto_scale_text.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';

class OptionButton extends StatefulWidget {
  final double height;
  final bool? enabled;
  final bool singleChoice;
  final String? text;
  final VoidCallback? onTap;
  final bool selected;

  const OptionButton({
    super.key,
    required this.height,
    this.text,
    this.onTap,
    this.enabled,
    required this.singleChoice,
    this.selected = false,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> {
  bool tapped = false;
  bool _pressed = false;
  bool _hovered = false;

  bool get _isEnabled => widget.enabled != false;
  bool get _isActive => widget.singleChoice ? tapped : widget.selected;

  @override
  void initState() {
    super.initState();
    if (widget.singleChoice) {
      tapped = selectedOptionButtonNotifier.value == widget.text;
      selectedOptionButtonNotifier.addListener(_updateSingleChoiceState);
    }
  }

  @override
  void dispose() {
    if (widget.singleChoice) {
      selectedOptionButtonNotifier.removeListener(_updateSingleChoiceState);
    }
    super.dispose();
  }

  void _updateSingleChoiceState() {
    setState(() {
      tapped = selectedOptionButtonNotifier.value == widget.text;
    });
  }

  void _handleTap() {
    if (!_isEnabled) return;

    if (widget.singleChoice) {
      selectedOptionButtonNotifier.value =
          selectedOptionButtonNotifier.value == widget.text
          ? null
          : widget.text;
    }

    Haptics.vibrate(HapticsType.selection);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    // --- dynamic width calculation (kept exactly as before) ---
    final textWidth = (widget.text != null)
        ? (TextPainter(
            text: TextSpan(
              text: widget.text!,
              style: const TextStyle(
                fontFamily: "SF-Pro",
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout()).size.width
        : 0.0;

    const minWidth = 80.0;
    const horizontalPadding = 32.0;
    final containerWidth = (textWidth + horizontalPadding).clamp(
      minWidth,
      double.infinity,
    );

    final textColor = !_isEnabled
        ? NavioTheme.textMuted(alpha: 0.28)
        : _isActive
        ? NavioTheme.textPrimary(alpha: _pressed ? 0.62 : 0.95)
        : NavioTheme.textSecondary();

    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
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
            width: containerWidth,
            alignment: Alignment.center,
            decoration: NavioTheme.surfaceDecoration(
              active: _isActive,
              hovered: _hovered && _isEnabled,
              pressed: _pressed,
              disabled: !_isEnabled,
              glow: _isActive,
            ),
            child: AutoScaleText(
              widget.text ?? "",
              maxLines: 1,
              minFontSize: 10,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
