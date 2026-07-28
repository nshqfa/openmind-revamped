/// Data models for مدينة لا تنهار (Unshakable City) — the Dart twin of the
/// backend's seed_city_content.ts structures.
///
/// These models describe the 6 missions, each with 6 stages, training + application
/// activities, and a checkpoint quiz. Content is Arabic-first.
///
/// Supports all 7 question types: choice, drag_drop, spin, connect,
/// numeric_input, tap_image, open_response.
library;

import 'dart:convert';

// import '../../shared/question_types/question_models.dart' show QuestionType;
import '../../shared/question_types/question_models.dart' show QuestionType, QuestionData, BilingualHint, DragDropData, SpinData, ConnectData, TapImageData, OpenResponseData;
import '../../shared/question_types/question_models.dart' show QuestionType, QuestionData;

// ─── Mission ──────────────────────────────────────────────────────────────────

class CityMission {
  CityMission({
    required this.id,
    required this.conceptKey,
    required this.cityMission,
    required this.titleAr,
    required this.titleEn,
    required this.emoji,
    required this.colorHex,
    required this.scene,
    required this.discovery,
    required this.explanation,
    required this.skills,
  });

  final int id;
  final String conceptKey;
  final String cityMission;
  final String titleAr;
  final String titleEn;
  final String emoji;
  final String colorHex;

  final BilingualText scene;
  final BilingualText discovery;
  final BilingualText explanation;

  final List<CitySkill> skills;

  /// The single depth-0 skill (the one shown in the UI).
  CitySkill get primarySkill => skills.first;
}

class BilingualText {
  BilingualText({required this.en, required this.ar});
  final String en;
  final String ar;
}

// ─── Skill ─────────────────────────────────────────────────────────────────────

class CitySkill {
  CitySkill({
    required this.skillId,
    required this.depth,
    required this.title,
    required this.titleAr,
    required this.topic,
    required this.trainingActivities,
    required this.applicationActivity,
    required this.checkpointQuestions,
  });

  final String skillId;
  final int depth;
  final String title;
  final String titleAr;
  final String topic;
  final List<CityActivity> trainingActivities;
  final CityActivity applicationActivity;
  final List<CheckpointQuestion> checkpointQuestions;
}

// ─── Activity ──────────────────────────────────────────────────────────────────
class CityActivity {
  CityActivity({
    required this.id,
    required this.activityType,
    required this.prompt,
    required this.promptAr,
    this.options = const [],
    required this.correctAnswer,
    this.dataJson,
    this.correctionRulesJson,
    required this.hints,
    required this.xpReward,
    this.skillId,
  });

  final String id;
  final String activityType;
  final String prompt;
  final String promptAr;
  final List<String> options;
  final dynamic correctAnswer;
  final Map<String, dynamic>? dataJson;
  final Map<String, dynamic>? correctionRulesJson;
  final List<BilingualText> hints;
  final int xpReward;
  final String? skillId;

  QuestionType get questionType => QuestionType.fromString(activityType);

}

/// Convert this CityActivity to the shared [QuestionData] model.
  /// This properly parses [dataJson] for structured types (drag_drop, spin,
  /// connect, tap_image, open_response) and flattens hints.
  QuestionData toQuestionData() {
  

    final type = QuestionType.fromString(activityType);
    final data = dataJson ?? <String, dynamic>{};

    DragDropData? dragDropData;
    SpinData? spinData;
    ConnectData? connectData;
    TapImageData? tapImageData;
    OpenResponseData? openResponseData;

    if (data.containsKey('items') && data.containsKey('slots')) {
      dragDropData = DragDropData.fromMap(data);
    } else if (data.containsKey('wheelSegments')) {
      spinData = SpinData.fromMap(data);
    } else if (data.containsKey('leftItems') && data.containsKey('rightItems')) {
      connectData = ConnectData.fromMap(data);
    } else if (data.containsKey('regions')) {
      tapImageData = TapImageData.fromMap(data);
    } else if (data.containsKey('acceptableAnswers')) {
      openResponseData = OpenResponseData.fromMap(data);
    }

    final hints = hints.map((h) => BilingualHint(text: h.en, textAr: h.ar)).toList();

    // Derive options from dataJson if the options list is empty.
    List<String> resolvedOptions = List<String>.from(options);
    if (resolvedOptions.isEmpty) {
      if (tapImageData != null) {
        resolvedOptions = tapImageData!.regions.map((r) => r.label).toList();
      } else if (spinData != null) {
        resolvedOptions = spinData!.wheelSegments.map((s) => s.label).toList();
      } else if (dragDropData != null) {
        resolvedOptions = dragDropData!.items.map((i) => i.label).toList();
      } else if (connectData != null) {
        resolvedOptions = [
          ...connectData!.leftItems.map((i) => i.label),
          ...connectData!.rightItems.map((i) => i.label),
        ];
      }
    }

    return QuestionData(
      type: type,
      prompt: prompt,
      promptAr: promptAr,
      options: resolvedOptions,
      correctIndex: correctAnswer is int ? correctAnswer as int : null,
      correctAnswer: correctAnswer,
      dragDropData: dragDropData,
      spinData: spinData,
      connectData: connectData,
      tapImageData: tapImageData,
      openResponseData: openResponseData,
      hints: hints,
      xpReward: xpReward,
    );
        return QuestionData.fromCityActivity(
      activityType: activityType,
      prompt: prompt,
      promptAr: promptAr,
      options: options,
      correctAnswer: correctAnswer,
      dataJson: dataJson,
      hintsJson: hints
          .map((h) => {'text': h.en, 'textAr': h.ar})
          .toList(),
      correctionRulesJson: correctionRulesJson,
      xpReward: xpReward,
    );
  }

