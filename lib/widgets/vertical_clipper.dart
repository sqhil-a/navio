// lib/widgets/vertical_clipper.dart
import 'package:flutter/material.dart';

class VerticalClipper extends StatelessWidget {
  final Widget child;
  const VerticalClipper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(clipper: _VerticalOnlyClipper(), child: child);
  }
}

class _VerticalOnlyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(-20, 0, size.width + 20, size.height);
  }

  @override
  bool shouldReclip(_VerticalOnlyClipper oldClipper) => false;
}
