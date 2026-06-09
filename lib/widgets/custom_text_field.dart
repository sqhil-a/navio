import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navio/widgets/navio_theme.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final int maxLength;
  final int maxLines;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.maxLength,
    required this.maxLines,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isFocused = false;
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    if (NavioTheme.isApple) {
      return Focus(
        onFocusChange: (focus) => setState(() => isFocused = focus),
        child: AnimatedContainer(
          duration: NavioTheme.normal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: NavioTheme.surfaceDecoration(
            focused: isFocused,
            glow: isFocused,
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: widget.controller,
                  maxLength: widget.maxLength,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText && _obscured,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  placeholder: widget.hintText,
                  placeholderStyle: TextStyle(
                    color: NavioTheme.textMuted(alpha: 0.5),
                    fontFamily: "SF-Pro",
                  ),
                  style: TextStyle(
                    color: NavioTheme.textPrimary(),
                    fontSize: 16,
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
      onFocusChange: (focus) {
        setState(() {
          isFocused = focus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: NavioTheme.surfaceDecoration(
          focused: isFocused,
          glow: isFocused,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                maxLength: widget.maxLength,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                onChanged: widget.onChanged,
                controller: widget.controller,
                obscureText: widget.obscureText && _obscured,
                style: TextStyle(
                  color: NavioTheme.textPrimary(),
                  fontSize: 16,
                  fontFamily: "SF-Pro",
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: NavioTheme.textMuted(alpha: 0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),

            // Show/hide toggle for password fields
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
