import 'dart:convert';

import 'package:dio/dio.dart';

class ResumeGradingException implements Exception {
  final String message;

  const ResumeGradingException(this.message);

  @override
  String toString() => message;
}

class ResumeGradeRequest {
  final String resumeText;
  final String fileName;

  const ResumeGradeRequest({required this.resumeText, required this.fileName});

  Map<String, dynamic> toJson() => {
    'resumeText': resumeText,
    'fileName': fileName,
  };
}

class ResumeGradeReport {
  final int overallScore;
  final int? jobFitScore;
  final String summary;
  final List<String> strengths;
  final List<String> issues;
  final List<String> improvements;
  final List<ResumeRewriteSuggestion> rewriteSuggestions;
  final List<ResumeGradeBreakdownItem> breakdown;
  final List<String> atsNotes;

  const ResumeGradeReport({
    required this.overallScore,
    required this.jobFitScore,
    required this.summary,
    required this.strengths,
    required this.issues,
    required this.improvements,
    required this.rewriteSuggestions,
    required this.breakdown,
    required this.atsNotes,
  });

  factory ResumeGradeReport.fromJson(Map<dynamic, dynamic> json) {
    return ResumeGradeReport(
      overallScore: _score(json['overallScore']),
      jobFitScore: json['jobFitScore'] == null
          ? null
          : _score(json['jobFitScore']),
      summary: json['summary']?.toString() ?? "",
      strengths: _stringList(json['strengths']),
      issues: _stringList(json['issues']),
      improvements: _stringList(json['improvements']),
      rewriteSuggestions: _mapList(json['rewriteSuggestions'])
          .map(ResumeRewriteSuggestion.fromJson)
          .where((item) => !_isExtractionArtifactRewrite(item))
          .toList(),
      breakdown: _mapList(
        json['breakdown'],
      ).map(ResumeGradeBreakdownItem.fromJson).toList(),
      atsNotes: _stringList(json['atsNotes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'jobFitScore': jobFitScore,
    'summary': summary,
    'strengths': strengths,
    'issues': issues,
    'improvements': improvements,
    'rewriteSuggestions': rewriteSuggestions
        .map((item) => item.toJson())
        .toList(),
    'breakdown': breakdown.map((item) => item.toJson()).toList(),
    'atsNotes': atsNotes,
  };
}

class ResumeGradeHistoryItem {
  final String id;
  final String fileName;
  final String textPreview;
  final int? pageCount;
  final DateTime createdAt;
  final ResumeGradeReport report;

  const ResumeGradeHistoryItem({
    required this.id,
    required this.fileName,
    required this.textPreview,
    required this.pageCount,
    required this.createdAt,
    required this.report,
  });

  factory ResumeGradeHistoryItem.fromJson(Map<dynamic, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? "");
    final pageCount = int.tryParse(json['pageCount']?.toString() ?? "");

    return ResumeGradeHistoryItem(
      id: json['id']?.toString() ?? "",
      fileName: json['fileName']?.toString() ?? "resume.pdf",
      textPreview: json['textPreview']?.toString() ?? "",
      pageCount: pageCount,
      createdAt: createdAt ?? DateTime.now(),
      report: ResumeGradeReport.fromJson(
        json['report'] is Map ? json['report'] as Map : const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'textPreview': textPreview,
    'pageCount': pageCount,
    'createdAt': createdAt.toIso8601String(),
    'report': report.toJson(),
  };
}

class ResumeRewriteSuggestion {
  final String before;
  final String after;
  final String reason;

  const ResumeRewriteSuggestion({
    required this.before,
    required this.after,
    required this.reason,
  });

  factory ResumeRewriteSuggestion.fromJson(Map<dynamic, dynamic> json) {
    return ResumeRewriteSuggestion(
      before: json['before']?.toString() ?? "",
      after: json['after']?.toString() ?? "",
      reason: json['reason']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'before': before,
    'after': after,
    'reason': reason,
  };
}

class ResumeGradeBreakdownItem {
  final String label;
  final int score;
  final String note;

  const ResumeGradeBreakdownItem({
    required this.label,
    required this.score,
    required this.note,
  });

  factory ResumeGradeBreakdownItem.fromJson(Map<dynamic, dynamic> json) {
    return ResumeGradeBreakdownItem(
      label: json['label']?.toString() ?? "Resume quality",
      score: _score(json['score']),
      note: json['note']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'score': score,
    'note': note,
  };
}

class ResumeGradingService {
  static const String _baseUrl =
      'https://navio-worker.naviopathways.workers.dev';

  static const String _appToken = 'navio-pathways-v1';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 80),
      headers: {'Content-Type': 'application/json', 'X-Navio-App': _appToken},
    ),
  );

  Future<ResumeGradeReport> grade(ResumeGradeRequest request) async {
    try {
      final response = await _dio.post(
        '/api/resume-grade',
        data: request.toJson(),
      );
      final data = response.data;

      if (data is Map && data['report'] is Map) {
        return ResumeGradeReport.fromJson(data['report'] as Map);
      }

      throw const ResumeGradingException('Resume report was not readable.');
    } on DioException catch (error) {
      final data = error.response?.data;
      if (error.response?.statusCode == 404) {
        return _gradeViaChatFallback(request);
      }

      if (error.response?.statusCode == 429) {
        throw const ResumeGradingException(
          'Resume grading is busy. Please wait a minute and try again.',
        );
      }

      if (data is Map && data['error'] != null) {
        throw ResumeGradingException(data['error'].toString());
      }

      throw const ResumeGradingException(
        'Could not grade this resume right now.',
      );
    }
  }

  Future<ResumeGradeReport> _gradeViaChatFallback(
    ResumeGradeRequest request,
  ) async {
    final resumeText = _clipForFallback(request.resumeText, 5600);

    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': 'openai/gpt-oss-20b',
          'temperature': 0.2,
          'maxTokens': 1200,
          'messages': [
            {
              'role': 'system',
              'content': [
                'You are Navio Pathways, a career coach for students and early-career users.',
                'Grade resumes with specific, practical, encouraging feedback.',
                'Return JSON only. No markdown, no commentary outside the JSON object.',
                'Use this exact shape: {"overallScore":number,"jobFitScore":number|null,"summary":string,"strengths":string[],"issues":string[],"improvements":string[],"rewriteSuggestions":[{"before":string,"after":string,"reason":string}],"breakdown":[{"label":string,"score":number,"note":string}],"atsNotes":string[]}.',
                'This is a general resume review, so jobFitScore must be null.',
                'Assume the resume text may come from PDF extraction, so ignore casing, line breaks, missing spaces, pipes, punctuation, odd separators, and contact-format artifacts unless they clearly affect actual resume content.',
                'Rewrite suggestions must focus on content quality: stronger impact bullets, quantified outcomes, clearer summary, more specific skills, and stronger project or experience descriptions.',
                'Do not suggest capitalization, punctuation, comma, spacing, separator, or contact-format fixes.',
              ].join(' '),
            },
            {
              'role': 'user',
              'content': [
                'File name: ${request.fileName}',
                'Analyze mode: general resume quality only',
                'Resume text:',
                resumeText,
              ].join('\n\n'),
            },
          ],
        },
      );

      final data = response.data;
      if (data is Map && data['message'] is String) {
        return _reportFromProviderText(data['message'] as String);
      }

      throw const ResumeGradingException('Resume report was not readable.');
    } on DioException catch (error) {
      final data = error.response?.data;
      if (error.response?.statusCode == 429) {
        throw const ResumeGradingException(
          'Resume grading is busy. Please wait a minute and try again.',
        );
      }

      if (data is Map && data['error'] != null) {
        throw ResumeGradingException(data['error'].toString());
      }

      throw const ResumeGradingException(
        'Could not grade this resume right now.',
      );
    }
  }
}

