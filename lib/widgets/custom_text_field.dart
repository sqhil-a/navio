import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navio/widgets/navio_theme.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final int maxLength;
  final int maxLines;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  final double? height;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.maxLength,
    required this.maxLines,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.inputFormatters,
    this.height,
    this.padding,
    this.fontSize = 16,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isFocused = false;
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = widget.height ?? 52.0;
    final effectivePadding =
        widget.padding ?? const EdgeInsets.symmetric(horizontal: 16);
    final isSingleLine = widget.obscureText || widget.maxLines == 1;

    if (NavioTheme.isApple) {
      final verticalPadding = isSingleLine ? 0.0 : 12.0;

      return Focus(
        onFocusChange: (focus) => setState(() => isFocused = focus),
        child: AnimatedContainer(
          duration: NavioTheme.normal,
          constraints: BoxConstraints(minHeight: effectiveHeight),
          padding: effectivePadding,
          decoration: NavioTheme.surfaceDecoration(
            focused: isFocused,
            glow: isFocused,
            disabled: !widget.enabled,
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  enabled: widget.enabled,
                  controller: widget.controller,
                  maxLength: widget.maxLength,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  inputFormatters: widget.inputFormatters,
                  obscureText: widget.obscureText && _obscured,
                  textAlignVertical: isSingleLine
                      ? TextAlignVertical.center
                      : TextAlignVertical.top,
                  padding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: verticalPadding,
                  ),
                  placeholder: widget.hintText,
                  placeholderStyle: TextStyle(
                    color: NavioTheme.textMuted(alpha: 0.5),
                    fontFamily: "SF-Pro",
                    fontSize: widget.fontSize,
                  ),
                  style: TextStyle(
                    color: NavioTheme.textPrimary(),
                    fontSize: widget.fontSize,
                    fontFamily: "SF-Pro",
                  ),
                  cursorColor: NavioTheme.textPrimary(alpha: 0.8),
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              if (widget.obscureText)
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: Icon(
                    _obscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    size: 18,
                    color: NavioTheme.textMuted(),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Focus(
      onFocusChange: (focus) => setState(() => isFocused = focus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(minHeight: effectiveHeight),
        padding: effectivePadding,
        decoration: NavioTheme.surfaceDecoration(
          focused: isFocused,
          glow: isFocused,
          disabled: !widget.enabled,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                enabled: widget.enabled,
                maxLength: widget.maxLength,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                obscureText: widget.obscureText && _obscured,
                textAlignVertical: isSingleLine
                    ? TextAlignVertical.center
                    : TextAlignVertical.top,
                style: TextStyle(
                  color: NavioTheme.textPrimary(),
                  fontSize: widget.fontSize,
                  fontFamily: "SF-Pro",
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: isSingleLine
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(vertical: 12),
                  counterText: "",
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: NavioTheme.textMuted(alpha: 0.5),
                    fontSize: widget.fontSize,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (widget.obscureText)
              GestureDetector(
                onTap: () => setState(() => _obscured = !_obscured),
                child: Icon(
                  _obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: NavioTheme.textMuted(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
