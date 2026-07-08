part of 'portfolio_home.dart';

class _ResumeField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLength;
  final int maxLines;

  const _ResumeField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
          CustomTextField(
            hintText: hint,
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}

class _ResumeReportHeading extends StatelessWidget {
  final String text;

  const _ResumeReportHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: "SF-Pro",
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: NavioTheme.textPrimary(alpha: 0.82),
      ),
    );
  }
}

class _ResumeReportList extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ResumeReportList({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final cleanItems = items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (cleanItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResumeReportHeading(title),
          const SizedBox(height: 8),
          ...cleanItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 7, right: 8),
                    decoration: BoxDecoration(
                      color: NavioTheme.textSecondary(alpha: 0.68),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: 12.5,
                        color: NavioTheme.textSecondary(alpha: 0.68),
                        height: 1.38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeRewriteLine extends StatelessWidget {
  final String label;
  final String value;

  const _ResumeRewriteLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 12.5,
          color: NavioTheme.textSecondary(alpha: 0.68),
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: NavioTheme.textPrimary(alpha: 0.82),
            ),
          ),
          TextSpan(text: value.trim().isEmpty ? "Not provided" : value.trim()),
        ],
      ),
    );
  }
}

class _ResumeEntrySectionEditor extends StatelessWidget {
  final String title;
  final String emptyText;
  final String addText;
  final List<_ResumeEntry> entries;
  final String titleHint;
  final String organizationHint;
  final String dateHint;
  final String detailsHint;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index, _ResumeEntry entry) onChanged;

  const _ResumeEntrySectionEditor({
    required this.title,
    required this.emptyText,
    required this.addText,
    required this.entries,
    required this.titleHint,
    required this.organizationHint,
    required this.dateHint,
    required this.detailsHint,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: NavioTheme.textMuted(alpha: 0.48),
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onAdd,
                  child: Text(
                    addText,
                    style: TextStyle(
                      fontFamily: "SF-Pro",
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: NavioTheme.textSecondary(alpha: 0.72),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: NavioTheme.surfaceDecoration(
                radius: NavioTheme.radiusMedium,
                border: false,
              ),
              child: Text(
                emptyText,
                style: TextStyle(
                  fontFamily: "SF-Pro",
                  fontSize: 13,
                  color: NavioTheme.textMuted(alpha: 0.42),
                ),
              ),
            )
          else
            AnimatedSize(
              duration: NavioTheme.normal,
              curve: Curves.easeOutCubic,
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _ResumeEntryEditor(
                      index: i,
                      entry: entries[i],
                      titleHint: titleHint,
                      organizationHint: organizationHint,
                      dateHint: dateHint,
                      detailsHint: detailsHint,
                      onRemove: () => onRemove(i),
                      onChanged: (entry) => onChanged(i, entry),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ResumeEntryEditor extends StatelessWidget {
  final int index;
  final _ResumeEntry entry;
  final String titleHint;
  final String organizationHint;
  final String dateHint;
  final String detailsHint;
  final VoidCallback onRemove;
  final void Function(_ResumeEntry entry) onChanged;

  const _ResumeEntryEditor({
    required this.index,
    required this.entry,
    required this.titleHint,
    required this.organizationHint,
    required this.dateHint,
    required this.detailsHint,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: NavioTheme.surfaceDecoration(
        radius: NavioTheme.radiusMedium,
        border: false,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Entry ${index + 1}",
                style: TextStyle(
                  fontFamily: "SF-Pro",
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: NavioTheme.textMuted(alpha: 0.46),
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: NavioTheme.textMuted(alpha: 0.48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ResumeEntryInput(
            value: entry.title,
            hint: titleHint,
            onChanged: (value) => onChanged(entry.copyWith(title: value)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ResumeEntryInput(
                  value: entry.organization,
                  hint: organizationHint,
                  onChanged: (value) =>
                      onChanged(entry.copyWith(organization: value)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: _ResumeEntryInput(
                  value: entry.dates,
                  hint: dateHint,
                  onChanged: (value) => onChanged(entry.copyWith(dates: value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ResumeEntryInput(
            value: entry.details,
            hint: detailsHint,
            maxLines: 3,
            onChanged: (value) => onChanged(entry.copyWith(details: value)),
          ),
        ],
      ),
    );
  }
}

class _ResumeEntryInput extends StatelessWidget {
  final String value;
  final String hint;
  final int maxLines;
  final void Function(String value) onChanged;

  const _ResumeEntryInput({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: "SF-Pro",
        fontSize: 13,
        color: NavioTheme.textPrimary(alpha: 0.9),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: NavioTheme.textMuted(alpha: 0.38)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NavioTheme.radiusSmall),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ResumePreviewSheet extends StatelessWidget {
  final _ResumeDraft draft;

  const _ResumePreviewSheet({required this.draft});

  List<String> _lines(String value) {
    return value
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final contact = [
      draft.phone,
      draft.email,
      draft.location,
    ].where((value) => value.trim().isNotEmpty).toList();
    final skills = _lines(draft.skills);
    final education = _lines(draft.education);
    final languages = _lines(draft.languages);
    final references = _lines(draft.references);

    return Container(
      width: 420,
      height: 594,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F4),
        borderRadius: BorderRadius.circular(NavioTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: "SF-Pro",
          color: Color(0xFF333335),
          height: 1.38,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDEC),
                borderRadius: BorderRadius.circular(NavioTheme.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        draft.name.isEmpty ? "Your Name" : draft.name,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontFamily: "SF-Pro",
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: Color(0xFF333335),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 16,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        draft.headline.isEmpty ? "student" : draft.headline,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.15,
                          color: const Color(0xFF55555A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333335),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 13),
                  const _ResumePreviewHeading("Summary"),
                  AutoScaleText(
                    draft.summary.isEmpty
                        ? "Add a short summary to describe your strengths, direction, and the kind of work you want to do."
                        : draft.summary,
                    maxLines: 2,
                    minFontSize: 8,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 10.4,
                      color: const Color(0xFF55555A),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const designHeight = 500.0;
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: designHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ResumePreviewSection(
                                  title: "Contact",
                                  items: contact,
                                  emptyText: "Add email, phone, or location.",
                                  maxItems: 3,
                                  itemMaxLines: 2,
                                  minFontSize: 7.8,
                                ),
                                _ResumePreviewSection(
                                  title: "Skills",
                                  items: skills,
                                  emptyText: "Add skills one per line.",
                                  maxItems: 5,
                                  itemMaxLines: 1,
                                  minFontSize: 8.2,
                                ),
                                _ResumePreviewSection(
                                  title: "Education",
                                  items: education,
                                  emptyText: "Add your school or program.",
                                  maxItems: 2,
                                  itemMaxLines: 2,
                                  minFontSize: 8,
                                ),
                                _ResumePreviewSection(
                                  title: "Languages",
                                  items: languages,
                                  emptyText: "Add languages one per line.",
                                  maxItems: 4,
                                  itemMaxLines: 1,
                                  minFontSize: 8.2,
                                  showMoreCount: false,
                                ),
                                if (references.isNotEmpty)
                                  _ResumePreviewSection(
                                    title: "References",
                                    items: references,
                                    emptyText: "Available on request.",
                                    maxItems: 1,
                                    itemMaxLines: 2,
                                    minFontSize: 7.8,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ResumePreviewEntrySection(
                                  title: "Experience",
                                  entries: draft.experienceEntries,
                                  maxItems: 3,
                                ),
                                _ResumePreviewEntrySection(
                                  title: "Achievements",
                                  entries: draft.achievementEntries,
                                  maxItems: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _ResumePreviewHeading extends StatelessWidget {
  final String title;

  const _ResumePreviewHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        "${title.toUpperCase()} :",
        style: const TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          color: Color(0xFF333335),
        ),
      ),
    );
  }
}

class _ResumePreviewSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final String emptyText;
  final int maxItems;
  final int itemMaxLines;
  final double minFontSize;
  final bool showMoreCount;

  const _ResumePreviewSection({
    required this.title,
    required this.items,
    required this.emptyText,
    this.maxItems = 4,
    this.itemMaxLines = 1,
    this.minFontSize = 8,
    this.showMoreCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(maxItems).toList();
    final hiddenCount = items.length - visibleItems.length;

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResumePreviewHeading(title),
          ...visibleItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3.5,
                    height: 3.5,
                    margin: const EdgeInsets.only(top: 5.5, right: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333335),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: _ResumePreviewLine(
                      text: item,
                      maxLines: itemMaxLines,
                      fontSize: 10.0,
                      minFontSize: minFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hiddenCount > 0 && showMoreCount)
            Text(
              "+ $hiddenCount more",
              style: const TextStyle(fontSize: 8.8, color: Color(0xFF77777B)),
            ),
        ],
      ),
    );
  }
}

class _ResumePreviewEntrySection extends StatelessWidget {
  final String title;
  final List<_ResumeEntry> entries;
  final int maxItems;

  const _ResumePreviewEntrySection({
    required this.title,
    required this.entries,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visibleEntries = entries
        .where((entry) => entry.hasContent)
        .take(maxItems)
        .toList();
    if (visibleEntries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResumePreviewHeading(title),
          ...visibleEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ResumePreviewLine(
                          text: entry.title.isEmpty ? "Untitled" : entry.title,
                          maxLines: 1,
                          fontSize: 10.7,
                          minFontSize: 8.2,
                          color: const Color(0xFF333335),
                          weight: FontWeight.w800,
                        ),
                      ),
                      if (entry.dates.trim().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 56,
                          child: _ResumePreviewLine(
                            text: entry.dates,
                            maxLines: 1,
                            fontSize: 9.4,
                            minFontSize: 7.2,
                            color: const Color(0xFF333335),
                            weight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (entry.organization.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _ResumePreviewLine(
                        text: entry.organization,
                        maxLines: 1,
                        fontSize: 9.9,
                        minFontSize: 7.8,
                        color: const Color(0xFF66666A),
                        weight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 4),
                  ...entry
                      .detailLines()
                      .take(2)
                      .map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.only(
                                  top: 5.5,
                                  right: 6,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF333335),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: _ResumePreviewLine(
                                  text: detail,
                                  maxLines: 2,
                                  fontSize: 9.8,
                                  minFontSize: 7.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumePreviewLine extends StatelessWidget {
  final String text;
  final int maxLines;
  final double fontSize;
  final double minFontSize;
  final Color color;
  final FontWeight weight;

  const _ResumePreviewLine({
    required this.text,
    required this.maxLines,
    required this.fontSize,
    required this.minFontSize,
    this.color = const Color(0xFF55555A),
    this.weight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (maxLines <= 1) {
      return SizedBox(
        height: fontSize * 1.26,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            clean,
            maxLines: 1,
            softWrap: false,
            style: _style(fontSize),
          ),
        ),
      );
    }

    return AutoScaleText(
      clean,
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: TextOverflow.clip,
      softWrap: true,
      style: _style(math.max(minFontSize, fontSize - 0.4)),
    );
  }

  TextStyle _style(double size) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: 1.2,
    );
  }
}
