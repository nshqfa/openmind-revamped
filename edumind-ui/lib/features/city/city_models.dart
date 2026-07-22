/// Data models for مدينة لا تنهار (Unshakable City) — the Dart twin of the
/// backend's seed_city_content.ts structures.
///
/// These models describe the 6 missions, each with 6 stages, training + application
/// activities, and a checkpoint quiz. Content is Arabic-first.
library;

import 'dart:convert';

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
    required this.options,
    required this.correctAnswer,
    required this.hints,
    required this.xpReward,
  });

  final String id;
  final String activityType; // 'choice' | 'numeric_input'
  final String prompt;
  final String promptAr;
  final List<String> options; // for choice; empty for numeric_input
  final dynamic correctAnswer; // int for correctIndex, num for numeric value
  final List<BilingualText> hints;
  final int xpReward;
}

// ─── Checkpoint ────────────────────────────────────────────────────────────────

class CheckpointQuestion {
  CheckpointQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.promptAr,
    required this.correctAnswer,
    required this.options,
  });

  final String id;
  final String type; // 'choice' | 'numeric_input'
  final String prompt;
  final String promptAr;
  final dynamic correctAnswer;
  final List<String> options;
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
