import 'package:flutter/material.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/services/groq_service.dart';
import 'package:navio/widgets/auto_scale_text.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/custom_text_field.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';
import 'dart:convert';

class CareerFinderPage extends StatefulWidget {
  const CareerFinderPage({super.key});

  @override
  State<CareerFinderPage> createState() => _CareerFinderPageState();
}

class _CareerFinderPageState extends State<CareerFinderPage> {
  final TextEditingController _searchController = TextEditingController();
  final GroqService _groq = GroqService();

  String _searchQuery = "";
  List<String> _recommended = [];
  int _visibleRecommendedCount = 0;
  int _recommendationRevealRun = 0;
  bool _recommendedLoading = false;
  String? _selectedCareer;
  String? _careerDescription;
  bool _descriptionLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _loadRecommended();
  }

  @override
  void dispose() {
    _recommendationRevealRun++;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommended() async {
    final cached = await AppStorage.loadString("cachedRecommended");
    if (cached != null && cached.isNotEmpty) {
      final list = _parseRecommendedCareers(cached);
      if (list.isNotEmpty) {
        _showRecommended(list);
        return;
      }
    }
    await _generateRecommended();
  }

  Future<void> _generateRecommended() async {
    if (!mounted) return;
    setState(() => _recommendedLoading = true);

    final aois = selectedAoiNotifier.value;
    final style = selectedStyleNotifier.value ?? "";
    final stage = stageNotifier.value;
    final allCareers = careerListNotifier.value.join(", ");

    final result = await _groq.sendChat(
      model: "llama-3.1-8b-instant",
      systemPrompt: """
You are a career advisor. Given a user's profile and a list of careers, return the 5 most suitable careers.

Return ONLY a JSON array of exactly 5 career names from the provided list, no explanation, no markdown, no backticks:
["Career One", "Career Two", "Career Three", "Career Four", "Career Five"]

Only return careers from the provided list. Never invent new ones.
""",
      userPrompt:
          """
Areas of interest: ${aois.join(', ')}
Work style: $style
Stage: $stage

Career list: $allCareers

Return the 5 best matching careers as a JSON array.
""",
      maxTokens: 150,
      temperature: 0.3,
    );

    if (result != null) {
      final list = _parseRecommendedCareers(result);
      if (list.isNotEmpty) {
        await AppStorage.saveString("cachedRecommended", jsonEncode(list));
        if (!mounted) return;
        _showRecommended(list);
        return;
      }
    }

    final fallback = _fallbackRecommendedCareers();
    if (mounted) {
      _showRecommended(fallback);
    }
  }

  void _showRecommended(List<String> careers) {
    final nextRecommendations = careers.take(5).toList();
    final run = ++_recommendationRevealRun;

    setState(() {
      _recommended = nextRecommendations;
      _recommendedLoading = false;
      _visibleRecommendedCount = 0;
    });

    _revealRecommended(run, nextRecommendations.length);
  }

  Future<void> _revealRecommended(int run, int count) async {
    for (var index = 0; index < count; index++) {
      await Future.delayed(Duration(milliseconds: index == 0 ? 90 : 140));
      if (!mounted || run != _recommendationRevealRun) return;

      setState(() => _visibleRecommendedCount = index + 1);
    }
  }

  List<String> _parseRecommendedCareers(String raw) {
    Object? decoded;

    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start == -1 || end <= start) return const [];

      try {
        decoded = jsonDecode(raw.substring(start, end + 1));
      } catch (_) {
        return const [];
      }
    }

    if (decoded is! List) return const [];

    final allowed = careerListNotifier.value.toSet();
    final matches = <String>[];
    for (final item in decoded) {
      final career = item.toString().trim();
      if (allowed.contains(career) && !matches.contains(career)) {
        matches.add(career);
      }
      if (matches.length == 5) return matches;
    }

    for (final career in _fallbackRecommendedCareers()) {
      if (!matches.contains(career)) matches.add(career);
      if (matches.length == 5) break;
    }

    return matches;
  }

  List<String> _fallbackRecommendedCareers() {
    final selectedAois = selectedAoiNotifier.value;
    final style = selectedStyleNotifier.value ?? "";
    final allowed = careerListNotifier.value.toSet();
    final recommendations = <String>[];

    void addAll(List<String> careers) {
      for (final career in careers) {
        if (allowed.contains(career) && !recommendations.contains(career)) {
          recommendations.add(career);
        }
        if (recommendations.length == 5) return;
      }
    }

    const byInterest = {
      "Technology": [
        "Software Engineering",
        "Computer Science",
        "Information Technology",
        "Web Development",
        "Cybersecurity",
      ],
      "Engineering": [
        "Mechanical Engineering",
        "Electrical Engineering",
        "Civil Engineering",
        "Robotics",
        "Aerospace Engineering",
      ],
      "Data & Analytics": [
        "Data Science",
        "Statistics",
        "Machine Learning",
        "Business Administration",
        "Economics",
      ],
      "Artificial Intelligence": [
        "Machine Learning",
        "Data Science",
        "Computer Science",
        "Robotics",
        "Software Engineering",
      ],
      "Healthcare": [
        "Medicine",
        "Nursing",
        "Health Administration",
        "Public Health",
        "Physical Therapy",
      ],
      "Business": [
        "Business Administration",
        "Product Management",
        "Marketing",
        "Finance",
        "Entrepreneurship",
      ],
      "Design": [
        "UX Design",
        "Graphic Design",
        "Industrial Design",
        "Interior Design",
        "Product Management",
      ],
      "Education": [
        "Education",
        "Special Education",
        "Early Childhood Education",
        "Mentoring",
        "Psychology",
      ],
      "Law": [
        "Law",
        "Public Policy",
        "Criminal Justice",
        "Political Science",
        "Environmental Law",
      ],
    };

    const byStyle = {
      "Creating": [
        "UX Design",
        "Graphic Design",
        "Animation",
        "Web Development",
      ],
      "Supporting": ["Nursing", "Social Work", "Psychology", "Education"],
      "Problem Solving": [
        "Software Engineering",
        "Data Science",
        "Engineering",
        "Cybersecurity",
      ],
      "Leading": [
        "Management",
        "Product Management",
        "Business Administration",
        "Entrepreneurship",
      ],
      "Researching": ["Data Science", "Biology", "Psychology", "Economics"],
      "Innovation": [
        "Entrepreneurship",
        "Product Management",
        "Robotics",
        "Software Engineering",
      ],
    };

    for (final aoi in selectedAois) {
      addAll(byInterest[aoi] ?? const []);
    }
    addAll(byStyle[style] ?? const []);
    addAll(const [
      "Software Engineering",
      "Data Science",
      "UX Design",
      "Marketing",
      "Business Administration",
    ]);

    return recommendations.take(5).toList();
  }

  Future<void> _loadCareerDescription(String career) async {
    setState(() {
      _selectedCareer = career;
      _careerDescription = null;
      _descriptionLoading = true;
    });

    final cacheKey = "careerDesc_${career.replaceAll(' ', '_')}";
    final cached = await AppStorage.loadString(cacheKey);
    if (cached != null && cached.isNotEmpty && mounted) {
      setState(() {
        _careerDescription = cached;
        _descriptionLoading = false;
      });
      return;
    }

    final result = await _groq.sendChat(
      model: "llama-3.1-8b-instant",
      systemPrompt:
          "You are a career advisor. Give a concise 2-3 sentence overview of a career: what it involves, who it suits, and typical work environment. No headers, no bullet points, plain text only.",
      userPrompt: "Describe the career: $career",
      maxTokens: 150,
      temperature: 0.3,
    );

    if (mounted) {
      final desc = result ?? "No description available.";
      await AppStorage.saveString(cacheKey, desc);
      setState(() {
        _careerDescription = desc;
        _descriptionLoading = false;
      });
    }
  }

  List<String> get _filteredCareers {
    final all = careerListNotifier.value;
    if (_searchQuery.isEmpty) return all;
    return all.where((c) => c.toLowerCase().contains(_searchQuery)).toList();
  }

  Future<void> _setCareer() async {
    if (_selectedCareer == null) return;

    final career = _selectedCareer!;
    await AppStorage.saveString("career", career);
    await AppStorage.saveString("careerTitle", "");
    await AppStorage.saveString("cachedPlan", "");
    await AppStorage.saveString("cachedResources", "");
    await AppStorage.saveString("cachedRecommended", "");
    await AppStorage.saveString("portfolioTodos", "");
    await AppStorage.saveString("portfolioTodosCareer", "");
    await AppStorage.saveString("portfolioSkills", "");
    await AppStorage.saveString("portfolioSkillsCareer", "");

    careerTitleNotifier.value = "";
    careerNotifier.value = career;
    showPlanNotifier.value = false;
    chatResetNotifier.value++;
    selectedNavIndexNotifier.value = 1;

    if (!mounted) return;
    setState(() {
      _selectedCareer = null;
      _careerDescription = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacing(height: 40),
              CustomTextField(
                controller: _searchController,
                hintText: "Search careers...",
                maxLines: 1,
                maxLength: 50,
              ),
              const Spacing(height: 20),
              Expanded(
                child: _selectedCareer != null
                    ? _buildDetailView()
                    : _buildListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final filtered = _filteredCareers;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (_searchQuery.isEmpty) ...[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recommended for you",
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: NavioTheme.textMuted(alpha: 0.42),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacing(height: 10),
                if (_recommendedLoading)
                  _buildRecommendationLoading()
                else
                  _buildRecommendedCareers(),
                const Spacing(height: 24),
                Text(
                  "All careers",
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: NavioTheme.textMuted(alpha: 0.42),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacing(height: 10),
              ],
            ),
          ),
        ],
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCareerTile(filtered[index]),
            childCount: filtered.length,
          ),
        ),
      ],
    );
  }

  Widget _buildCareerTile(String career) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LabelButton(
        height: 52,
        width: double.infinity,
        text: career,

        enabled: true,
        onTap: () => _loadCareerDescription(career),
      ),
    );
  }

  Widget _buildRecommendationLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoadingStep("Reading your interests", true),
          _buildLoadingStep("Matching career patterns", false),
          _buildLoadingStep("Ranking best fits", false),
        ],
      ),
    );
  }

  Widget _buildLoadingStep(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: NavioTheme.normal,
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? NavioTheme.accent
                  : NavioTheme.textMuted(alpha: 0.16),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 13,
              color: active
                  ? NavioTheme.textSecondary(alpha: 0.68)
                  : NavioTheme.textMuted(alpha: 0.34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCareers() {
    if (_recommended.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < _recommended.length; i++)
          _RecommendedCareerStep(
            index: i,
            career: _recommended[i],
            isVisible: i < _visibleRecommendedCount,
            onTap: () => _loadCareerDescription(_recommended[i]),
          ),
      ],
    );
  }

  Widget _buildDetailView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedCareer = null;
                  _careerDescription = null;
                }),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16,
                      color: NavioTheme.textSecondary(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Back",
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: 14,
                        color: NavioTheme.textSecondary(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: compact ? 14 : 20),

            // Career name
            SizedBox(
              height: compact ? 66 : 78,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoScaleText(
                  _selectedCareer ?? "",
                  maxLines: 2,
                  minFontSize: 18,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: "New-York",
                    fontSize: compact ? 25 : 28,
                    color: NavioTheme.textPrimary(),
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 10 : 16),

            // Description card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(compact ? 14 : 16),
                decoration: NavioTheme.surfaceDecoration(
                  active: true,
                  glow: true,
                  radius: NavioTheme.radiusLarge,
                ),
                child: _CareerDescriptionText(
                  text: _descriptionLoading
                      ? "Loading..."
                      : (_careerDescription ?? ""),
                  loading: _descriptionLoading,
                ),
              ),
            ),
            SizedBox(height: compact ? 12 : 20),

            // Set career button
            ValueListenableBuilder<String>(
              valueListenable: careerNotifier,
              builder: (context, currentCareer, _) {
                final isSet = currentCareer == _selectedCareer;
                return LabelButton(
                  height: 52,
                  width: double.infinity,
                  text: isSet ? "Current career" : "Set as my career",
                  enabled: !isSet,
                  onTap: isSet ? null : _setCareer,
                );
              },
            ),
            SizedBox(height: compact ? 24 : 32),
          ],
        );
      },
    );
  }
}

