/// Progress store for مدينة لا تنهار — SharedPreferences-backed, mirrors
/// the backend's node progression state machine (locked → available →
/// in_progress → completed).
///
/// Local-first: works offline, syncs with the backend when available.
/// Follows the same pattern as LearnProgressStore.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'city_models.dart';

class CityProgressStore {
  CityProgressStore._(this._prefs);
  static CityProgressStore? _instance;
  static const _key = 'cityMissionProgress';

  final SharedPreferences _prefs;

  /// Bumped whenever progress changes so screens can react.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Future<CityProgressStore> load() async {
    _instance ??= CityProgressStore._(await SharedPreferences.getInstance());
    return _instance!;
  }

  // ─── Progress map ─────────────────────────────────────────────────────────────

  Map<int, MissionProgress> get allProgress {
    final raw = _prefs.getString(_key);
    if (raw == null) return _defaultProgress();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final result = <int, MissionProgress>{};
    for (final entry in map.entries) {
      final id = int.tryParse(entry.key);
      if (id != null) {
        result[id] = MissionProgress.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    return result;
  }

  MissionProgress? getProgress(int missionId) => allProgress[missionId];

  int get totalXp {
    var total = 0;
    for (final p in allProgress.values) {
      total += p.xpEarned;
    }
    return total;
  }

  Future<void> saveProgress(Map<int, MissionProgress> progress) async {
    final map = <String, dynamic>{};
    for (final entry in progress.entries) {
      map['${entry.key}'] = entry.value.toJson();
    }
    await _prefs.setString(_key, jsonEncode(map));
    revision.value++;
  }

  Future<void> updateMission(MissionProgress progress) async {
    final all = allProgress;
    all[progress.missionId] = progress;
    await saveProgress(all);
  }

  /// Initialize default progress: mission 1 available, rest locked.
  Map<int, MissionProgress> _defaultProgress() {
    return {
      for (var i = 1; i <= 6; i++)
        i: MissionProgress(
          missionId: i,
          status: i == 1 ? NodeStatus.available : NodeStatus.locked,
        ),
    };
  }

  /// Reset all city progress (for testing).
  Future<void> reset() async {
    await _prefs.remove(_key);
    revision.value++;
  }

  /// Count completed missions.
  int get completedCount {
    return allProgress.values.where((p) => p.status == NodeStatus.completed).length;
  }

  /// Percentage complete (0–100).
  int get completionPercent => ((completedCount / 6) * 100).round();
}
