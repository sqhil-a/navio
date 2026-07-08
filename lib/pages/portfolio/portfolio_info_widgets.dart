part of 'portfolio_home.dart';

class _EditableInfoField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final void Function(String value) onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;
  final bool compact;

  const _EditableInfoField({
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    required this.onSubmitted,
    this.inputFormatters,
    this.maxLength = 80,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final fieldHeight = compact ? 48.0 : 54.0;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 9 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLabel(label: label, compact: compact),
          SizedBox(height: compact ? 5 : 6),
          CustomTextField(
            controller: controller,
            hintText: hint,
            maxLength: maxLength,
            maxLines: 1,
            height: fieldHeight,
            fontSize: compact ? 14 : 16,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _InfoReadOnlyEditField extends StatelessWidget {
  final String label;
  final String value;
  final String emptyText;
  final String editText;
  final VoidCallback onEdit;
  final bool compact;

  const _InfoReadOnlyEditField({
    required this.label,
    required this.value,
    required this.emptyText,
    required this.editText,
    required this.onEdit,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final rowHeight = compact ? 48.0 : 56.0;
    final buttonHeight = compact ? 36.0 : 40.0;
    final buttonWidth = editText.length <= 4 ? 82.0 : 92.0;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 9 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLabel(label: label, compact: compact),
          SizedBox(height: compact ? 5 : 6),
          Container(
            height: rowHeight,
            padding: const EdgeInsets.fromLTRB(16, 6, 7, 6),
            decoration: NavioTheme.surfaceDecoration(
              radius: NavioTheme.radiusMedium,
              border: false,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value : emptyText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "SF-Pro",
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: hasValue
                          ? NavioTheme.textPrimary()
                          : NavioTheme.textMuted(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                LabelButton(
                  height: buttonHeight,
                  width: buttonWidth,
                  text: editText,
                  enabled: true,
                  onTap: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final String label;
  final bool compact;

  const _InfoLabel({
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: "SF-Pro",
        fontSize: compact ? 11 : 11.5,
        fontWeight: FontWeight.w800,
        color: NavioTheme.textMuted(alpha: 0.48),
      ),
    );
  }
}

class _InfoOptionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final void Function(String value) onSelected;

  const _InfoOptionSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_InfoOptionSheet> createState() => _InfoOptionSheetState();
}

class _InfoOptionSheetState extends State<_InfoOptionSheet> {
  final _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options.where((option) {
      return option.toLowerCase().contains(_query.toLowerCase().trim());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.74,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: NavioTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: NavioTheme.textMuted(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: "New-York",
                      fontSize: 24,
                      color: NavioTheme.textPrimary(),
                    ),
                  ),
                ),
                LabelButton(
                  height: 38,
                  width: 84,
                  text: "Close",
                  enabled: true,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.options.length > 8)
              CustomTextField(
                controller: _searchController,
                hintText: "Search...",
                maxLength: 50,
                maxLines: 1,
                height: 48,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onChanged: (value) => setState(() => _query = value),
              ),
            if (widget.options.length > 8) const SizedBox(height: 10),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No matches found",
                        style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontSize: 14,
                          color: NavioTheme.textMuted(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        final selected = option == widget.selectedValue;

                        return LabelButton(
                          height: 48,
                          width: double.infinity,
                          text: option,
                          icon: selected ? "✓" : null,
                          enabled: true,
                          onTap: () {
                            widget.onSelected(option);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final bool compact;

  const _InfoChip({
    required this.label,
    required this.onRemove,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 6 : 7,
      ),
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
              fontSize: compact ? 11.5 : 12,
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
                size: compact ? 13 : 14,
                color: NavioTheme.textMuted(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
