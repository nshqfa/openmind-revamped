/// Shared question type models — used by City, Learn path, and any other
/// feature that presents interactive questions.
///
/// The 7 types mirror the backend's `QuestionType` union in types.ts:
///   choice, drag_drop, spin, connect, numeric_input, tap_image, open_response
library;

import 'dart:convert';

// ─── Question type enum ──────────────────────────────────────────────────────

/// All 7 question interaction types the app supports.
enum QuestionType {
  choice,
  dragDrop,
  spin,
  connect,
  numericInput,
  tapImage,
  openResponse;

  static QuestionType fromString(String value) => switch (value) {
        'choice' => QuestionType.choice,
        'drag_drop' => QuestionType.dragDrop,
        'spin' => QuestionType.spin,
        'connect' => QuestionType.connect,
        'numeric_input' => QuestionType.numericInput,
        'tap_image' => QuestionType.tapImage,
        'open_response' => QuestionType.openResponse,
        _ => QuestionType.choice,
      };

  String toBackendString() => switch (this) {
        QuestionType.choice => 'choice',
        QuestionType.dragDrop => 'drag_drop',
        QuestionType.spin => 'spin',
        QuestionType.connect => 'connect',
        QuestionType.numericInput => 'numeric_input',
        QuestionType.tapImage => 'tap_image',
        QuestionType.openResponse => 'open_response',
      };
}

// ─── Drag & Drop ─────────────────────────────────────────────────────────────

class DragDropItem {
  DragDropItem({required this.id, required this.label});
  final String id;
  final String label;

  static DragDropItem fromMap(Map<String, dynamic> m) => DragDropItem(
        id: m['id'] as String,
        label: m['label'] as String,
      );
}

class DragDropSlot {
  DragDropSlot({required this.id, required this.label, required this.correctItemId});
  final String id;
  final String label;
  final String correctItemId;

  static DragDropSlot fromMap(Map<String, dynamic> m) => DragDropSlot(
        id: m['id'] as String,
        label: m['label'] as String,
        correctItemId: m['correctItemId'] as String,
      );
}

class DragDropData {
  DragDropData({required this.items, required this.slots});
  final List<DragDropItem> items;
  final List<DragDropSlot> slots;

