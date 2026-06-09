import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/pages/portfolio/plan_service.dart';
import 'package:navio/services/field_to_job_title.dart';
import 'package:navio/services/groq_service.dart';
import 'package:navio/widgets/auto_scale_text.dart';
import 'package:navio/widgets/buttons/label_button.dart';
import 'package:navio/widgets/custom_text_field.dart';
import 'package:navio/widgets/line_seperator.dart';
import 'package:navio/widgets/navio_theme.dart';
import 'package:navio/widgets/notifiers.dart';
import 'package:navio/widgets/spacing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

part 'portfolio_models.dart';
part 'portfolio_resume_widgets.dart';
part 'portfolio_skill_widgets.dart';
part 'portfolio_dashboard_widgets.dart';
part 'portfolio_info_widgets.dart';
part 'portfolio_todo_widgets.dart';

const _todoCacheKey = "portfolioTodos";
const _todoCareerKey = "portfolioTodosCareer";
const _skillsCacheKey = "portfolioSkills";
const _skillsCareerKey = "portfolioSkillsCareer";
const _resumeCacheKey = "portfolioResume";
const _todoKindNormal = "normal";
const _todoKindResources = "resources";
const _todoKindSkills = "skills";

enum _PortfolioSection { home, info, skills, todo, resume, reset }

class PortfolioHome extends StatefulWidget {
  final VoidCallback onOpenPlan;

  const PortfolioHome({super.key, required this.onOpenPlan});

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  final _todoController = TextEditingController();
  final _infoNameController = TextEditingController();
  final _infoStageController = TextEditingController();
  final _infoCareerController = TextEditingController();
  final _infoStyleController = TextEditingController();
  final _interestController = TextEditingController();
  final _resumeNameController = TextEditingController();
  final _resumeHeadlineController = TextEditingController();
  final _resumeEmailController = TextEditingController();
  final _resumePhoneController = TextEditingController();
  final _resumeLocationController = TextEditingController();
  final _resumeSummaryController = TextEditingController();
  final _resumeSkillsController = TextEditingController();
  final _resumeExperienceController = TextEditingController();
  final _resumeEducationController = TextEditingController();
  final _resumeAchievementsController = TextEditingController();
  final _resumeLanguagesController = TextEditingController();
  final _resumeReferencesController = TextEditingController();
  final _planService = PlanService();
  final List<_TodoItem> _todos = [];
  final List<_SkillItem> _skills = [];
  final List<_ResumeEntry> _resumeExperiences = [];
  final List<_ResumeEntry> _resumeAchievements = [];

  bool isLoading = false;
  bool _hasTodoText = false;
  bool _isSeedingTodos = false;
  bool _isGeneratingTasks = false;
  bool _hasSkillAssessment = false;
  bool _showResumePreview = false;
  int _skillAssessmentIndex = 0;
  int _careerChangeSerial = 0;
  int _taskGenerationRun = 0;
  _PortfolioSection _section = _PortfolioSection.home;

  @override
  void initState() {
    super.initState();
    careerNotifier.addListener(_onCareerChanged);
    portfolioTabTapNotifier.addListener(_onPortfolioTabTapped);
    roadmapResourceOpenedNotifier.addListener(_onRoadmapResourceOpened);
    _todoController.addListener(_onTodoTextChanged);
    _infoNameController.text = usernameNotifier.value;
    _infoStageController.text = stageNotifier.value;
    _infoCareerController.text = careerNotifier.value;
    _infoStyleController.text = selectedStyleNotifier.value ?? "";
    _loadTodos();
    _loadSkills();
    _loadResume();
    _convertCareer();
  }

  @override
  void dispose() {
    careerNotifier.removeListener(_onCareerChanged);
    portfolioTabTapNotifier.removeListener(_onPortfolioTabTapped);
    roadmapResourceOpenedNotifier.removeListener(_onRoadmapResourceOpened);
    _todoController.removeListener(_onTodoTextChanged);
    _todoController.dispose();
    _infoNameController.dispose();
    _infoStageController.dispose();
    _infoCareerController.dispose();
    _infoStyleController.dispose();
    _interestController.dispose();
    _resumeNameController.dispose();
    _resumeHeadlineController.dispose();
    _resumeEmailController.dispose();
    _resumePhoneController.dispose();
    _resumeLocationController.dispose();
    _resumeSummaryController.dispose();
    _resumeSkillsController.dispose();
    _resumeExperienceController.dispose();
    _resumeEducationController.dispose();
    _resumeAchievementsController.dispose();
    _resumeLanguagesController.dispose();
    _resumeReferencesController.dispose();
    super.dispose();
  }

  void _onCareerChanged() {
    _taskGenerationRun++;
    careerTitleNotifier.value = "";
    _infoCareerController.text = careerNotifier.value;
    if (mounted) {
      setState(() {
        _section = _PortfolioSection.home;
        _careerChangeSerial++;
        _isGeneratingTasks = false;
      });
    }
    _convertCareer();
    _loadTodos();
    _loadSkills();
    _loadResume(useSavedDraft: false);
  }

  void _onPortfolioTabTapped() {
    if (_section == _PortfolioSection.home) return;
    setState(() => _section = _PortfolioSection.home);
  }

  void _onTodoTextChanged() {
    final hasText = _todoController.text.trim().isNotEmpty;
    if (hasText != _hasTodoText) {
      setState(() => _hasTodoText = hasText);
    }
  }

  void _syncInfoControllers() {
    if (_section != _PortfolioSection.info) return;
    _infoNameController.text = usernameNotifier.value;
    _infoStageController.text = stageNotifier.value;
    _infoCareerController.text = careerNotifier.value;
    _infoStyleController.text = selectedStyleNotifier.value ?? "";
  }

  Future<void> _saveInfoField(String key, String value) async {
    final clean = value.trim();
    HapticFeedback.selectionClick();

    switch (key) {
      case "username":
        usernameNotifier.value = clean;
        break;
      case "stage":
        stageNotifier.value = clean;
        break;
      case "career":
        careerNotifier.value = clean;
        careerTitleNotifier.value = "";
        await AppStorage.saveString("careerTitle", "");
        break;
      case "style":
        selectedStyleNotifier.value = clean.isEmpty ? null : clean;
        break;
    }

    await AppStorage.saveString(key, clean);
    if (mounted) setState(() {});
  }

  Future<void> _addInterest() async {
    final clean = _interestController.text.trim();
    if (clean.isEmpty) return;

    final current = selectedAoiNotifier.value
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final exists = current.any(
      (item) => item.toLowerCase() == clean.toLowerCase(),
    );
    if (exists || current.length >= 10) {
      HapticFeedback.selectionClick();
      _interestController.clear();
      return;
    }

    final next = [...current, clean];
    selectedAoiNotifier.value = next;
    _interestController.clear();
    HapticFeedback.lightImpact();
    await AppStorage.saveStringList("aois", next);
    if (mounted) setState(() {});
  }

  Future<void> _removeInterest(String interest) async {
    final next = selectedAoiNotifier.value
        .where((item) => item != interest)
        .toList();
    selectedAoiNotifier.value = next;
    HapticFeedback.lightImpact();
    await AppStorage.saveStringList("aois", next);
    if (mounted) setState(() {});
  }

  void _onRoadmapResourceOpened() {
    _completeSpecialTodo(_todoKindResources);
  }

