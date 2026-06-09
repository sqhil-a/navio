import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavioTheme {
  const NavioTheme._();

  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF17171C);
  static const Color surfaceRaised = Color(0xFF202027);
  static const Color surfacePressed = Color(0xFF121216);
  static const Color accent = Color(0xFF8A7CFF);

  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 16;
  static const double borderWidth = 1.2;

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 300);

  static bool get isApple {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static Color textPrimary({double alpha = 0.92}) =>
      Colors.white.withValues(alpha: alpha);

  static Color textSecondary({double alpha = 0.62}) =>
      Colors.white.withValues(alpha: alpha);

  static Color textMuted({double alpha = 0.36}) =>
      Colors.white.withValues(alpha: alpha);

  static Color surfaceColor({
    bool active = false,
    bool hovered = false,
    bool pressed = false,
    bool disabled = false,
  }) {
    if (isApple) {
      if (disabled) return Colors.white.withValues(alpha: 0.035);
      if (active && pressed) return Colors.white.withValues(alpha: 0.1);
      if (active) return Colors.white.withValues(alpha: 0.082);
      if (pressed) return Colors.white.withValues(alpha: 0.055);
      if (hovered) return Colors.white.withValues(alpha: 0.07);
      return Colors.white.withValues(alpha: 0.052);
    }

    if (disabled) return Color.lerp(surface, background, 0.18)!;
    if (active && pressed) return Color.lerp(surfacePressed, accent, 0.04)!;
    if (active) return surfaceRaised;
    if (pressed) return surfacePressed;
    if (hovered) return surfaceRaised;
    return surface;
  }

  static Color borderColor({
    bool active = false,
    bool focused = false,
    bool disabled = false,
  }) {
    if (isApple) {
      if (disabled) return Colors.white.withValues(alpha: 0.055);
      if (focused) return Colors.white.withValues(alpha: 0.34);
      if (active) return Colors.white.withValues(alpha: 0.22);
      return Colors.white.withValues(alpha: 0.105);
    }

    if (disabled) return Colors.white.withValues(alpha: 0.06);
    if (focused) return accent.withValues(alpha: 0.58);
    if (active) return accent.withValues(alpha: 0.34);
    return Colors.white.withValues(alpha: 0.09);
  }

  static List<BoxShadow> glow({
    bool active = true,
    bool strong = false,
    double alpha = 0.07,
  }) {
    if (!active) return const [];

    if (isApple) {
      return [
        BoxShadow(
          color: Colors.white.withValues(alpha: strong ? 0.055 : 0.035),
          blurRadius: strong ? 26 : 18,
          spreadRadius: -2,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.24),
          blurRadius: 28,
          spreadRadius: -10,
          offset: const Offset(0, 14),
        ),
      ];
    }

    return [
      BoxShadow(
        color: accent.withValues(alpha: strong ? alpha + 0.03 : alpha),
        blurRadius: strong ? 20 : 14,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static BoxDecoration surfaceDecoration({
    bool active = false,
    bool hovered = false,
    bool pressed = false,
    bool focused = false,
    bool disabled = false,
    bool glow = false,
    bool border = true,
    double radius = radiusLarge,
  }) {
    final effectiveRadius = isApple ? radius + 6 : radius;

    return BoxDecoration(
      color: surfaceColor(
        active: active,
        hovered: hovered,
        pressed: pressed,
        disabled: disabled,
      ),
      borderRadius: BorderRadius.circular(effectiveRadius),
      border: border
          ? Border.all(
              color: borderColor(
                active: active,
                focused: focused,
                disabled: disabled,
              ),
              width: borderWidth,
            )
          : null,
      boxShadow: NavioTheme.glow(active: glow && !disabled, strong: active),
    );
  }
}