  static DragDropData fromMap(Map<String, dynamic> m) => DragDropData(
        items: (m['items'] as List)
            .map((i) => DragDropItem.fromMap(i as Map<String, dynamic>))
            .toList(),
        slots: (m['slots'] as List)
            .map((s) => DragDropSlot.fromMap(s as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Spin Wheel ─────────────────────────────────────────────────────────────

class WheelSegment {
  WheelSegment({required this.id, required this.label});
  final String id;
  final String label;

  static WheelSegment fromMap(Map<String, dynamic> m) => WheelSegment(
        id: m['id'] as String,
        label: m['label'] as String,
      );
}

class SpinData {
  SpinData({required this.wheelSegments, required this.correctSegmentId, this.explanation});
  final List<WheelSegment> wheelSegments;
  final String correctSegmentId;
  final String? explanation;

  static SpinData fromMap(Map<String, dynamic> m) => SpinData(
        wheelSegments: (m['wheelSegments'] as List)
            .map((w) => WheelSegment.fromMap(w as Map<String, dynamic>))
            .toList(),
        correctSegmentId: m['correctSegmentId'] as String,
        explanation: m['explanation'] as String?,
      );
}

// ─── Connect (Match Pairs) ──────────────────────────────────────────────────

class ConnectItem {
  ConnectItem({required this.id, required this.label});
  final String id;
  final String label;

  static ConnectItem fromMap(Map<String, dynamic> m) => ConnectItem(
        id: m['id'] as String,
        label: m['label'] as String,
      );
}

class CorrectPair {
  CorrectPair({required this.leftId, required this.rightId});
  final String leftId;
  final String rightId;

  static CorrectPair fromMap(Map<String, dynamic> m) => CorrectPair(
        leftId: m['leftId'] as String,
        rightId: m['rightId'] as String,
      );
}

class ConnectData {
  ConnectData({required this.leftItems, required this.rightItems, required this.correctPairs});
  final List<ConnectItem> leftItems;
  final List<ConnectItem> rightItems;
  final List<CorrectPair> correctPairs;

  static ConnectData fromMap(Map<String, dynamic> m) => ConnectData(
        leftItems: (m['leftItems'] as List)
            .map((i) => ConnectItem.fromMap(i as Map<String, dynamic>))
            .toList(),
        rightItems: (m['rightItems'] as List)
            .map((i) => ConnectItem.fromMap(i as Map<String, dynamic>))
            .toList(),
        correctPairs: (m['correctPairs'] as List)
            .map((p) => CorrectPair.fromMap(p as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Tap Image ───────────────────────────────────────────────────────────────

class TapRegion {
  TapRegion({required this.id, required this.label, required this.isCorrect});
  final String id;
  final String label;
  final bool isCorrect;

  static TapRegion fromMap(Map<String, dynamic> m) => TapRegion(
        id: m['id'] as String,
        label: m['label'] as String,
        isCorrect: m['isCorrect'] as bool,
      );
}

class TapImageData {
  TapImageData({required this.regions});
  final List<TapRegion> regions;

  static TapImageData fromMap(Map<String, dynamic> m) => TapImageData(
        regions: (m['regions'] as List)
            .map((r) => TapRegion.fromMap(r as Map<String, dynamic>))
            .toList(),
      );
}

// ─── Open Response ──────────────────────────────────────────────────────────

class OpenResponseData {
  OpenResponseData({required this.acceptableAnswers});
  final List<String> acceptableAnswers;

  static OpenResponseData fromMap(Map<String, dynamic> m) => OpenResponseData(
        acceptableAnswers:
            (m['acceptableAnswers'] as List).map((a) => a as String).toList(),
      );
}

// ─── Generic question data wrapper ────────────────────────────────────────────

/// Holds the type-specific payload for any of the 7 question types.
/// This is the shared shape that all features can parse from backend JSON.
class QuestionData {
  QuestionData({
    required this.type,
    required this.prompt,
    required this.promptAr,
    this.options = const [],
    this.correctIndex,
    this.correctAnswer,
    this.explanation,
    this.dragDropData,
    this.spinData,
    this.connectData,
    this.tapImageData,
    this.openResponseData,
    this.numericTolerance = 0.5,
    this.hints = const [],
    this.xpReward = 10,
  });

  final QuestionType type;
  final String prompt;
  final String promptAr;

  // choice
  final List<String> options;
  final int? correctIndex;

  // numeric_input
  final dynamic correctAnswer;
  final double numericTolerance;

  // Shared
  final String? explanation;
  final List<BilingualHint> hints;
  final int xpReward;

  // Type-specific data
  final DragDropData? dragDropData;
  final SpinData? spinData;
  final ConnectData? connectData;
  final TapImageData? tapImageData;
  final OpenResponseData? openResponseData;

  /// Parse from a backend JSON payload (used by city seed data, placement
  /// test questions, checkpoint questions, etc.).

factory QuestionData.fromJson(Map<String, dynamic> m) {
    final typeStr = m['type'] as String? ?? 'choice';
    final type = QuestionType.fromString(typeStr);

    // Extract type-specific data
    DragDropData? dragDropData;
    SpinData? spinData;
    ConnectData? connectData;
    TapImageData? tapImageData;
    OpenResponseData? openResponseData;

    if (type == QuestionType.dragDrop && m.containsKey('items') && m.containsKey('slots')) {
      dragDropData = DragDropData.fromMap(m);
    } else if (type == QuestionType.spin && m.containsKey('wheelSegments')) {
      spinData = SpinData.fromMap(m);
    } else if (type == QuestionType.connect && m.containsKey('leftItems')) {
      connectData = ConnectData.fromMap(m);
    } else if (type == QuestionType.tapImage && m.containsKey('regions')) {
      tapImageData = TapImageData.fromMap(m);
    }

    // Open-response: acceptable answers come from correctAnswer (list) or acceptableAnswers key.
    if (type == QuestionType.openResponse) {
      final answers = m['acceptableAnswers'] ??
          (m['correctAnswer'] is List ? m['correctAnswer'] : null);
      if (answers is List && answers.isNotEmpty) {
        openResponseData = OpenResponseData(
          acceptableAnswers: answers.map((a) => a as String).toList(),
        );
      }
    }

    // Parse hints — supports both `hintsJson` (list of maps) and `hints` (list of maps).
    final hints = <BilingualHint>[];
    final rawHints = m['hintsJson'] ?? m['hints'];
    if (rawHints != null) {
      for (final h in (rawHints as List)) {
        final map = h as Map;
        hints.add(BilingualHint(
          text: map['text'] as String? ?? map['en'] as String? ?? '',
          textAr: map['textAr'] as String? ?? map['ar'] as String? ?? '',
        ));
      }
    }

    // Numeric tolerance from correctionRulesJson or acceptableVariance.
    double tolerance = 0.5;
    if (m['acceptableVariance'] is num) {
      tolerance = (m['acceptableVariance'] as num).toDouble();
    } else if (m['correctionRulesJson'] is Map) {
      final rules = m['correctionRulesJson'] as Map;
      if (rules['tolerance'] is num) {
        tolerance = (rules['tolerance'] as num).toDouble();
      }
    }

    return QuestionData(
      type: type,
      prompt: m['prompt'] as String? ?? '',
      promptAr: m['promptAr'] as String? ?? '',
      options: (m['options'] as List?)?.map((o) => o as String).toList() ?? [],
      correctIndex: m['correctIndex'] is int ? m['correctIndex'] as int : null,
      correctAnswer: m['correctAnswer'] ?? m['value'],
      explanation: m['explanation'] as String?,
      dragDropData: dragDropData,
      spinData: spinData,
      connectData: connectData,
      tapImageData: tapImageData,
      openResponseData: openResponseData,
      numericTolerance: tolerance,
      hints: hints,
      xpReward: (m['xpReward'] as num?)?.toInt() ?? 10,
    );
  }

  /// Build from a CityActivity's raw fields.
  ///
  /// This avoids coupling shared/ to the city feature by accepting plain
  /// Dart types. The caller (CityActivity.toQuestionData) assembles the map.
  ///
  /// [activityType] — e.g. 'choice', 'drag_drop'
  /// [prompt] / [promptAr] — bilingual prompt
  /// [options] — flat option strings
  /// [correctAnswer] — type-correct answer (int, List, Map, …)
  /// [dataJson] — structured payload (items/slots, segments, regions, etc.)
  /// [hintsJson] — list of `{text, textAr}` maps
  /// [correctionRulesJson] — optional rules (e.g. `{'tolerance': 0}`)
  factory QuestionData.fromCityActivity({
    required String activityType,
    required String prompt,
    required String promptAr,
    required List<String> options,
    required dynamic correctAnswer,
    Map<String, dynamic>? dataJson,
    List<Map<String, String>>? hintsJson,
    Map<String, dynamic>? correctionRulesJson,
    int xpReward = 10,
  }) {
    // Merge CityActivity fields with dataJson so fromJson can pick up
    // structured keys (items, slots, wheelSegments, leftItems, regions…).
    final merged = <String, dynamic>{
      'type': activityType,
      'prompt': prompt,
      'promptAr': promptAr,
      'options': options,
      'correctAnswer': correctAnswer,
      'xpReward': xpReward,
    };

    if (dataJson != null) merged.addAll(dataJson);
    if (hintsJson != null) merged['hints'] = hintsJson;
    if (correctionRulesJson != null) {
      merged['correctionRulesJson'] = correctionRulesJson;
    }

    // For choice, expose correctIndex directly.
    if (activityType == 'choice' && correctAnswer is int) {
      merged['correctIndex'] = correctAnswer;
    }

    return QuestionData.fromJson(merged);
  }
}

/// A bilingual hint.
class BilingualHint {
  BilingualHint({required this.text, required this.textAr});
  final String text;
  final String textAr;
}