  Future<void> _loadSkills() async {
    final career = careerNotifier.value;
    if (career.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _skills.clear();
          _hasSkillAssessment = false;
          _skillAssessmentIndex = 0;
        });
      }
      return;
    }

    final skillsCareer = await AppStorage.loadString(_skillsCareerKey) ?? "";
    final raw = await AppStorage.loadString(_skillsCacheKey);
    final items = <_SkillItem>[];
    var hasAssessment = false;

    if (skillsCareer == career && raw != null && raw.isNotEmpty) {
      try {
        items.addAll(
          (jsonDecode(raw) as List).whereType<Map>().map(
            (item) => _normalizeSkillItem(_SkillItem.fromJson(item)),
          ),
        );
        hasAssessment = items.isNotEmpty;
      } catch (_) {}
    }

    if (items.isEmpty) {
      items.addAll(_defaultSkillsForCareer(career));
    }

    if (mounted && careerNotifier.value == career) {
      setState(() {
        _skills
          ..clear()
          ..addAll(items);
        _hasSkillAssessment = hasAssessment;
        _skillAssessmentIndex = 0;
      });
    }
  }

  Future<void> _saveSkills() async {
    await AppStorage.saveString(
      _skillsCacheKey,
      jsonEncode(_skills.map((skill) => skill.toJson()).toList()),
    );
    await AppStorage.saveString(_skillsCareerKey, careerNotifier.value);
  }

  void _updateSkillScore(int index, double value) {
    setState(() => _skills[index].score = value.round().clamp(1, 5));
  }

  void _previousSkillQuestion() {
    if (_skillAssessmentIndex == 0) return;
    HapticFeedback.selectionClick();
    setState(() => _skillAssessmentIndex--);
  }

  Future<void> _nextSkillQuestion() async {
    if (_skillAssessmentIndex >= _skills.length - 1) {
      await _completeSkillAssessment();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _skillAssessmentIndex++);
  }

  Future<void> _completeSkillAssessment() async {
    HapticFeedback.mediumImpact();
    setState(() => _hasSkillAssessment = true);
    _completeSpecialTodo(_todoKindSkills);
    await _saveSkills();
  }

  void _retakeSkillAssessment() {
    HapticFeedback.selectionClick();
    setState(() {
      _hasSkillAssessment = false;
      _skillAssessmentIndex = 0;
    });
  }

  Future<void> _loadTodos() async {
    final career = careerNotifier.value;
    final todoCareer = await AppStorage.loadString(_todoCareerKey) ?? "";
    final raw = await AppStorage.loadString(_todoCacheKey);
    final items = <_TodoItem>[];

    if (todoCareer == career && raw != null && raw.isNotEmpty) {
      try {
        items.addAll(
          (jsonDecode(raw) as List).whereType<Map>().map(
            (item) => _normalizeTodoItem(_TodoItem.fromJson(item)),
          ),
        );
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _todos
          ..clear()
          ..addAll(items);
      });
    }

    await _seedTodosForCareerIfNeeded(career, todoCareer);
  }

  Future<void> _seedTodosForCareerIfNeeded(
    String career,
    String seededCareer,
  ) async {
    if (_isSeedingTodos) return;
    if (career.trim().isEmpty) return;
    if (seededCareer == career) return;

    _isSeedingTodos = true;
    try {
      final steps = await _planService.loadOrGenerate();
      if (!mounted || careerNotifier.value != career) return;

      setState(() {
        _todos
          ..clear()
          ..addAll(_todosFromRoadmap(steps));
      });
      await _saveTodos();
    } catch (_) {
      if (!mounted || careerNotifier.value != career) return;

      setState(() {
        _todos
          ..clear()
          ..addAll(_fallbackTodosForCareer(career));
      });
      await _saveTodos();
    } finally {
      _isSeedingTodos = false;
    }
  }

  List<_TodoItem> _todosFromRoadmap(List<Map<String, String>> steps) {
    final todos = <_TodoItem>[];

    for (var i = 0; i < steps.length && todos.length < 5; i++) {
      final title = steps[i]['title']?.trim() ?? "";
      if (title.isEmpty) continue;

      final action = _firstActionFromDescription(steps[i]['description'] ?? "");
      todos.add(_TodoItem(title: _todoTitleForStep(title, action, i)));
    }

    todos.add(
      _TodoItem(
        title: "Open Resources and save one useful link",
        kind: _todoKindResources,
      ),
    );
    todos.add(
      _TodoItem(
        title: "Complete your first Skills quiz",
        kind: _todoKindSkills,
        isDone: _hasSkillAssessment,
      ),
    );

    while (todos.length < 5) {
      todos.add(_TodoItem(title: "Add one portfolio proof from today's work"));
    }

    return todos.take(7).toList();
  }

  String _todoTitleForStep(String title, String action, int index) {
    final cleanTitle = _shortTodoStepTitle(title);
    final cleanAction = _todoActionForStep(title, action, index);

    if (cleanTitle.isEmpty) return cleanAction;
    return "$cleanTitle: $cleanAction";
  }

  String _firstActionFromDescription(String description) {
    final lines = description
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return "";

    return lines.firstWhere(
      (line) => RegExp(
        r'\b(build|create|practice|learn|research|complete|write|save|apply|make|find|review|watch|read|update)\b',
        caseSensitive: false,
      ).hasMatch(line),
      orElse: () => lines.first,
    );
  }

  String _shortTodoAction(String value) {
    final clean = _compactText(value);
    if (clean.isEmpty) return "";

    final keywordAction = _keywordTodoAction(clean);
    if (keywordAction != null) return keywordAction;

    var sentence = clean.split(RegExp(r'[.!?]\s+')).first.trim();
    sentence = sentence
        .split(RegExp(r'\s+(?:Utilize|Use|Join|This|These)\b'))
        .first
        .trim();
    sentence = sentence.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

    final colonIndex = sentence.indexOf(':');
    if (colonIndex >= 0 && colonIndex < 36) {
      sentence = sentence.substring(colonIndex + 1).trim();
    }

    final clause = sentence.split(RegExp(r'\s+(?:to|by|so that)\s+')).first;
    if (clause.length < sentence.length && clause.length > 18) {
      sentence = clause.trim();
    }

    var words = sentence
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length > 10) {
      words = words.take(10).toList();
    }

    sentence = words.join(' ');
    return sentence.replaceAll(RegExp(r'[,.:\-;]+$'), '').trim();
  }

  String _todoActionForStep(String title, String action, int index) {
    final keywordAction = _keywordTodoAction("$title $action");
    if (keywordAction != null) return keywordAction;

    final cleanAction = _shortTodoAction(action);
    if (cleanAction.isNotEmpty) return cleanAction;

    const fallbackActions = [
      "Write 3 notes about this step",
      "Practice the main skill for 25 minutes",
      "Create one small proof of work",
      "Update your next step",
      "Save one useful resource",
    ];

    return fallbackActions[index % fallbackActions.length];
  }

  String? _keywordTodoAction(String value) {
    final lower = value.toLowerCase();

    if (_matchesAny(lower, [
      "degree",
      "bachelor",
      "college",
      "university",
      "degree program",
      "related program",
      "enroll",
    ])) {
      return "Compare 3 related programs";
    }
    if (_matchesAny(lower, ["boot camp", "course", "coursera", "edx"])) {
      return "Choose one course to start";
    }
    if (_matchesAny(lower, ["coding challenge", "hackathon", "competition"])) {
      return "Join one coding challenge";
    }
    if (_matchesAny(lower, [
      "app development",
      "mobile app",
      "framework",
      "react",
      "flutter",
    ])) {
      return "Build one tiny app screen";
    }
    if (_matchesAny(lower, [
      "programming",
      "python",
      "java",
      "c++",
      "javascript",
      "language",
    ])) {
      return "Complete one beginner coding lesson";
    }
    if (_matchesAny(lower, ["portfolio", "project", "proof"])) {
      return "Add one project proof";
    }
    if (_matchesAny(lower, ["github", "stack overflow", "community"])) {
      return "Join one relevant community";
    }
    if (_matchesAny(lower, ["internship", "volunteer", "practical"])) {
      return "Find 3 experience options";
    }
    if (_matchesAny(lower, ["exam", "certification", "test"])) {
      return "Plan one study session";
    }
    if (_matchesAny(lower, ["resource", "article", "video", "book"])) {
      return "Save one useful resource";
    }
    if (_matchesAny(lower, ["research", "source"])) {
      return "Write 3 notes from one source";
    }

    return null;
  }

  String _compactText(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\d.)\-\s]+'), '')
        .trim();
  }

  String _limitTodo(String value) {
    final clean = _compactText(value);
    final parts = clean.split(':');

    if (parts.length > 1) {
      final title = _shortTodoStepTitle(parts.first);
      final action = _todoActionForStep(title, parts.sublist(1).join(':'), 0);
      if (title.isNotEmpty && action.isNotEmpty) {
        return "$title: $action";
      }
    }

    final shortened = _shortTodoAction(clean);
    return shortened.isEmpty ? clean : shortened;
  }

  _TodoItem _normalizeTodoItem(_TodoItem todo) {
    final migratedTitle = todo.title.replaceFirst(
      RegExp(r'^Do this from\s+', caseSensitive: false),
      '',
    );

    final kind = _todoKindForTitle(migratedTitle, fallback: todo.kind);
    final title = switch (kind) {
      _todoKindResources => "Open Resources and save one useful link",
      _todoKindSkills => "Complete your first Skills quiz",
      _ => _limitTodo(migratedTitle),
    };

    return _TodoItem(
      title: title,
      isDone: kind == _todoKindSkills && _hasSkillAssessment
          ? true
          : todo.isDone,
      kind: kind,
    );
  }

  String _todoKindForTitle(String title, {String fallback = _todoKindNormal}) {
    final lower = title.toLowerCase();
    if (lower.contains("open resources") ||
        lower.contains("save one useful link")) {
      return _todoKindResources;
    }
    if (lower.contains("skills quiz") || lower.contains("skill quiz")) {
      return _todoKindSkills;
    }
    return fallback;
  }

  String _shortTodoStepTitle(String value) {
    var title = _compactText(value);
    title = title
        .replaceFirst(RegExp(r'\bFundamentals\b', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\bExperience\b', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\bCourses\b', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\bPrograms\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final words = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length > 4) {
      title = words.take(4).join(' ');
    }

    return title.replaceAll(RegExp(r'[,.:\-;]+$'), '').trim();
  }

  _SkillItem _normalizeSkillItem(_SkillItem skill) {
    return _SkillItem(
      label: skill.label,
      prompt: _questionForSkill(skill.label),
      score: skill.score,
      target: skill.target,
    );
  }

  List<_TodoItem> _fallbackTodosForCareer(String career) {
    final label = career.trim().isEmpty ? "your career" : career;
    return [
      _TodoItem(
        title: "Find 3 entry-level $label job posts and save common skills",
      ),
      _TodoItem(
        title: "Choose one $label skill to practice for 25 minutes today",
      ),
      _TodoItem(title: "Create one small portfolio project idea for $label"),
      _TodoItem(title: "Save one $label resource and write 2 notes"),
      _TodoItem(title: "Write one question to ask about $label"),
      _TodoItem(
        title: "Open Resources and save one useful link",
        kind: _todoKindResources,
      ),
      _TodoItem(
        title: "Complete your first Skills quiz",
        kind: _todoKindSkills,
        isDone: _hasSkillAssessment,
      ),
    ];
  }

  List<_SkillItem> _defaultSkillsForCareer(String career) {
    final lower = career.toLowerCase();

    if (_matchesAny(lower, [
      "actuarial",
      "accounting",
      "economics",
      "finance",
      "mathematics",
      "statistics",
      "taxation",
    ])) {
      return _skillSet(career, const [
        "Quantitative Reasoning",
        "Statistics",
        "Spreadsheet Modeling",
        "Risk Analysis",
        "Business Context",
        "Exam Discipline",
        "Communication",
        "Programming",
      ]);
    }

    if (_matchesAny(lower, [
      "computer",
      "software",
      "web",
      "app",
      "data",
      "machine learning",
      "artificial",
      "cybersecurity",
      "information",
      "robotics",
      "game",
    ])) {
      return _skillSet(career, const [
        "Programming",
        "Data Thinking",
        "Debugging",
        "Systems Design",
        "Tool Fluency",
        "Product Sense",
        "Communication",
        "Project Building",
      ]);
    }

    if (_matchesAny(lower, [
      "medicine",
      "nursing",
      "health",
      "therapy",
      "psychology",
      "dental",
      "pharmacy",
      "public health",
      "biology",
      "neuroscience",
      "nutrition",
    ])) {
      return _skillSet(career, const [
        "Science Foundations",
        "Patient Communication",
        "Attention to Detail",
        "Ethical Judgment",
        "Research Literacy",
        "Teamwork",
        "Stress Management",
        "Data Literacy",
      ]);
    }

    if (_matchesAny(lower, [
      "design",
      "art",
      "animation",
      "film",
      "music",
      "writing",
      "photography",
      "illustration",
      "theatre",
    ])) {
      return _skillSet(career, const [
        "Creative Tools",
        "Visual Taste",
        "Storytelling",
        "Feedback Use",
        "Portfolio Building",
        "Client Communication",
        "Project Planning",
        "Originality",
      ]);
    }

    if (_matchesAny(lower, [
      "business",
      "management",
      "marketing",
      "entrepreneurship",
      "product",
      "sales",
      "human resources",
      "real estate",
      "hospitality",
    ])) {
      return _skillSet(career, const [
        "Market Research",
        "Strategy",
        "Communication",
        "Spreadsheet Analysis",
        "Leadership",
        "Customer Empathy",
        "Execution",
        "Presentation",
      ]);
    }

    if (_matchesAny(lower, [
      "education",
      "social work",
      "counseling",
      "law",
      "policy",
      "criminal",
      "public administration",
      "sociology",
    ])) {
      return _skillSet(career, const [
        "Communication",
        "Empathy",
        "Research Literacy",
        "Conflict Resolution",
        "Ethical Judgment",
        "Documentation",
        "Critical Thinking",
        "Community Awareness",
      ]);
    }

    if (_matchesAny(lower, [
      "engineering",
      "architecture",
      "construction",
      "physics",
      "mechanical",
      "electrical",
      "civil",
      "aerospace",
    ])) {
      return _skillSet(career, const [
        "Math",
        "Physics",
        "Technical Tools",
        "Problem Solving",
        "Safety Thinking",
        "Project Planning",
        "Team Communication",
        "Prototyping",
      ]);
    }

    return _skillSet(career, const [
      "Research",
      "Communication",
      "Problem Solving",
      "Digital Tools",
      "Project Planning",
      "Data Literacy",
      "Portfolio Building",
      "Career Knowledge",
    ]);
  }

  bool _matchesAny(String value, List<String> terms) {
    return terms.any((term) => value.contains(term));
  }

  List<_SkillItem> _skillSet(String career, List<String> labels) {
    return labels
        .map(
          (label) => _SkillItem(label: label, prompt: _questionForSkill(label)),
        )
        .toList();
  }

  String _questionForSkill(String label) {
    final lower = label.toLowerCase();
    if (lower.contains("quantitative")) {
      return "How comfortable are you solving multi-step math problems?";
    }
    if (lower.contains("statistics")) {
      return "How comfortable are you using charts or tables to answer a question?";
    }
    if (lower.contains("programming")) {
      return "How comfortable are you writing or editing a small program?";
    }
    if (lower.contains("spreadsheet")) {
      return "How comfortable are you using spreadsheet formulas?";
    }
    if (lower.contains("communication")) {
      return "How comfortable are you explaining a topic to someone who is new to it?";
    }
    if (lower.contains("portfolio") || lower.contains("project")) {
      return "How much experience do you have finishing and sharing a small project?";
    }
    if (lower.contains("research")) {
      return "How comfortable are you finding reliable sources and writing useful notes?";
    }
    if (lower.contains("data") || lower.contains("statistics")) {
      return "How comfortable are you using data to support a decision?";
    }
    if (lower.contains("math") || lower.contains("quantitative")) {
      return "How comfortable are you working through math-heavy homework or practice problems?";
    }
    if (lower.contains("tool")) {
      return "How comfortable are you learning a new app or digital tool on your own?";
    }
    if (lower.contains("risk")) {
      return "How comfortable are you comparing possible outcomes before making a choice?";
    }
    if (lower.contains("business") || lower.contains("market")) {
      return "How comfortable are you explaining why a company succeeds?";
    }
    if (lower.contains("exam")) {
      return "How consistent are you with studying for tests over multiple weeks?";
    }
    if (lower.contains("debug")) {
      return "How comfortable are you finding and fixing mistakes in your work?";
    }
    if (lower.contains("system")) {
      return "How comfortable are you breaking a complex thing into smaller parts?";
    }
    if (lower.contains("product") || lower.contains("customer")) {
      return "How comfortable are you thinking about what a user or customer needs?";
    }
    if (lower.contains("science")) {
      return "How comfortable are you using science concepts in classwork or projects?";
    }
    if (lower.contains("patient") || lower.contains("empathy")) {
      return "How comfortable are you listening carefully and responding with care?";
    }
    if (lower.contains("detail")) {
      return "How reliable are you at checking your work for small mistakes?";
    }
    if (lower.contains("ethical")) {
      return "How comfortable are you thinking through what is fair, safe, and responsible?";
    }
    if (lower.contains("team")) {
      return "How comfortable are you working with others on a shared task?";
    }
    if (lower.contains("stress")) {
      return "How well do you stay focused on difficult tasks?";
    }
    if (lower.contains("creative") || lower.contains("visual")) {
      return "How comfortable are you making visual or creative work and improving it?";
    }
    if (lower.contains("story")) {
      return "How comfortable are you turning ideas into a clear story or explanation?";
    }
    if (lower.contains("feedback")) {
      return "How comfortable are you using feedback to improve your work?";
    }
    if (lower.contains("client")) {
      return "How comfortable are you asking questions to understand what someone wants?";
    }
    if (lower.contains("planning") || lower.contains("execution")) {
      return "How comfortable are you turning a goal into steps and following through?";
    }
    if (lower.contains("leadership")) {
      return "How comfortable are you helping a group stay organized and moving forward?";
    }
    if (lower.contains("strategy")) {
      return "How comfortable are you choosing a plan after comparing options?";
    }
    if (lower.contains("presentation")) {
      return "How comfortable are you presenting your ideas out loud or on slides?";
    }
    if (lower.contains("conflict")) {
      return "How comfortable are you handling disagreement calmly?";
    }
    if (lower.contains("documentation")) {
      return "How comfortable are you writing clear notes, records, or summaries?";
    }
    if (lower.contains("critical")) {
      return "How comfortable are you questioning an idea before accepting it?";
    }
    if (lower.contains("community")) {
      return "How much do you understand the people or communities this work affects?";
    }
    if (lower.contains("physics")) {
      return "How comfortable are you applying physics ideas to real examples?";
    }
    if (lower.contains("safety")) {
      return "How often do you think about what could go wrong and how to prevent it?";
    }
    if (lower.contains("prototype")) {
      return "How much experience do you have making rough versions to test an idea?";
    }
    if (lower.contains("problem")) {
      return "How comfortable are you solving a problem when the answer is not obvious?";
    }
    if (lower.contains("career")) {
      return "How much do you know about what this career looks like day to day?";
    }

    return "How much real experience do you have with $label?";
  }

  Future<void> _saveTodos() async {
    await AppStorage.saveString(
      _todoCacheKey,
      jsonEncode(_todos.map((todo) => todo.toJson()).toList()),
    );
    await AppStorage.saveString(_todoCareerKey, careerNotifier.value);
  }

  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _todos.insert(0, _TodoItem(title: text));
      _todoController.clear();
    });
    _saveTodos();
  }

  Future<void> _generateMoreTasks() async {
    if (_isGeneratingTasks) return;

    final career = careerNotifier.value.trim();
    if (career.isEmpty) {
      selectedNavIndexNotifier.value = 0;
      return;
    }

    final run = ++_taskGenerationRun;
    setState(() => _isGeneratingTasks = true);
    var generated = <_TodoItem>[];

    try {
      final existingKeys = _todos
          .map((todo) => _todoDuplicateKey(todo.title))
          .where((key) => key.isNotEmpty)
          .toSet();
      var steps = <Map<String, String>>[];

      try {
        steps = await _planService.loadOrGenerate();
        if (!mounted || run != _taskGenerationRun) return;

        final aiTasks = await _planService.generateTasks(
          roadmapSteps: steps,
          existingTasks: _todos.map((todo) => todo.title).toList(),
        );
        if (!mounted || run != _taskGenerationRun) return;

        generated = _generatedTodosFromTitles(aiTasks, existingKeys);
      } catch (_) {
        generated = const [];
      }

    if (generated.length < 3) {
      if (steps.isEmpty) {
        try {
          steps = await _planService.loadOrGenerate();
        } catch (_) {
          steps = const [];
        }
      }

      try {
        generated = [
          ...generated,
          ..._fallbackGeneratedTodos(steps, existingKeys),
        ].take(3).toList();
      } catch (e) {
        // If all else fails, just leave the generated list empty
        // without crashing the UI.
      }
    }

    } catch (_) {
      generated = const [];
    }

    if (!mounted || run != _taskGenerationRun) return;

    setState(() {
      if (generated.isNotEmpty) {
        _todos.insertAll(0, generated);
      }
      _isGeneratingTasks = false;
    });

    if (generated.isNotEmpty) {
      try {
        await _saveTodos();
      } catch (_) {}
    }
  }

  List<_TodoItem> _generatedTodosFromTitles(
    List<String> titles,
    Set<String> existingKeys,
  ) {
    final todos = <_TodoItem>[];
    for (final title in titles) {
      final clean = _prepareGeneratedTodoTitle(title, existingKeys);
      if (clean == null) continue;

      todos.add(_TodoItem(title: clean));
      if (todos.length == 3) break;
    }
    return todos;
  }

  List<_TodoItem> _fallbackGeneratedTodos(
    List<Map<String, String>> steps,
    Set<String> existingKeys,
  ) {
    final candidates = <String>[];

    for (var i = 0; i < steps.length; i++) {
      final title = steps[i]['title']?.trim() ?? "";
      final action = _firstActionFromDescription(steps[i]['description'] ?? "");
      if (title.isNotEmpty) {
        candidates.add(_todoTitleForStep(title, action, i));
      }
    }

    final career = careerNotifier.value.trim();
    final label = career.isEmpty ? "your career" : career;
    candidates.addAll([
      "Find 3 $label role examples",
      "Save one useful $label resource",
      "Write 3 questions about $label",
      "Practice one core $label skill",
      "Add one portfolio proof",
      "Compare 2 learning resources",
    ]);

    return _generatedTodosFromTitles(candidates, existingKeys);
  }

