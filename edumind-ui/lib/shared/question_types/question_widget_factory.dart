/// Generic question widget factory — resolves any of the 7 question types
/// into the appropriate interactive widget.
///
/// This factory is designed to be used ANYWHERE in the app that needs to
/// present questions: city path, learn path, placement tests, review mode, etc.
///
/// Usage:
///   ```dart
///   QuestionWidgetFactory.build(
///     questionData: myQuestionData,
///     accent: Colors.blue,
///     onAnswer: (isCorrect, xp) { ... },
///   )
///   ```
library;

import 'package:flutter/material.dart';

import 'question_models.dart';
import '../widgets/activities/activity_choice.dart';
import '../widgets/activities/activity_drag_drop.dart';
import '../widgets/activities/activity_spin.dart';
import '../widgets/activities/activity_connect.dart';
import '../widgets/activities/activity_numeric_input.dart';
import '../widgets/activities/activity_tap_image.dart';
import '../widgets/activities/activity_open_response.dart';

/// Callback when the learner provides an answer.
typedef QuestionAnswerCallback = void Function(bool isCorrect, int xp);

/// A stateless factory that routes to the correct question widget based on
/// [QuestionData.type]. Delegates to the polished, feature-complete activity
/// widgets in `shared/widgets/activities/`.
class QuestionWidgetFactory {
  QuestionWidgetFactory._();

  /// Build the correct widget for [questionData].
  static Widget build({
    required QuestionData questionData,
    required Color accent,
    required QuestionAnswerCallback onAnswer,
  }) {
    final onCorrect = (int xp) => onAnswer(true, xp);

    return switch (questionData.type) {
      QuestionType.choice => ActivityChoice(data: questionData, accent: accent, onCorrect: onCorrect),
      QuestionType.dragDrop => ActivityDragDrop(data: questionData, accent: accent, onCorrect: onCorrect),
      QuestionType.spin => ActivitySpin(data: questionData, accent: accent, onCorrect: onCorrect),
      QuestionType.connect => ActivityConnect(data: questionData, accent: accent, onCorrect: onCorrect),
      QuestionType.numericInput => ActivityNumericInput(data: questionData, accent: accent, onCorrect: onCorrect),
      QuestionType.tapImage => ActivityTapImage(data: questionData, accent: accent, onCorrect: onCorrect),
      QuestionType.openResponse => ActivityOpenResponse(data: questionData, accent: accent, onCorrect: onCorrect),
    };
  }
}