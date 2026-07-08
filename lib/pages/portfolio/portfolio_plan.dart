import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lottie/lottie.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/pages/portfolio/plan_service.dart';
import 'package:navio/pages/portfolio/roadmap_step.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/custom_text_field.dart';
import 'package:navio/widgets/line_seperator.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navio/widgets/buttons/send_button.dart';

class PortfolioPlan extends StatefulWidget {
  const PortfolioPlan({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<PortfolioPlan> createState() => _PortfolioPlanState();
}

class _PortfolioPlanState extends State<PortfolioPlan> {
  static const _editCooldownUntilKey = "portfolioPlanEditCooldownUntil";
  final _service = PlanService();
  final _editController = TextEditingController();

  List<Map<String, String>> _steps = [];
  List<Map<String, String>> _resources = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isApplyingEdit = false;
  bool _hideEditSendButton = false;
  bool _resourcesExpanded = false;
  bool _resourcesPressed = false;
  bool _resourcesLoading = false;
  String? _error;
  int _visibleRoadmapCount = 0;
  int _roadmapRevealRun = 0;
  int _lastResourcesRequest = 0;
  int? _expandedIndex;
  Timer? _editCooldownTimer;

  @override
  void initState() {
    super.initState();
    roadmapResourcesRequestNotifier.addListener(_onResourcesRequest);
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onResourcesRequest());
    _restoreEditCooldown();
  }

  @override
  void dispose() {
    _roadmapRevealRun++;
    roadmapResourcesRequestNotifier.removeListener(_onResourcesRequest);
    _editCooldownTimer?.cancel();
    _editController.dispose();
    super.dispose();
  }

  void _onResourcesRequest() {
    final request = roadmapResourcesRequestNotifier.value;
    if (!mounted || request == _lastResourcesRequest || request == 0) return;

    _lastResourcesRequest = request;
    if (careerNotifier.value.trim().isEmpty) return;

    setState(() {
      _resourcesExpanded = true;
      _expandedIndex = null;
    });
    _loadResources();
  }

  Future<void> _load() async {
    if (careerNotifier.value.trim().isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final steps = await _service.loadOrGenerate();
      if (mounted) {
        _showSteps(steps);
        Haptics.vibrate(HapticsType.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Couldn't generate your plan.\nTap to retry.";
          _isLoading = false;
        });
        Haptics.vibrate(HapticsType.error);
      }
    }
  }

