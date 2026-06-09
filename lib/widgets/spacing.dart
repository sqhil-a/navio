import 'package:flutter/material.dart';

class Spacing extends StatelessWidget {
  final double? height;
  final double? width;

  const Spacing({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}