class CheckpointQuestion {
  CheckpointQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.promptAr,
    required this.correctAnswer,
    this.options = const [],
    this.errorPatterns,
  });

  final String id;
  final String type;
  final String prompt;
  final String promptAr;
  final dynamic correctAnswer;
  final List<String> options;
  final List<Map<String, dynamic>>? errorPatterns;

  QuestionType get questionType => QuestionType.fromString(type);
}

// ─── Stage definitions ─────────────────────────────────────────────────────────

class StageDef {
  const StageDef({
    required this.type,
    required this.title,
    required this.titleAr,
    required this.icon,
  });

  final String type; // scene | discovery | explanation | training | application | verification
  final String title;
  final String titleAr;
  final String icon;
}

const kStageDefs = [
  StageDef(type: 'scene', title: 'Scenario', titleAr: 'الموقف', icon: '📖'),
  StageDef(type: 'discovery', title: 'Discovery', titleAr: 'الاكتشاف', icon: '🔍'),
  StageDef(type: 'explanation', title: 'Explanation', titleAr: 'الشرح', icon: '💡'),
  StageDef(type: 'training', title: 'Training', titleAr: 'التدريب', icon: '🎯'),
  StageDef(type: 'application', title: 'Application', titleAr: 'تطبيق المدينة', icon: '🏗️'),
  StageDef(type: 'verification', title: 'Verification', titleAr: 'التحقق', icon: '✅'),
];

// ─── Progress ──────────────────────────────────────────────────────────────────

/// Mirrors the backend's NodeStatus progression:
///   locked → available → in_progress → completed
enum NodeStatus { locked, available, inProgress, completed }

class MissionProgress {
  MissionProgress({
    required this.missionId,
    this.status = NodeStatus.locked,
    this.currentStageIndex = 0,
    this.checkpointPassed = false,
    this.checkpointScore = 0.0,
    this.attemptsCount = 0,
    this.hintsUsed = 0,
    this.xpEarned = 0,
  });

  final int missionId;
  NodeStatus status;
  int currentStageIndex;
  bool checkpointPassed;
  double checkpointScore;
  int attemptsCount;
  int hintsUsed;
  int xpEarned;

  Map<String, dynamic> toJson() => {
    'missionId': missionId,
    'status': status.name,
    'currentStageIndex': currentStageIndex,
    'checkpointPassed': checkpointPassed,
    'checkpointScore': checkpointScore,
    'attemptsCount': attemptsCount,
    'hintsUsed': hintsUsed,
    'xpEarned': xpEarned,
  };

  factory MissionProgress.fromJson(Map<String, dynamic> m) => MissionProgress(
        missionId: m['missionId'] as int,
        status: NodeStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => NodeStatus.locked,
        ),
        currentStageIndex: (m['currentStageIndex'] as num?)?.toInt() ?? 0,
        checkpointPassed: (m['checkpointPassed'] as bool?) ?? false,
        checkpointScore: ((m['checkpointScore'] as num?) ?? 0.0).toDouble(),
        attemptsCount: (m['attemptsCount'] as num?)?.toInt() ?? 0,
        hintsUsed: (m['hintsUsed'] as num?)?.toInt() ?? 0,
        xpEarned: (m['xpEarned'] as num?)?.toInt() ?? 0,
      );
}
