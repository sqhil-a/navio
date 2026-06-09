import 'package:flutter/material.dart';
import 'package:navio/widgets/navio_theme.dart';

class NavioNotification extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onDismissed;

  const NavioNotification({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.onDismissed,
  });

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 100,
        left: 24,
        right: 24,
        child: NavioNotification(
          message: message,
          duration: duration,
          onDismissed: () => overlayEntry.remove(),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<NavioNotification> createState() => _NavioNotificationState();
}

class _NavioNotificationState extends State<NavioNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  // How long the enter/exit transitions take
  static const _animDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _animDuration);

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slide =
        Tween<Offset>(
          begin: const Offset(0, 0.3), // starts slightly below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Play enter animation, wait, then play exit animation
    _controller.forward().then((_) {
      Future.delayed(widget.duration, _dismiss);
    });
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: NavioTheme.surfaceDecoration(
              active: true,
              glow: true,
              radius: NavioTheme.radiusMedium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: NavioTheme.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: NavioTheme.textPrimary(),
                      fontFamily: "SF-Pro",
                      fontSize: 14,
                    ),
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
