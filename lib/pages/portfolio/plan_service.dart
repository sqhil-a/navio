import 'dart:convert';

import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:navio/app_storage.dart';
import 'package:navio/services/groq_service.dart';
import 'package:navio/services/plan.dart';
import 'package:navio/widgets/notifiers.dart';

const _planCacheKey = "cachedPlan";
const _resourcesCacheKey = "cachedResources";

class PlanService {
  final GroqService _groq = GroqService();

  Future<List<Map<String, String>>> loadOrGenerate() async {
    final cached = await AppStorage.loadString(_planCacheKey);
    if (cached != null && cached.isNotEmpty) return _parsePlan(cached);
    return generate();
  }

  Future<List<Map<String, String>>> generate() async {
    final result = await _groq.getPlan(
      career: careerNotifier.value,
      stage: stageNotifier.value,
      aois: selectedAoiNotifier.value,
      style: selectedStyleNotifier.value ?? "",
    );
    if (result == null) throw Exception("No response received.");
    final steps = _parsePlan(result);
    await AppStorage.saveString(_planCacheKey, result);
    return steps;
  }

  Future<List<Map<String, String>>> edit(String instruction) async {
    final current = await AppStorage.loadString(_planCacheKey) ?? "";
    if (current.isEmpty) throw Exception("No existing plan to edit.");
    final result = await _groq.editPlan(
      currentPlan: current,
      instruction: instruction,
    );
    if (result == null) throw Exception("No response received.");
    final steps = _parsePlan(result);
    await AppStorage.saveString(_planCacheKey, result);
    Haptics.vibrate(HapticsType.success);
    return steps;
  }

  Future<void> clearCache() => AppStorage.saveString(_planCacheKey, "");

  List<Map<String, String>> _parsePlan(String json) {
    final parsed = jsonDecode(json);
    if (parsed is! Map || !parsed.containsKey('steps')) {
      throw FormatException("Missing 'steps'.");
    }

    final list = parsed['steps'] as List;
    if (list.length != 4) {
      throw FormatException("Expected 4 steps, got ${list.length}.");
    }

    return list.map((s) {
      if (s['title'] == null || s['description'] == null) {
        throw FormatException("Step missing fields.");
      }

      return {
        'title': s['title'].toString(),
        'description': s['description'].toString(),
      };
    }).toList();
  }

  Future<List<Map<String, String>>> loadOrGenerateResources() async {
    final cached = await AppStorage.loadString(_resourcesCacheKey);
    if (cached != null && cached.isNotEmpty) return _parseResources(cached);
    return generateResources();
  }

  Future<List<Map<String, String>>> generateResources() async {
    final result = await _groq.getResources(
      career: careerNotifier.value,
      stage: stageNotifier.value,
    );
    if (result == null) throw Exception("No response received.");
    final resources = _parseResources(result);
    await AppStorage.saveString(_resourcesCacheKey, result);
    return resources;
  }

  Future<void> clearResourcesCache() =>
      AppStorage.saveString(_resourcesCacheKey, "");

  Future<List<String>> generateTasks({
    required List<Map<String, String>> roadmapSteps,
    required List<String> existingTasks,
  }) async {
    final result = await _groq.getTasks(
      career: careerNotifier.value,
      stage: stageNotifier.value,
      aois: selectedAoiNotifier.value,
      style: selectedStyleNotifier.value ?? "",
      roadmapSteps: roadmapSteps,
      existingTasks: existingTasks,
    );
    if (result == null) throw Exception("No response received.");
    return _parseTasks(result);
  }

  List<Map<String, String>> _parseResources(String json) {
    final parsed = jsonDecode(json);
    if (parsed is! Map || !parsed.containsKey('resources')) {
      throw FormatException("Missing 'resources'.");
    }

    final list = parsed['resources'] as List;
    if (list.length != 4) {
      throw FormatException("Expected 4 resources, got ${list.length}.");
    }

    return list.map((r) {
      if (r['title'] == null || r['url'] == null) {
        throw FormatException("Resource missing fields.");
      }

      return {'title': r['title'].toString(), 'url': r['url'].toString()};
    }).toList();
  }

  List<String> _parseTasks(String json) {
    Object parsed;
    try {
      parsed = jsonDecode(json);
    } catch (_) {
      final start = json.indexOf('{');
      final end = json.lastIndexOf('}');
      if (start == -1 || end <= start) {
        throw FormatException("Missing task JSON object.");
      }
      parsed = jsonDecode(json.substring(start, end + 1));
    }

    if (parsed is! Map || !parsed.containsKey('tasks')) {
      throw FormatException("Missing 'tasks'.");
    }

    final rawTasks = parsed['tasks'];
    if (rawTasks is! List) {
      throw FormatException("'tasks' must be a list.");
    }

    final list = rawTasks;
    if (list.length != 3) {
      throw FormatException("Expected 3 tasks, got ${list.length}.");
    }

    return list
        .map((task) => task.toString().trim())
        .where((task) => task.isNotEmpty)
        .toList();
  }
}
