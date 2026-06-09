import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';

class NavButton extends StatefulWidget {
  final int index;
  final IconData iconDefault;
  final IconData iconSelected;
  final String label;

  const NavButton({
    super.key,
    required this.index,
    required this.iconDefault,
    required this.iconSelected,
    required this.label,
  });

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedNavIndexNotifier,
      builder: (context, value, child) {
        final bool isSelected = value == widget.index;

        return GestureDetector(
          onTap: () {
            Haptics.vibrate(HapticsType.light);
            showPlanNotifier.value = false;
            if (widget.index == 1) {
              portfolioTabTapNotifier.value++;
            }
            selectedNavIndexNotifier.value = widget.index;
          },
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                // Fill the full Expanded width so all buttons are equal size
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? NavioTheme.surfaceColor(active: true, pressed: _pressed)
                      : NavioTheme.isApple
                      ? Colors.white.withValues(alpha: 0.012)
                      : Colors.transparent,
                  boxShadow: NavioTheme.glow(
                    active: isSelected,
                    alpha: _pressed ? 0.04 : 0.06,
                  ),
                  borderRadius: BorderRadius.circular(
                    NavioTheme.isApple
                        ? NavioTheme.radiusLarge + 8
                        : NavioTheme.radiusLarge,
                  ),
                  border: NavioTheme.isApple && isSelected
                      ? Border.all(
                          color: NavioTheme.borderColor(active: true),
                          width: NavioTheme.borderWidth,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: TweenAnimationBuilder(
                        tween: ColorTween(
                          begin: NavioTheme.textPrimary(),
                          end: isSelected
                              ? NavioTheme.accent
                              : NavioTheme.textPrimary(),
                        ),
                        duration: const Duration(milliseconds: 150),
                        builder: (context, color, child) {
                          return Icon(
                            isSelected
                                ? widget.iconSelected
                                : widget.iconDefault,
                            size: 35,
                            color: color,
                          );
                        },
                      ),
                    ),

                    Spacing(height: 5),

                    TweenAnimationBuilder(
                      tween: ColorTween(
                        begin: NavioTheme.textPrimary(),
                        end: isSelected
                            ? NavioTheme.accent
                            : NavioTheme.textPrimary(),
                      ),
                      duration: const Duration(milliseconds: 150),
                      builder: (context, color, child) {
                        return Text(
                          widget.label,
                          style: TextStyle(
                            fontFamily: "SF-Pro",
                            fontWeight: FontWeight(800),
                            fontSize: 15,
                            color: isSelected ? color : Colors.transparent,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