String? _prepareGeneratedTodoTitle(
  String? value,
  Set<String> existingKeys,
) {
  if (value == null) return null;

  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length < 3) return null;

  final clean = _limitTodo(
    trimmed.replaceFirst(RegExp(r'^Do this\s*:?\s*', caseSensitive: false), '')
  );

  if (!_isUsableGeneratedTodo(clean)) return null;

  final key = _todoDuplicateKey(clean);
  if (key.isEmpty || existingKeys.contains(key)) return null;

  existingKeys.add(key);
  return clean;
}

  bool _isUsableGeneratedTodo(String value) {
    final clean = _compactText(value);
    if (clean.isEmpty) return false;

    final lower = clean.toLowerCase();
    if (lower.contains("do this")) return false;
    if (_todoKindForTitle(clean) != _todoKindNormal) return false;
    if (RegExp(
      r'\b(to|at|in|for|with|by|from|of|and|or)$',
      caseSensitive: false,
    ).hasMatch(clean)) {
      return false;
    }

    final words = clean.split(RegExp(r'\s+')).where((word) {
      return word.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').isNotEmpty;
    }).length;

    return words >= 3 && clean.length <= 90;
  }

  String _todoDuplicateKey(String value) {
    return _compactText(value)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _toggleTodo(int index) {
    final todo = _todos[index];

    if (!todo.isDone && todo.kind == _todoKindResources) {
      HapticFeedback.lightImpact();
      roadmapResourcesRequestNotifier.value++;
      showPlanNotifier.value = true;
      return;
    }

    if (!todo.isDone && todo.kind == _todoKindSkills) {
      HapticFeedback.lightImpact();
      setState(() => _section = _PortfolioSection.skills);
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _todos[index].isDone = !_todos[index].isDone);
    _saveTodos();
  }

  void _completeSpecialTodo(String kind) {
    if (!mounted) return;

    final index = _todos.indexWhere(
      (todo) => todo.kind == kind && !todo.isDone,
    );
    if (index < 0) return;

    setState(() => _todos[index].isDone = true);
    _saveTodos();
  }

  void _deleteTodo(int index) {
    HapticFeedback.lightImpact();
    setState(() => _todos.removeAt(index));
    _saveTodos();
  }

  Future<void> _convertCareer() async {
    final career = careerNotifier.value;

    if (careerTitleNotifier.value.isNotEmpty) return;
    if (career.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      final groq = GroqService();
      final title = await groq.convertFieldToJobTitle(career);
      if (careerNotifier.value != career) return;

      careerTitleNotifier.value = title ?? career;
      await AppStorage.saveString("careerTitle", careerTitleNotifier.value);
    } catch (e) {
      if (careerNotifier.value != career) return;
      careerTitleNotifier.value = career;
      await AppStorage.saveString("careerTitle", career);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: careerNotifier,
      builder: (context, career, _) {
        return ValueListenableBuilder(
          valueListenable: careerTitleNotifier,
          builder: (context, title, _) {
            final displayTitle = title.isNotEmpty ? title : career;

            return AnimatedSwitcher(
              duration: NavioTheme.normal,
              layoutBuilder: (currentChild, previousChildren) {
                return currentChild ?? const SizedBox.shrink();
              },
              transitionBuilder: _fadeTransition,
              child: KeyedSubtree(
                key: ValueKey(_section),
                child: _buildSection(career, displayTitle),
              ),
            );
          },
        );
      },
    );
  }

  Widget _fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    );
  }

  Widget _careerChangeTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSection(String career, String displayTitle) {
    switch (_section) {
      case _PortfolioSection.info:
        return _buildInfoScreen(career);
      case _PortfolioSection.skills:
        return _buildSkillsScreen(career);
      case _PortfolioSection.todo:
        return _buildTodoScreen();
      case _PortfolioSection.resume:
        return _buildResumeScreen();
      case _PortfolioSection.reset:
        return _buildResetScreen();
      case _PortfolioSection.home:
        return _buildHomeScreen(career, displayTitle);
    }
  }

  Widget _buildHomeScreen(String career, String displayTitle) {
    final remainingTasks = _todos.where((todo) => !todo.isDone).length;
    final completedTasks = _todos.where((todo) => todo.isDone).length;
    final totalTasks = _todos.length;
    final taskProgress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final skillAverage = _skillAverage();
    final hasCareer = career.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 690;
        final tight = constraints.maxHeight < 630;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              layoutBuilder: (currentChild, previousChildren) {
                return currentChild ?? const SizedBox.shrink();
              },
              transitionBuilder: _careerChangeTransition,
              child: Column(
                key: ValueKey("career-dashboard-$_careerChangeSerial"),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(career, displayTitle, compact: compact),
                  SizedBox(height: tight ? 12 : 16),
                  const LineSeparator(),
                  SizedBox(height: tight ? 12 : 16),
                  _DashboardHeroCard(
                    compact: compact,
                    title: hasCareer
                        ? "Path in motion"
                        : "Choose your direction",
                    subtitle: hasCareer
                        ? "Keep your plan, skills, resume, and tasks moving together."
                        : "Start with Career Finder to unlock a roadmap and smarter tasks.",
                    progressLabel: totalTasks == 0
                        ? "No tasks yet"
                        : "$completedTasks of $totalTasks tasks done",
                    progress: taskProgress,
                    primaryValue: remainingTasks.toString(),
                    primaryLabel: remainingTasks == 1
                        ? "task left"
                        : "tasks left",
                    secondaryValue: _hasSkillAssessment
                        ? "${skillAverage.toStringAsFixed(1)}/5"
                        : "--",
                    secondaryLabel: "skill score",
                  ),
                ],
              ),
            ),
            SizedBox(height: tight ? 14 : 20),
            Text(
              "Tools",
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: NavioTheme.textMuted(alpha: 0.48),
              ),
            ),
            SizedBox(height: tight ? 8 : 10),
            Expanded(child: _buildMenuButtons(compact: compact)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    String career,
    String displayTitle, {
    bool compact = false,
  }) {
    final subtitle = career.trim().isEmpty
        ? "Nice to see you."
        : isLoading && careerTitleNotifier.value.isEmpty
        ? "Finding your path..."
        : "Aspiring $displayTitle";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoScaleText(
          "Good ${getTimeOfDay()}, ${usernameNotifier.value}",
          maxLines: 1,
          minFontSize: 20,
          style: TextStyle(fontFamily: "New-York", fontSize: compact ? 26 : 30),
        ),
        SizedBox(height: compact ? 7 : 10),
        AnimatedSwitcher(
          duration: NavioTheme.normal,
          layoutBuilder: (currentChild, previousChildren) {
            return currentChild ?? const SizedBox.shrink();
          },
          transitionBuilder: _fadeTransition,
          child: AutoScaleText(
            subtitle,
            key: ValueKey(subtitle),
            maxLines: 1,
            minFontSize: 11,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontWeight: FontWeight.w500,
              color: NavioTheme.textSecondary(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons({bool compact = false}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final gap = constraints.maxHeight < 150 ? 5.0 : compact ? 8.0 : 10.0;
      
      // FIX: Ensure buttonHeight has a robust minimum threshold (e.g. clamp 50.0 instead of 38.0)
      // to handle cases where layout height reports smaller values upon item removal.
      final buttonHeight = ((constraints.maxHeight - gap * 2) / 3)
          .clamp(50.0, compact ? 66.0 : 76.0) 
          .toDouble();
          
      final showSubtitles = buttonHeight >= 58;

      Widget button({
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
        return Expanded(
          child: _PortfolioButton(
            height: buttonHeight,
            showSubtitle: showSubtitles,
            compact: compact,
            icon: icon,
            title: title,
            subtitle: subtitle,
            onTap: onTap,
          ),
        );
      }

      return Column(
        children: [
          Row(
            children: [
              button(
                icon: Icons.route_rounded,
                title: "My Plan",
                subtitle: "Open roadmap",
                onTap: widget.onOpenPlan,
              ),
              const SizedBox(width: 10),
              button(
                icon: Icons.badge_outlined,
                title: "My Info",
                subtitle: "View profile",
                onTap: () => setState(() => _section = _PortfolioSection.info),
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              button(
                icon: Icons.radar_rounded,
                title: "Skills",
                subtitle: _hasSkillAssessment ? "View skill map" : "Assess fit",
                onTap: () => setState(() => _section = _PortfolioSection.skills),
              ),
              const SizedBox(width: 10),
              button(
                icon: Icons.checklist_rounded,
                title: "Tasks",
                subtitle: "${_todos.where((todo) => !todo.isDone).length} left",
                onTap: () => setState(() => _section = _PortfolioSection.todo),
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              button(
                icon: Icons.description_outlined,
                title: "Resume",
                subtitle: _hasResumeContent() ? "View draft" : "Build draft",
                onTap: () => setState(() => _section = _PortfolioSection.resume),
              ),
              const SizedBox(width: 10),
              button(
                icon: Icons.refresh_rounded,
                title: "Reset",
                subtitle: "Start over",
                onTap: () => setState(() => _section = _PortfolioSection.reset),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  bool _hasResumeContent() {
    return [
          _resumeSummaryController.text,
          _resumeSkillsController.text,
          _resumeEducationController.text,
          _resumeLanguagesController.text,
          _resumeReferencesController.text,
        ].any((value) => value.trim().isNotEmpty) ||
        _resumeExperiences.any((entry) => entry.hasContent) ||
        _resumeAchievements.any((entry) => entry.hasContent);
  }

  Future<void> _loadResume({bool useSavedDraft = true}) async {
    if (useSavedDraft) {
      final raw = await AppStorage.loadString(_resumeCacheKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          final draft = _ResumeDraft.fromJson(jsonDecode(raw) as Map);
          _applyResumeDraft(draft);
          return;
        } catch (_) {}
      }
    }

    final careerTitle = careerTitleNotifier.value.trim().isNotEmpty
        ? careerTitleNotifier.value.trim()
        : careerNotifier.value.trim();
    final starterSkills = _skills
        .where((skill) => skill.score >= 4)
        .map((skill) => skill.label)
        .take(6)
        .toList();

    _applyResumeDraft(
      _ResumeDraft(
        name: usernameNotifier.value.trim(),
        headline: careerTitle.isEmpty ? "Student" : "Aspiring $careerTitle",
        summary: careerTitle.isEmpty
            ? ""
            : "Motivated student building toward $careerTitle, with interests in ${selectedAoiNotifier.value.take(3).join(', ')}.",
        skills: starterSkills.isEmpty ? "" : starterSkills.join("\n"),
        education: stageNotifier.value.trim(),
      ),
    );
  }

  void _applyResumeDraft(_ResumeDraft draft) {
    _resumeNameController.text = draft.name;
    _resumeHeadlineController.text = draft.headline;
    _resumeEmailController.text = draft.email;
    _resumePhoneController.text = draft.phone;
    _resumeLocationController.text = draft.location;
    _resumeSummaryController.text = draft.summary;
    _resumeSkillsController.text = draft.skills;
    _resumeExperienceController.text = draft.experience;
    _resumeEducationController.text = draft.education;
    _resumeAchievementsController.text = draft.achievements;
    _resumeLanguagesController.text = draft.languages;
    _resumeReferencesController.text = draft.references;
    _resumeExperiences
      ..clear()
      ..addAll(draft.experienceEntries);
    _resumeAchievements
      ..clear()
      ..addAll(draft.achievementEntries);
    if (mounted) setState(() => _showResumePreview = draft.hasContent);
  }

  _ResumeDraft _resumeDraft() {
    final experiences = _resumeExperiences
        .where((entry) => entry.hasContent)
        .toList(growable: false);
    final achievements = _resumeAchievements
        .where((entry) => entry.hasContent)
        .toList(growable: false);

    return _ResumeDraft(
      name: _resumeNameController.text.trim(),
      headline: _resumeHeadlineController.text.trim(),
      email: _resumeEmailController.text.trim(),
      phone: _resumePhoneController.text.trim(),
      location: _resumeLocationController.text.trim(),
      summary: _resumeSummaryController.text.trim(),
      skills: _resumeSkillsController.text.trim(),
      experience: experiences.isEmpty
          ? _resumeExperienceController.text.trim()
          : _resumeEntriesToLegacy(experiences),
      education: _resumeEducationController.text.trim(),
      achievements: achievements.isEmpty
          ? _resumeAchievementsController.text.trim()
          : _resumeEntriesToLegacy(achievements),
      languages: _resumeLanguagesController.text.trim(),
      references: _resumeReferencesController.text.trim(),
      experienceEntries: experiences,
      achievementEntries: achievements,
    );
  }

  String _resumeEntriesToLegacy(List<_ResumeEntry> entries) {
    return entries
        .map((entry) => entry.toPreviewLines().join(" - "))
        .join("\n");
  }

  Future<void> _saveResume({bool showPreview = true}) async {
    final draft = _resumeDraft();
    await AppStorage.saveString(_resumeCacheKey, jsonEncode(draft.toJson()));
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() => _showResumePreview = showPreview);
    }
  }

  void _addResumeEntry({required bool achievement}) {
    HapticFeedback.lightImpact();
    setState(() {
      final list = achievement ? _resumeAchievements : _resumeExperiences;
      list.add(const _ResumeEntry());
    });
  }

  void _updateResumeEntry({
    required bool achievement,
    required int index,
    required _ResumeEntry entry,
  }) {
    setState(() {
      final list = achievement ? _resumeAchievements : _resumeExperiences;
      if (index >= 0 && index < list.length) {
        list[index] = entry;
      }
    });
  }

  void _removeResumeEntry({required bool achievement, required int index}) {
    HapticFeedback.lightImpact();
    setState(() {
      final list = achievement ? _resumeAchievements : _resumeExperiences;
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
      }
    });
  }

  List<String> _resumeLines(String value) {
    return value
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _resumePdfLine(String value, int maxChars) {
    final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= maxChars) return clean;
    final clipped = clean.substring(0, math.max(0, maxChars - 3)).trimRight();
    final lastSpace = clipped.lastIndexOf(" ");
    final readable = lastSpace > 24 ? clipped.substring(0, lastSpace) : clipped;
    return "${readable.replaceFirst(RegExp(r'[\s,.;:-]+$'), '')}...";
  }

  Future<Uint8List> _buildResumePdfBytes() async {
    final draft = _resumeDraft();
    final doc = pw.Document();
    const pageBg = PdfColor.fromInt(0xFFF6F6F4);
    const panel = PdfColor.fromInt(0xFFEDEDEC);
    const text = PdfColor.fromInt(0xFF333335);
    const muted = PdfColor.fromInt(0xFF66666A);
    const accent = PdfColor.fromInt(0xFF333335);

    pw.TextStyle style(double size, {bool bold = false, PdfColor? color}) {
      return pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? text,
        lineSpacing: 1.35,
      );
    }

    pw.Widget heading(String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          value.toUpperCase(),
          style: style(12.5, bold: true, color: text),
        ),
      );
    }

    pw.Widget listSection(
      String title,
      List<String> items,
      String empty, {
      int maxItems = 4,
      int maxChars = 90,
      bool showWhenEmpty = false,
      bool showMoreCount = true,
    }) {
      final visible = items.take(maxItems).toList();
      final hiddenCount = items.length - visible.length;
      final content = visible.isEmpty ? [empty] : visible;
      if (items.isEmpty && !showWhenEmpty) return pw.SizedBox.shrink();
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            heading(title),
            ...content.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 4,
                      height: 4,
                      margin: const pw.EdgeInsets.only(top: 5, right: 8),
                      decoration: const pw.BoxDecoration(
                        color: accent,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _resumePdfLine(item, maxChars),
                        style: style(10.5, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hiddenCount > 0 && showMoreCount)
              pw.Text("+ $hiddenCount more", style: style(9.5, color: muted)),
          ],
        ),
      );
    }

    pw.Widget entrySection(
      String title,
      List<_ResumeEntry> entries,
      String empty, {
      int maxItems = 3,
    }) {
      final visible = entries.where((entry) => entry.hasContent).take(maxItems);
      final visibleList = visible.toList();
      if (visibleList.isEmpty) return pw.SizedBox.shrink();

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            heading(title),
            ...visibleList.map((entry) {
              final details = entry.detailLines().take(2).toList();
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            _resumePdfLine(entry.title, 72),
                            style: style(10.8, bold: true),
                          ),
                        ),
                        if (entry.dates.trim().isNotEmpty)
                          pw.Text(
                            _resumePdfLine(entry.dates, 22),
                            style: style(9.8, bold: true, color: text),
                          ),
                      ],
                    ),
                    if (entry.organization.trim().isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(
                          _resumePdfLine(entry.organization, 78),
                          style: style(10.2, bold: true, color: muted),
                        ),
                      ),
                    pw.SizedBox(height: details.isEmpty ? 0 : 5),
                    ...details.map(
                      (detail) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 3,
                              height: 3,
                              margin: const pw.EdgeInsets.only(
                                top: 5,
                                right: 7,
                              ),
                              decoration: const pw.BoxDecoration(
                                color: accent,
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                _resumePdfLine(detail, 105),
                                style: style(10.2, color: muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) {
          return pw.Container(
            color: pageBg,
            padding: const pw.EdgeInsets.all(34),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: panel,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        draft.name.isEmpty ? "Your Name" : draft.name,
                        style: style(38, bold: true),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        draft.headline.isEmpty ? "Student" : draft.headline,
                        style: style(15, color: muted),
                      ),
                      pw.SizedBox(height: 18),
                      pw.Container(width: 42, height: 3, color: accent),
                      pw.SizedBox(height: 18),
                      heading("Summary"),
                      pw.Text(
                        draft.summary.isEmpty
                            ? "Add a short summary to describe your strengths, direction, and the kind of work you want to do."
                            : _resumePdfLine(draft.summary, 220),
                        style: style(11.8, color: muted),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 22),
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            listSection(
                              "Contact",
                              [
                                draft.phone,
                                draft.email,
                                draft.location,
                              ].where((value) => value.isNotEmpty).toList(),
                              "Add email, phone, or location.",
                              maxItems: 3,
                              maxChars: 72,
                            ),
                            listSection(
                              "Skills",
                              _resumeLines(draft.skills),
                              "Add skills one per line.",
                              maxItems: 7,
                              maxChars: 58,
                            ),
                            listSection(
                              "Education",
                              _resumeLines(draft.education),
                              "Add your school or program.",
                              maxItems: 2,
                              maxChars: 70,
                            ),
                            listSection(
                              "Languages",
                              _resumeLines(draft.languages),
                              "Add languages one per line.",
                              maxItems: 6,
                              maxChars: 58,
                              showMoreCount: false,
                            ),
                            if (draft.references.trim().isNotEmpty)
                              listSection(
                                "References",
                                _resumeLines(draft.references),
                                "Available on request.",
                                maxItems: 1,
                                maxChars: 52,
                              ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 22),
                      pw.Expanded(
                        flex: 7,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            entrySection(
                              "Experience",
                              draft.experienceEntries,
                              "Add roles, projects, or volunteer work.",
                              maxItems: 3,
                            ),
                            entrySection(
                              "Achievements",
                              draft.achievementEntries,
                              "Add awards, competitions, or impact.",
                              maxItems: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  Future<void> _saveResumePdf() async {
    await _saveResume(showPreview: true);
    HapticFeedback.lightImpact();
    final bytes = await _buildResumePdfBytes();
    await Printing.layoutPdf(
      name: "navio_resume.pdf",
      onLayout: (_) async => bytes,
    );
  }

  Widget _buildResumeScreen() {
    final draft = _resumeDraft();

    return _buildSubScreen(
      title: "Resume",
      trailing: _hasResumeContent()
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showResumePreview = !_showResumePreview);
                },
                child: Text(
                  _showResumePreview ? "Edit" : "Preview",
                  style: TextStyle(
                    fontFamily: "SF-Pro",
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NavioTheme.textSecondary(alpha: 0.74),
                  ),
                ),
              ),
            )
          : null,
      child: AnimatedSwitcher(
        duration: NavioTheme.normal,
        transitionBuilder: _fadeTransition,
        child: _showResumePreview && draft.hasContent
            ? _buildResumePreview(draft)
            : _buildResumeForm(),
      ),
    );
  }

  Widget _buildResumeForm() {
    return SingleChildScrollView(
      key: const ValueKey("resume-form"),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Answer these once. Navio will turn them into a clean resume draft.",
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 13,
              color: NavioTheme.textSecondary(alpha: 0.64),
              height: 1.45,
            ),
          ),
          const Spacing(height: 16),
          _ResumeField(
            label: "Name",
            hint: "Your full name",
            controller: _resumeNameController,
            maxLength: 80,
          ),
          _ResumeField(
            label: "Headline",
            hint: "developer, marketer, founder",
            controller: _resumeHeadlineController,
            maxLength: 100,
          ),
          _ResumeField(
            label: "Contact",
            hint: "Email",
            controller: _resumeEmailController,
            maxLength: 100,
          ),
          _ResumeField(
            label: "Phone",
            hint: "Optional",
            controller: _resumePhoneController,
            maxLength: 40,
          ),
          _ResumeField(
            label: "Location",
            hint: "City, province/state",
            controller: _resumeLocationController,
            maxLength: 80,
          ),
          _ResumeField(
            label: "Summary",
            hint:
                "2-3 sentences about what you do, what you are building toward, and your strengths.",
            controller: _resumeSummaryController,
            maxLength: 450,
            maxLines: 4,
          ),
          _ResumeField(
            label: "Skills",
            hint: "One per line, e.g.\nApp Development\nCommunication",
            controller: _resumeSkillsController,
            maxLength: 500,
            maxLines: 5,
          ),
          _ResumeEntrySectionEditor(
            title: "Experience",
            emptyText: "Add roles, projects, volunteer work, or clubs.",
            addText: "Add Experience",
            entries: _resumeExperiences,
            titleHint: "Role or project title",
            organizationHint: "Company, club, or organization",
            dateHint: "2025 - Present",
            detailsHint: "Impact or details, one per line",
            onAdd: () => _addResumeEntry(achievement: false),
            onRemove: (index) =>
                _removeResumeEntry(achievement: false, index: index),
            onChanged: (index, entry) => _updateResumeEntry(
              achievement: false,
              index: index,
              entry: entry,
            ),
          ),
          _ResumeField(
            label: "Education",
            hint: "School/program, years, and a short note.",
            controller: _resumeEducationController,
            maxLength: 450,
            maxLines: 4,
          ),
          _ResumeEntrySectionEditor(
            title: "Achievements",
            emptyText: "Add awards, competitions, certificates, or impact.",
            addText: "Add Achievement",
            entries: _resumeAchievements,
            titleHint: "Award or achievement",
            organizationHint: "Issuer, event, or context",
            dateHint: "2026",
            detailsHint: "Result, placement, or why it matters",
            onAdd: () => _addResumeEntry(achievement: true),
            onRemove: (index) =>
                _removeResumeEntry(achievement: true, index: index),
            onChanged: (index, entry) => _updateResumeEntry(
              achievement: true,
              index: index,
              entry: entry,
            ),
          ),
          _ResumeField(
            label: "Languages",
            hint: "One per line",
            controller: _resumeLanguagesController,
            maxLength: 180,
            maxLines: 3,
          ),
          _ResumeField(
            label: "References",
            hint:
                "Optional. Add names, roles, email/phone, or write: Available on request.",
            controller: _resumeReferencesController,
            maxLength: 350,
            maxLines: 4,
          ),
          const Spacing(height: 10),
          LabelButton(
            height: 56,
            width: double.infinity,
            text: "Build Resume",
            enabled: true,
            onTap: _saveResume,
          ),
        ],
      ),
    );
  }

  Widget _buildResumePreview(_ResumeDraft draft) {
    return Padding(
      key: const ValueKey("resume-preview"),
      padding: const EdgeInsets.only(bottom: 120),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controlsHeight = 66.0;
          final availableHeight = math.max(
            120.0,
            constraints.maxHeight - controlsHeight,
          );

          return Column(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: availableHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: _ResumePreviewSheet(draft: draft),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LabelButton(
                      height: 54,
                      width: double.infinity,
                      text: "Edit",
                      enabled: true,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _showResumePreview = false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LabelButton(
                      height: 54,
                      width: double.infinity,
                      text: "Save PDF",
                      enabled: true,
                      onTap: _saveResumePdf,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoScreen(String career) {
    _syncInfoControllers();

    return _buildSubScreen(
      title: "My info",
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EditableInfoField(
              label: "Name",
              hint: "Your name",
              controller: _infoNameController,
              onSubmitted: (value) => _saveInfoField("username", value),
            ),
            _EditableInfoField(
              label: "Stage",
              hint: "Highschool, university, working...",
              controller: _infoStageController,
              onSubmitted: (value) => _saveInfoField("stage", value),
            ),
            _EditableInfoField(
              label: "Career",
              hint: "Career you are building toward",
              controller: _infoCareerController,
              onSubmitted: (value) => _saveInfoField("career", value),
            ),
            _EditableInfoField(
              label: "Style",
              hint: "Planner, builder, creative...",
              controller: _infoStyleController,
              onSubmitted: (value) => _saveInfoField("style", value),
            ),
            const SizedBox(height: 8),
            Text(
              "Interests (${selectedAoiNotifier.value.length}/10)",
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: NavioTheme.textMuted(alpha: 0.46),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<String>>(
              valueListenable: selectedAoiNotifier,
              builder: (context, aois, _) {
                final canAdd = aois.length < 10;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (aois.isEmpty)
                      Text(
                        "Not selected yet",
                        style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontSize: 13,
                          color: NavioTheme.textMuted(alpha: 0.42),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: aois
                            .map(
                              (aoi) => _InfoChip(
                                label: aoi,
                                onRemove: () => _removeInterest(aoi),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoInlineInput(
                            controller: _interestController,
                            hint: canAdd
                                ? "Add an interest..."
                                : "Interest limit reached",
                            enabled: canAdd,
                            onSubmitted: (_) => _addInterest(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: canAdd ? _addInterest : null,
                          child: AnimatedContainer(
                            duration: NavioTheme.normal,
                            width: 46,
                            height: 46,
                            decoration: NavioTheme.surfaceDecoration(
                              active: canAdd,
                              disabled: !canAdd,
                              radius: NavioTheme.radiusMedium,
                              border: false,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: canAdd
                                  ? NavioTheme.accent
                                  : NavioTheme.textMuted(alpha: 0.24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsScreen(String career) {
    final hasCareer = career.trim().isNotEmpty;
    final child = !hasCareer
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: _buildSkillsCareerRequired(),
          )
        : _skills.isEmpty
        ? _buildSkillsLoading()
        : _hasSkillAssessment
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: _buildSkillResults(),
          )
        : _buildSkillAssessment(career);

    return _buildSubScreen(
      title: "Skills",
      trailing: _hasSkillAssessment
          ? Text(
              "${_skillAverage().toStringAsFixed(1)}/5",
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 12,
                color: NavioTheme.textMuted(alpha: 0.46),
              ),
            )
          : null,
      child: child,
    );
  }

  Widget _buildSkillsCareerRequired() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 80, 4, 0),
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
              "Your skill map is based on the career you want to build toward.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 13,
                color: NavioTheme.textMuted(alpha: 0.46),
                height: 1.5,
              ),
            ),
            const Spacing(height: 24),
            LabelButton(
              height: 56,
              width: double.infinity,
              text: "Open Career Finder",
              enabled: true,
              onTap: () {
                HapticFeedback.lightImpact();
                selectedNavIndexNotifier.value = 0;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsLoading() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          "Preparing your skill map...",
          style: TextStyle(
            fontFamily: "SF-Pro",
            color: NavioTheme.textMuted(alpha: 0.46),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillAssessment(String career) {
    final index = _skillAssessmentIndex.clamp(0, _skills.length - 1).toInt();
    final skill = _skills[index];
    final isLast = index == _skills.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        final questionFontSize = compact ? 20.0 : 24.0;
        final ratingNumberSize = compact ? 34.0 : 40.0;
        final ratingPadding = compact
            ? const EdgeInsets.fromLTRB(14, 12, 14, 10)
            : const EdgeInsets.fromLTRB(16, 15, 16, 12);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${index + 1} of ${_skills.length}",
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: NavioTheme.textMuted(alpha: 0.46),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (index + 1) / _skills.length),
                duration: NavioTheme.slow,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 4,
                    backgroundColor: NavioTheme.textMuted(alpha: 0.12),
                    color: NavioTheme.accent,
                  );
                },
              ),
            ),
            AnimatedSwitcher(
              duration: NavioTheme.slow,
              layoutBuilder: (currentChild, previousChildren) {
                return currentChild ?? const SizedBox.shrink();
              },
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              child: _buildSkillQuestionBody(
                key: ValueKey("${skill.label}-$index"),
                context: context,
                skill: skill,
                index: index,
                isLast: isLast,
                compact: compact,
                questionFontSize: questionFontSize,
                ratingNumberSize: ratingNumberSize,
                ratingPadding: ratingPadding,
              ),
            ),
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildSkillQuestionBody({
    required Key key,
    required BuildContext context,
    required _SkillItem skill,
    required int index,
    required bool isLast,
    required bool compact,
    required double questionFontSize,
    required double ratingNumberSize,
    required EdgeInsets ratingPadding,
  }) {
    return KeyedSubtree(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: compact ? 18 : 26),
          Text(
            skill.prompt,
            style: TextStyle(
              fontFamily: "New-York",
              fontSize: questionFontSize,
              color: NavioTheme.textPrimary(alpha: 0.92),
              height: 1.14,
            ),
          ),
          const SizedBox(height: 8),
          AutoScaleText(
            skill.label,
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NavioTheme.textSecondary(alpha: 0.62),
            ),
          ),
          SizedBox(height: compact ? 20 : 28),
          Container(
            width: double.infinity,
            padding: ratingPadding,
            decoration: NavioTheme.surfaceDecoration(active: true, glow: true),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: NavioTheme.normal,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    "${skill.score}",
                    key: ValueKey("${skill.label}-${skill.score}"),
                    style: TextStyle(
                      fontFamily: "New-York",
                      fontSize: ratingNumberSize,
                      color: NavioTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: NavioTheme.normal,
                  child: Text(
                    _skillLevelLabel(skill.score),
                    key: ValueKey(_skillLevelLabel(skill.score)),
                    style: TextStyle(
                      fontFamily: "SF-Pro",
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NavioTheme.textSecondary(alpha: 0.68),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 12 : 16),
                _buildSkillSlider(index, skill),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New",
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: 12,
                        color: NavioTheme.textMuted(alpha: 0.38),
                      ),
                    ),
                    Text(
                      "Strong",
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: 12,
                        color: NavioTheme.textMuted(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: LabelButton(
                  height: 54,
                  width: double.infinity,
                  text: "Back",
                  enabled: index > 0,
                  onTap: _previousSkillQuestion,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabelButton(
                  height: 54,
                  width: double.infinity,
                  text: isLast ? "Save" : "Next",
                  enabled: true,
                  onTap: _nextSkillQuestion,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillSlider(int index, _SkillItem skill) {
    final value = skill.score.toDouble();
    final platform = defaultTargetPlatform;
    final useCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (useCupertino) {
      return CupertinoSlider(
        min: 1,
        max: 5,
        divisions: 4,
        value: value,
        onChanged: (nextValue) => _updateSkillScore(index, nextValue),
        onChangeEnd: (_) => HapticFeedback.selectionClick(),
      );
    }

    return Slider(
      min: 1,
      max: 5,
      divisions: 4,
      value: value,
      onChanged: (nextValue) => _updateSkillScore(index, nextValue),
      onChangeEnd: (_) => HapticFeedback.selectionClick(),
    );
  }

  String _skillLevelLabel(int score) {
    switch (score) {
      case 1:
        return "Just starting";
      case 2:
        return "Some exposure";
      case 3:
        return "Comfortable basics";
      case 4:
        return "Confident";
      case 5:
        return "Strong";
      default:
        return "Comfortable basics";
    }
  }

  Widget _buildSkillResults() {
    final strong = _skills.where((skill) => skill.score >= 4).toList();
    final gaps = _skills.where((skill) => skill.score < skill.target).toList()
      ..sort((a, b) => a.score.compareTo(b.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkillsRadarCard(skills: _skills),
        const Spacing(height: 16),
        _SkillSection(
          title: "Strong skills",
          emptyText: "Nothing is marked strong yet. Retake when you improve.",
          children: strong
              .map(
                (skill) => _SkillChip(label: "${skill.label} ${skill.score}/5"),
              )
              .toList(),
        ),
        const Spacing(height: 14),
        _SkillSection(
          title: "Skill gaps",
          emptyText: "No major gaps. Keep building proof of progress.",
          children: gaps
              .take(4)
              .map(
                (skill) => _SkillGapTile(
                  skill: skill,
                  onImprove: () => _improveSkill(skill),
                ),
              )
              .toList(),
        ),
        const Spacing(height: 14),
        LabelButton(
          height: 56,
          width: double.infinity,
          text: "Retake assessment",
          enabled: true,
          onTap: _retakeSkillAssessment,
        ),
      ],
    );
  }

  double _skillAverage() {
    if (_skills.isEmpty) return 0;
    final total = _skills.fold<int>(0, (sum, skill) => sum + skill.score);
    return total / _skills.length;
  }

  void _improveSkill(_SkillItem skill) {
    final career = careerTitleNotifier.value.isNotEmpty
        ? careerTitleNotifier.value
        : careerNotifier.value;
    final prompt =
        "How can I improve ${skill.label} for $career? Give me 3 practical steps I can do this week.";

    HapticFeedback.lightImpact();
    simulatorSeedPromptNotifier.value = "";
    simulatorSeedPromptNotifier.value = prompt;
    showPlanNotifier.value = false;
    selectedNavIndexNotifier.value = 2;
  }

  Widget _buildTodoScreen() {
    final remaining = _todos.where((todo) => !todo.isDone).length;

    return _buildSubScreen(
      title: "Tasks",
      trailing: Text(
        "$remaining left",
        style: TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 12,
          color: NavioTheme.textMuted(alpha: 0.46),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: NavioTheme.surfaceDecoration(
                      radius: NavioTheme.radiusMedium,
                      border: false,
                    ),
                    child: TextField(
                      controller: _todoController,
                      maxLength: 80,
                      onSubmitted: (_) => _addTodo(),
                      style: TextStyle(
                        fontFamily: "SF-Pro",
                        fontSize: 14,
                        color: NavioTheme.textPrimary(),
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Add a next step...",
                        hintStyle: TextStyle(
                          color: NavioTheme.textMuted(alpha: 0.42),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _TaskSquareButton(
                  icon: Icons.add_rounded,
                  enabled: _hasTodoText,
                  onTap: _addTodo,
                ),
                const SizedBox(width: 8),
                _TaskSquareButton(
                  icon: Icons.auto_awesome_rounded,
                  enabled: !_isGeneratingTasks,
                  isLoading: _isGeneratingTasks,
                  onTap: _generateMoreTasks,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_todos.isEmpty)
              _EmptyTodoState()
            else
              Column(
                children: [
                  for (var i = 0; i < _todos.length; i++)
                    _TodoTile(
                      todo: _todos[i],
                      onToggle: () => _toggleTodo(i),
                      onDelete: () => _deleteTodo(i),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetScreen() {
    return _buildSubScreen(
      title: "Reset",
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This clears onboarding, saved career, roadmap cache, simulator chat, and your local tasks.",
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 14,
                color: NavioTheme.textSecondary(alpha: 0.68),
                height: 1.5,
              ),
            ),
            const Spacing(height: 18),
            _PortfolioButton(
              icon: Icons.close_rounded,
              title: "Cancel",
              subtitle: "Keep everything",
              onTap: () => setState(() => _section = _PortfolioSection.home),
            ),
            const SizedBox(height: 10),
            _PortfolioButton(
              icon: Icons.warning_amber_rounded,
              title: "Confirm reset",
              subtitle: "Clear saved progress",
              onTap: resetPrefs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScreen({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _goHome,
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
            ?trailing,
          ],
        ),
        const Spacing(height: 22),
        Text(title, style: const TextStyle(fontSize: 30)),
        const Spacing(height: 24),
        const LineSeparator(),
        const Spacing(height: 22),
        Expanded(child: child),
      ],
    );
  }

  void _goHome() {
    HapticFeedback.selectionClick();
    setState(() => _section = _PortfolioSection.home);
  }

  Future<void> resetPrefs() async {
    await AppStorage.resetAll();
    setState(() => _section = _PortfolioSection.home);
  }

  String getTimeOfDay() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) return "morning";
    if (hour >= 12 && hour < 17) return "afternoon";
    return "evening";
  }
}

