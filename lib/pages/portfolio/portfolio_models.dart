part of 'portfolio_home.dart';

class _ResumeDraft {
  final String name;
  final String headline;
  final String email;
  final String phone;
  final String location;
  final String summary;
  final String skills;
  final String experience;
  final String education;
  final String achievements;
  final String languages;
  final String references;
  final List<_ResumeEntry> experienceEntries;
  final List<_ResumeEntry> achievementEntries;

  const _ResumeDraft({
    this.name = "",
    this.headline = "",
    this.email = "",
    this.phone = "",
    this.location = "",
    this.summary = "",
    this.skills = "",
    this.experience = "",
    this.education = "",
    this.achievements = "",
    this.languages = "",
    this.references = "",
    this.experienceEntries = const [],
    this.achievementEntries = const [],
  });

  bool get hasContent {
    return [
          summary,
          skills,
          experience,
          education,
          achievements,
          languages,
          references,
        ].any((value) => value.trim().isNotEmpty) ||
        experienceEntries.any((entry) => entry.hasContent) ||
        achievementEntries.any((entry) => entry.hasContent);
  }

  factory _ResumeDraft.fromJson(Map<dynamic, dynamic> json) {
    final legacyExperience = json['experience']?.toString() ?? "";
    final legacyAchievements = json['achievements']?.toString() ?? "";
    final experienceEntries = _ResumeEntry.fromJsonList(
      json['experienceEntries'],
    );
    final achievementEntries = _ResumeEntry.fromJsonList(
      json['achievementEntries'],
    );

    return _ResumeDraft(
      name: json['name']?.toString() ?? "",
      headline: json['headline']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      phone: json['phone']?.toString() ?? "",
      location: json['location']?.toString() ?? "",
      summary: json['summary']?.toString() ?? "",
      skills: json['skills']?.toString() ?? "",
      experience: legacyExperience,
      education: json['education']?.toString() ?? "",
      achievements: legacyAchievements,
      languages: json['languages']?.toString() ?? "",
      references: json['references']?.toString() ?? "",
      experienceEntries: experienceEntries.isNotEmpty
          ? experienceEntries
          : _ResumeEntry.fromLegacyLines(legacyExperience),
      achievementEntries: achievementEntries.isNotEmpty
          ? achievementEntries
          : _ResumeEntry.fromLegacyLines(legacyAchievements),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'headline': headline,
    'email': email,
    'phone': phone,
    'location': location,
    'summary': summary,
    'skills': skills,
    'experience': experience,
    'education': education,
    'achievements': achievements,
    'languages': languages,
    'references': references,
    'experienceEntries': experienceEntries
        .map((entry) => entry.toJson())
        .toList(),
    'achievementEntries': achievementEntries
        .map((entry) => entry.toJson())
        .toList(),
  };
}

class _ResumeEntry {
  final String title;
  final String organization;
  final String dates;
  final String details;

  const _ResumeEntry({
    this.title = "",
    this.organization = "",
    this.dates = "",
    this.details = "",
  });

  bool get hasContent {
    return [
      title,
      organization,
      dates,
      details,
    ].any((value) => value.trim().isNotEmpty);
  }

  _ResumeEntry copyWith({
    String? title,
    String? organization,
    String? dates,
    String? details,
  }) {
    return _ResumeEntry(
      title: title ?? this.title,
      organization: organization ?? this.organization,
      dates: dates ?? this.dates,
      details: details ?? this.details,
    );
  }

  List<String> detailLines() {
    return details
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> toPreviewLines() {
    return [
      title,
      organization,
      dates,
      ...detailLines(),
    ].where((value) => value.trim().isNotEmpty).toList();
  }

  factory _ResumeEntry.fromJson(Map<dynamic, dynamic> json) {
    return _ResumeEntry(
      title: json['title']?.toString() ?? "",
      organization: json['organization']?.toString() ?? "",
      dates: json['dates']?.toString() ?? "",
      details: json['details']?.toString() ?? "",
    );
  }

  static List<_ResumeEntry> fromJsonList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map(_ResumeEntry.fromJson)
        .where((entry) => entry.hasContent)
        .toList();
  }

  static List<_ResumeEntry> fromLegacyLines(String value) {
    return value
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => _ResumeEntry(title: line))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'organization': organization,
    'dates': dates,
    'details': details,
  };
}


class _TodoItem {
  final String title;
  final String kind;
  bool isDone;

  _TodoItem({
    required this.title,
    this.kind = _todoKindNormal,
    this.isDone = false,
  });

  factory _TodoItem.fromJson(Map<dynamic, dynamic> json) {
    return _TodoItem(
      title: json['title']?.toString() ?? "",
      kind: json['kind']?.toString() ?? _todoKindNormal,
      isDone: json['isDone'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'kind': kind,
    'isDone': isDone,
  };
}

class _SkillItem {
  final String label;
  final String prompt;
  final int target;
  int score;

  _SkillItem({
    required this.label,
    required this.prompt,
    this.score = 3,
    this.target = 4,
  });

  factory _SkillItem.fromJson(Map<dynamic, dynamic> json) {
    final score = int.tryParse(json['score']?.toString() ?? "") ?? 3;
    final target = int.tryParse(json['target']?.toString() ?? "") ?? 4;

    return _SkillItem(
      label: json['label']?.toString() ?? "Skill",
      prompt: json['prompt']?.toString() ?? "Rate your current experience.",
      score: score.clamp(1, 5).toInt(),
      target: target.clamp(1, 5).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'prompt': prompt,
    'score': score,
    'target': target,
  };
}