String _clipForFallback(String value, int maxLength) {
  final clean = value.trim();
  if (clean.length <= maxLength) return clean;
  return clean.substring(0, maxLength).trimRight();
}

ResumeGradeReport _reportFromProviderText(String value) {
  final jsonText = _extractJsonObject(value);
  if (jsonText == null) {
    throw const ResumeGradingException('Resume report was not readable.');
  }

  final decoded = jsonDecode(jsonText);
  if (decoded is! Map) {
    throw const ResumeGradingException('Resume report was not readable.');
  }

  final report = ResumeGradeReport.fromJson(decoded);
  return ResumeGradeReport(
    overallScore: report.overallScore,
    jobFitScore: null,
    summary: report.summary,
    strengths: report.strengths,
    issues: report.issues,
    improvements: report.improvements,
    rewriteSuggestions: report.rewriteSuggestions,
    breakdown: report.breakdown,
    atsNotes: report.atsNotes,
  );
}

bool _isExtractionArtifactRewrite(ResumeRewriteSuggestion item) {
  final text = [item.before, item.after, item.reason].join(" ").toLowerCase();

  final artifactPatterns = [
    'capitalization',
    'proper capitalization',
    'punctuation',
    'comma',
    'commas',
    'spacing',
    'space',
    'separator',
    'separators',
    'format',
    'formatting',
    'standardize contact',
    'contact information format',
    'consistent use of',
  ];

  return artifactPatterns.any(text.contains);
}

String? _extractJsonObject(String value) {
  final fenced = RegExp(
    r'```(?:json)?\s*([\s\S]*?)\s*```',
    caseSensitive: false,
  ).firstMatch(value);
  final candidate = fenced?.group(1) ?? value;
  final start = candidate.indexOf('{');
  final end = candidate.lastIndexOf('}');

  if (start < 0 || end <= start) return null;
  return candidate.substring(start, end + 1);
}

int _score(dynamic value) {
  final parsed = int.tryParse(value?.toString() ?? "") ?? 0;
  return parsed.clamp(0, 100).toInt();
}

List<String> _stringList(dynamic value) {
  if (value is! List) return [];
  return value
      .map((item) => item?.toString().trim() ?? "")
      .where((item) => item.isNotEmpty)
      .toList();
}

List<Map<dynamic, dynamic>> _mapList(dynamic value) {
  if (value is! List) return [];
  return value.whereType<Map>().toList();
}