class _CareerDescriptionText extends StatelessWidget {
  final String text;
  final bool loading;

  const _CareerDescriptionText({required this.text, required this.loading});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final color = loading
            ? NavioTheme.textMuted()
            : NavioTheme.textSecondary(alpha: 0.72);
        var size = 14.0;

        for (var candidate = 14.0; candidate >= 9.0; candidate -= 0.4) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: candidate,
                height: 1.55,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          size = candidate;
          if (painter.height <= constraints.maxHeight) break;
        }

        return Text(
          text,
          style: TextStyle(
            fontFamily: "SF-Pro",
            fontSize: size,
            color: color,
            height: 1.55,
          ),
        );
      },
    );
  }
}

class _RecommendedCareerStep extends StatefulWidget {
  final int index;
  final String career;
  final bool isVisible;
  final VoidCallback onTap;

  const _RecommendedCareerStep({
    required this.index,
    required this.career,
    required this.isVisible,
    required this.onTap,
  });

  @override
  State<_RecommendedCareerStep> createState() => _RecommendedCareerStepState();
}

class _RecommendedCareerStepState extends State<_RecommendedCareerStep> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: NavioTheme.slow,
      curve: Curves.easeOutCubic,
      child: widget.isVisible
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hovered = true),
                  onExit: (_) => setState(() {
                    _hovered = false;
                    _pressed = false;
                  }),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    onTapDown: (_) => setState(() => _pressed = true),
                    onTapUp: (_) => setState(() => _pressed = false),
                    onTapCancel: () => setState(() => _pressed = false),
                    child: AnimatedScale(
                      scale: _pressed ? 0.975 : 1,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: NavioTheme.normal,
                        curve: Curves.easeOutCubic,
                        constraints: const BoxConstraints(minHeight: 58),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: NavioTheme.surfaceDecoration(
                          active: true,
                          hovered: _hovered,
                          pressed: _pressed,
                          glow: _hovered,
                        ),
                        child: Row(
                          children: [
                            _buildMarker(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Match ${(widget.index + 1).toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontFamily: "SF-Pro",
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: NavioTheme.textMuted(
                                        alpha: _pressed ? 0.28 : 0.42,
                                      ),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  AutoScaleText(
                                    widget.career,
                                    maxLines: 1,
                                    minFontSize: 10,
                                    style: TextStyle(
                                      fontFamily: "SF-Pro",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: NavioTheme.textPrimary(
                                        alpha: _pressed ? 0.62 : 0.95,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedSlide(
                              offset: _pressed
                                  ? const Offset(0.12, 0)
                                  : _hovered
                                  ? const Offset(0.06, 0)
                                  : Offset.zero,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: NavioTheme.textMuted(
                                  alpha: _hovered ? 0.62 : 0.42,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMarker() {
    return AnimatedContainer(
      duration: NavioTheme.normal,
      curve: Curves.easeOutCubic,
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: NavioTheme.surfaceColor(
          active: true,
        ).withValues(alpha: _hovered ? 0.9 : 0.72),
        border: Border.all(
          color: NavioTheme.borderColor(
            active: true,
          ).withValues(alpha: _hovered ? 0.95 : 0.72),
          width: NavioTheme.borderWidth,
        ),
      ),
      child: Text(
        "${widget.index + 1}",
        style: const TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: NavioTheme.accent,
        ),
      ),
    );
  }
}
