part of 'portfolio_home.dart';

class _EditableInfoField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final void Function(String value) onSubmitted;

  const _EditableInfoField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: NavioTheme.textMuted(alpha: 0.48),
            ),
          ),
          const SizedBox(height: 8),
          _InfoInlineInput(
            controller: controller,
            hint: hint,
            onSubmitted: onSubmitted,
            onEditingComplete: () => onSubmitted(controller.text),
          ),
        ],
      ),
    );
  }
}

class _InfoInlineInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final void Function(String value) onSubmitted;
  final VoidCallback? onEditingComplete;

  const _InfoInlineInput({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.enabled = true,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: NavioTheme.surfaceDecoration(
        radius: NavioTheme.radiusMedium,
        disabled: !enabled,
        border: false,
      ),
      child: TextField(
        enabled: enabled,
        controller: controller,
        maxLength: 80,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        style: TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 14,
          color: NavioTheme.textPrimary(),
        ),
        decoration: InputDecoration(
          counterText: "",
          hintText: hint,
          hintStyle: TextStyle(color: NavioTheme.textMuted(alpha: 0.42)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _InfoChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: NavioTheme.surfaceDecoration(
        active: true,
        radius: NavioTheme.radiusSmall,
        border: false,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AutoScaleText(
            label,
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NavioTheme.textSecondary(alpha: 0.78),
            ),
          ),
          const SizedBox(width: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: NavioTheme.textMuted(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