  Future<void> _applyEdit() async {
    final instruction = _editController.text.trim();
    if (instruction.isEmpty || _isApplyingEdit || _hideEditSendButton) return;

    setState(() {
      _isApplyingEdit = true;
      _error = null;
    });

    try {
      final steps = await _service.edit(instruction);
      if (mounted) {
        setState(() {
          _isApplyingEdit = false;
          _isEditing = false;
          _expandedIndex = null;
          _editController.clear();
        });
        _showSteps(steps);
        Haptics.vibrate(HapticsType.success);
      }
      await _startEditCooldown();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Couldn't apply edit. Tap to retry.";
          _isApplyingEdit = false;
        });
        Haptics.vibrate(HapticsType.error);
      }
    }
  }

  Future<void> _loadResources() async {
    if (_resources.isNotEmpty) return;

    setState(() => _resourcesLoading = true);

    try {
      final resources = await _service.loadOrGenerateResources();
      if (mounted) {
        setState(() {
          _resources = resources;
          _resourcesLoading = false;
        });
        Haptics.vibrate(HapticsType.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _resourcesLoading = false);
        Haptics.vibrate(HapticsType.error);
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) _editController.clear();
    });
  }

  Future<void> _restoreEditCooldown() async {
    final raw = await AppStorage.loadString(_editCooldownUntilKey);

    if (raw == null || raw.trim().isEmpty) {
      if (mounted && _hideEditSendButton) {
        setState(() => _hideEditSendButton = false);
      }
      return;
    }

    final cooldownUntilMs = int.tryParse(raw);
    if (cooldownUntilMs == null) {
      await AppStorage.saveString(_editCooldownUntilKey, "");
      return;
    }

    final remainingMs = cooldownUntilMs - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) {
      await AppStorage.saveString(_editCooldownUntilKey, "");
      if (mounted && _hideEditSendButton) {
        setState(() => _hideEditSendButton = false);
      }
      return;
    }

    _editCooldownTimer?.cancel();
    if (mounted) {
      setState(() => _hideEditSendButton = true);
    }

    _editCooldownTimer = Timer(Duration(milliseconds: remainingMs), () async {
      await AppStorage.saveString(_editCooldownUntilKey, "");
      if (!mounted) return;
      setState(() => _hideEditSendButton = false);
    });
  }

  Future<void> _startEditCooldown() async {
    final cooldownUntilMs = DateTime.now()
        .add(const Duration(seconds: 5))
        .millisecondsSinceEpoch;

    await AppStorage.saveString(
      _editCooldownUntilKey,
      cooldownUntilMs.toString(),
    );

    _editCooldownTimer?.cancel();
    if (mounted) {
      setState(() => _hideEditSendButton = true);
    }

    _editCooldownTimer = Timer(const Duration(seconds: 5), () async {
      await AppStorage.saveString(_editCooldownUntilKey, "");
      if (!mounted) return;
      setState(() => _hideEditSendButton = false);
    });
  }

  void _showSteps(List<Map<String, String>> steps) {
    final run = ++_roadmapRevealRun;

    setState(() {
      _steps = steps;
      _isLoading = false;
      _visibleRoadmapCount = 0;
    });

    _revealRoadmap(run, steps.length + 1);
  }

  Future<void> _revealRoadmap(int run, int count) async {
    for (var index = 0; index < count; index++) {
      await Future.delayed(Duration(milliseconds: index == 0 ? 90 : 130));
      if (!mounted || run != _roadmapRevealRun) return;

      setState(() => _visibleRoadmapCount = index + 1);
    }
  }

  void _toggleStep(int index) {
    Haptics.vibrate(HapticsType.soft);

    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
      if (_expandedIndex != null) _resourcesExpanded = false;
    });
  }

  void _toggleResources() {
    Haptics.vibrate(HapticsType.soft);

    setState(() {
      _resourcesExpanded = !_resourcesExpanded;
      if (_resourcesExpanded) _expandedIndex = null;
    });

    if (_resourcesExpanded) _loadResources();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await _completeResourceTodo();
      roadmapResourceOpenedNotifier.value++;
    }
  }

  Future<void> _completeResourceTodo() async {
    const todoCacheKey = "portfolioTodos";
    final raw = await AppStorage.loadString(todoCacheKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final items = jsonDecode(raw);
      if (items is! List) return;

      var changed = false;
      final updated = items.map((item) {
        if (item is! Map) return item;

        final title = item['title']?.toString().toLowerCase() ?? "";
        final kind = item['kind']?.toString() ?? "";
        final isResourceTodo =
            kind == "resources" ||
            title.contains("open resources") ||
            title.contains("save one useful link");

        if (isResourceTodo && item['isDone'] != true) {
          changed = true;
          return {...item, 'kind': "resources", 'isDone': true};
        }

        return item;
      }).toList();

      if (changed) {
        await AppStorage.saveString(todoCacheKey, jsonEncode(updated));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: careerNotifier,
      builder: (context, career, _) {
        final hasCareer = career.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(showEdit: hasCareer),
            if (hasCareer) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: _isEditing ? _buildEditInput() : const SizedBox.shrink(),
              ),
              const Spacing(height: 20),
              Expanded(child: _buildBody()),
            ] else
              Expanded(child: _buildCareerRequiredState()),
          ],
        );
      },
    );
  }

  Widget _buildHeader({bool showEdit = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onBack,
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
            const Spacer(),
            if (showEdit && !_isLoading)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _toggleEdit,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isEditing ? Icons.edit_off_rounded : Icons.edit_rounded,
                      key: ValueKey(_isEditing),
                      size: 22,
                      color: _isEditing
                          ? NavioTheme.accent
                          : NavioTheme.textSecondary(),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Spacing(height: 22),
        const Text("Roadmap", style: TextStyle(fontSize: 30)),
        const Spacing(height: 24),
        const LineSeparator(),
        const Spacing(height: 22),
      ],
    );
  }

  Widget _buildCareerRequiredState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose a career first",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "New-York",
                fontSize: 24,
                color: NavioTheme.textPrimary(alpha: 0.86),
              ),
            ),
            const Spacing(height: 10),
            Text(
              "Your roadmap is generated from the career you want to explore.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 13,
                color: NavioTheme.textMuted(alpha: 0.46),
                height: 1.5,
              ),
            ),
            const Spacing(height: 24),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: LabelButton(
                  height: 56,
                  width: double.infinity,
                  text: "Open Career Finder",
                  enabled: true,
                  centerText: true,
                  onTap: () {
                    showPlanNotifier.value = false;
                    selectedNavIndexNotifier.value = 0;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CustomTextField(
              controller: _editController,
              hintText: "Edit",
              maxLines: 2,
              maxLength: 150,
            ),
          ),
          const SizedBox(width: 10),

          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _editController,
            builder: (context, value, child) {
              final canSend =
                  value.text.trim().isNotEmpty &&
                  !_isApplyingEdit &&
                  !_hideEditSendButton;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );

                  return FadeTransition(
                    opacity: curved,
                    child: SizeTransition(
                      sizeFactor: curved,
                      axis: Axis.horizontal,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1,
                        ).animate(curved),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _hideEditSendButton
                    ? const SizedBox(
                        key: ValueKey("plan-edit-send-hidden"),
                        width: 0,
                        height: 44,
                      )
                    : SendButton(
                        key: const ValueKey("plan-edit-send-visible"),
                        isLoading: _isApplyingEdit,
                        enabled: canSend,
                        onTap: _applyEdit,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    return _buildRoadmap();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 100,
            height: 100,
          ),
          const Spacing(height: 16),
          Text(
            "Building your roadmap...",
            style: TextStyle(
              color: NavioTheme.textSecondary(alpha: 0.58),
              fontFamily: "SF-Pro",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: GestureDetector(
        onTap: _load,
        child: Text(
          _error!,
          style: TextStyle(
            color: NavioTheme.textSecondary(alpha: 0.58),
            fontFamily: "SF-Pro",
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRoadmap() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const Spacing(height: 20),
          for (int i = 0; i < _steps.length; i++)
            _RoadmapRevealItem(
              isVisible: i < _visibleRoadmapCount,
              child: RoadmapStep(
                number: i + 1,
                title: _steps[i]['title'] ?? "",
                description: _steps[i]['description'] ?? "",
                isLast: i == _steps.length - 1,
                isExpanded: _expandedIndex == i,
                onTap: () => _toggleStep(i),
              ),
            ),
          const Spacing(height: 40),
          _RoadmapRevealItem(
            isVisible: _visibleRoadmapCount > _steps.length,
            child: _buildResourcesCard(),
          ),
          const Spacing(height: 140),
        ],
      ),
    );
  }

  Widget _buildResourcesCard() {
    return GestureDetector(
      onTap: _toggleResources,
      onTapDown: (_) => setState(() => _resourcesPressed = true),
      onTapUp: (_) => setState(() => _resourcesPressed = false),
      onTapCancel: () => setState(() => _resourcesPressed = false),
      child: AnimatedScale(
        scale: _resourcesPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: NavioTheme.surfaceDecoration(
              active: _resourcesExpanded,
              pressed: _resourcesPressed,
              glow: _resourcesExpanded,
              radius: NavioTheme.radiusLarge,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Resources",
                        style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _resourcesExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: NavioTheme.textMuted(),
                      ),
                    ),
                  ],
                ),

                // AnimatedSize makes the content slide open/close
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: _resourcesExpanded
                      ? GestureDetector(
                          // absorbs taps so resource links don't bubble up
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _resourcesLoading
                                ? Lottie.asset(
                                    'assets/animations/loading.json',
                                    width: 40,
                                  )
                                : Column(
                                    children: _resources
                                        .map((r) => _buildResourceLink(r))
                                        .toList(),
                                  ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceLink(Map<String, String> resource) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _openUrl(resource['url'] ?? ""),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: NavioTheme.surfaceDecoration(
            radius: NavioTheme.radiusSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  resource['title'] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    color: NavioTheme.textSecondary(alpha: 0.78),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: NavioTheme.textMuted(alpha: 0.54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapRevealItem extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  const _RoadmapRevealItem({required this.isVisible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: NavioTheme.slow,
      curve: Curves.easeOutCubic,
      child: isVisible
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: child,
            )
          : const SizedBox.shrink(),
    );
  }
}
