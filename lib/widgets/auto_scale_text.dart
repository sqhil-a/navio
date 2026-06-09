import 'package:flutter/material.dart';

class AutoScaleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final double minFontSize;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final bool softWrap;

  const AutoScaleText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.minFontSize = 8,
    this.textAlign,
    this.overflow = TextOverflow.clip,
    this.softWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(style);
    final baseSize = effectiveStyle.fontSize ?? defaultStyle.fontSize ?? 14;

    return LayoutBuilder(
      builder: (context, constraints) {
        var size = baseSize;
        final maxWidth = constraints.maxWidth;

        if (maxWidth.isFinite && maxWidth > 0) {
          for (
            var candidate = baseSize;
            candidate >= minFontSize;
            candidate -= 0.5
          ) {
            final painter = TextPainter(
              text: TextSpan(
                text: text,
                style: effectiveStyle.copyWith(fontSize: candidate),
              ),
              maxLines: maxLines,
              textAlign: textAlign ?? TextAlign.start,
              textDirection: Directionality.of(context),
            )..layout(maxWidth: maxWidth);

            if (!painter.didExceedMaxLines && painter.width <= maxWidth) {
              size = candidate;
              break;
            }
            size = minFontSize;
          }
        }

        return Text(
          text,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          textAlign: textAlign,
          style: effectiveStyle.copyWith(fontSize: size),
        );
      },
    );
  }
}
