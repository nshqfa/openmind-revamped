/// Stage 6: التحقق (Verification) — checkpoint quiz with 2-3 questions.
/// The learner must score ≥ 70% to pass and complete the mission.
///
/// Supports all 7 question types: choice, drag_drop, spin, connect,
/// numeric_input, tap_image, open_response.
library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../../../widgets/mascot.dart';
import '../city_models.dart';
import '../city_progress_store.dart';
import '../../../shared/widgets/mascot_animation.dart';


class VerificationStage extends StatefulWidget {
  const VerificationStage({super.key, required this.mission, required this.onComplete});

  final CityMission mission;
  final VoidCallback onComplete;

  @override
  State<VerificationStage> createState() => _VerificationStageState();
}

class _VerificationStageState extends State<VerificationStage> {
  /// Answers per question — type varies by question type:
  ///   choice → int (option index)
  ///   numeric_input → double
  ///   drag_drop → Map<String, String> (slotId → itemId)
  ///   spin → int (segment index)
  ///   connect → Map<String, String> (leftId → rightId)
  ///   tap_image → Set<int> (selected indices)
  ///   open_response → String
  final List<dynamic> _answers = [];
  bool _submitted = false;
  int _correctCount = 0;
  bool _passed = false;

  /// Text controllers for open_response and numeric_input questions.
  final Map<int, TextEditingController> _textControllers = {};

  List<CheckpointQuestion> get _questions => widget.mission.primarySkill.checkpointQuestions;

  @override
  void initState() {
    super.initState();
    _answers.addAll(List.filled(_questions.length, null));
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Color _accent() =>
      Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

  bool _isAnswered(int index) {
    final a = _answers[index];
    if (a == null) return false;
    if (a is Map) return a.isNotEmpty;
    if (a is Set) return a.isNotEmpty;
    if (a is String) return a.trim().isNotEmpty;
    return true; // int, double — always answered once set
  }

  int get _answeredCount => _questions.asMap().keys.where(_isAnswered).length;

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _resultView();
    return _quizView();
  }

  Widget _quizView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MiddlePalette.primaryAction.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: Row(
              children: [
                const Text('✅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'التحقق من الفهم',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MiddlePalette.primaryAction,
                    ),
                  ),
                ),
                Text(
                  '$_answeredCount/${_questions.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Questions list
          Expanded(
            child: ListView.separated(
              itemCount: _questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _questionCard(index),
            ),
          ),
          const SizedBox(height: 12),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _answeredCount == _questions.length ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: MiddlePalette.primaryAction,
                foregroundColor: Colors.white,
                disabledBackgroundColor: MiddlePalette.outline,
                disabledForegroundColor: MiddlePalette.body,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Palette.radiusButton),
                ),
                elevation: 0,
              ),
              child: const Text(
                'تسجيل الإجابات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _questionCard(int index) {
    final q = _questions[index];
    final accent = _accent();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiddlePalette.card,
        border: Border.all(color: MiddlePalette.outline),
        borderRadius: BorderRadius.circular(Palette.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'سؤال ${index + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Prompt
          Text(
            q.promptAr,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: MiddlePalette.blueInk,
            ),
          ),
          const SizedBox(height: 12),
          // Answer input — routes to the right widget per type
          _buildAnswerWidget(index, q),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(int index, CheckpointQuestion q) {
    return switch (q.type) {
      'choice' => _choiceOptions(index, q),
      'numeric_input' => _numericInputField(index),
      'drag_drop' => _dragDropSlots(index, q),
      'spin' => _spinOptions(index, q),
      'connect' => _connectOptions(index, q),
      'tap_image' => _tapImageRegions(index, q),
      'open_response' => _openResponseField(index),
      _ => _choiceOptions(index, q),
    };
  }

  // ── Choice ────────────────────────────────────────────────────────────────

  Widget _choiceOptions(int qIndex, CheckpointQuestion q) {
    return Column(
      children: [
        for (var i = 0; i < q.options.length; i++)
          _optionTile(qIndex, i, q.options[i]),
      ],
    );
  }

  Widget _optionTile(int qIndex, int optIndex, String label) {
    final selected = _answers[qIndex] == optIndex;
    final accent = _accent();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: () => setState(() => _answers[qIndex] = optIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? accent : MiddlePalette.outline,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : Colors.transparent,
                    border: Border.all(
                      color: selected ? accent : MiddlePalette.outline,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? accent : MiddlePalette.blueInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Numeric Input ──────────────────────────────────────────────────────────

  Widget _numericInputField(int qIndex) {
    _textControllers.putIfAbsent(qIndex, () => TextEditingController());
    final controller = _textControllers[qIndex]!;
    final accent = _accent();

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: MiddlePalette.blueInk,
      ),
      decoration: InputDecoration(
        hintText: 'اكتب الإجابة',
        hintStyle: TextStyle(
          fontSize: 14,
          color: MiddlePalette.body.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: MiddlePalette.softBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          borderSide: BorderSide(color: MiddlePalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          borderSide: BorderSide(color: MiddlePalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        final num = double.tryParse(value);
        if (num != null) {
          setState(() => _answers[qIndex] = num);
        }
      },
    );
  }

  // ── Drag & Drop (simplified: dropdown per slot) ────────────────────────────

  Widget _dragDropSlots(int qIndex, CheckpointQuestion q) {
    // For verification, use a simplified dropdown per slot since full D&D
    // is complex in a scrollable list. Shows items as chips, slots as dropdowns.
    final correctMap = q.correctAnswer is Map<String, dynamic>
        ? Map<String, dynamic>.from(q.correctAnswer as Map)
        : <String, dynamic>{};
    final slotIds = correctMap.keys.toList();
    final allItems = q.options.isNotEmpty
        ? q.options
        : correctMap.values.map((v) => v.toString()).toList();

    // Current selections
    final current = _answers[qIndex] is Map
        ? Map<String, String>.from(_answers[qIndex] as Map)
        : <String, String>{};

    final accent = _accent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available items as chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final item in allItems)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MiddlePalette.softBlue,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: MiddlePalette.outline),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MiddlePalette.blueInk,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Slots as tappable selectors
        for (final slotId in slotIds)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slotId,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.body,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in allItems)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!current.containsKey(slotId)) {
                              current[slotId] = item;
                            } else if (current[slotId] == item) {
                              current.remove(slotId);
                            } else {
                              current[slotId] = item;
                            }
                            _answers[qIndex] = Map<String, String>.from(current);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: current[slotId] == item
                                ? accent.withValues(alpha: 0.12)
                                : MiddlePalette.card,
                            borderRadius: BorderRadius.circular(Palette.radiusButton),
                            border: Border.all(
                              color: current[slotId] == item
                                  ? accent
                                  : MiddlePalette.outline,
                              width: current[slotId] == item ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: current[slotId] == item
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: current[slotId] == item
                                  ? accent
                                  : MiddlePalette.blueInk,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Spin (select from segments) ───────────────────────────────────────────

  Widget _spinOptions(int qIndex, CheckpointQuestion q) {
    final selected = _answers[qIndex] as int?;
    final accent = _accent();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < q.options.length; i++)
          GestureDetector(
            onTap: () => setState(() => _answers[qIndex] = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected == i
                    ? accent.withValues(alpha: 0.12)
                    : MiddlePalette.card,
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                border: Border.all(
                  color: selected == i ? accent : MiddlePalette.outline,
                  width: selected == i ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected == i)
                    Icon(Icons.check_circle, size: 16, color: accent)
                  else
                    Icon(Icons.radio_button_unchecked, size: 16, color: MiddlePalette.outline),
                  const SizedBox(width: 8),
                  Text(
                    q.options[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected == i ? FontWeight.w700 : FontWeight.w500,
                      color: selected == i ? accent : MiddlePalette.blueInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Connect (match pairs) ─────────────────────────────────────────────────

  Widget _connectOptions(int qIndex, CheckpointQuestion q) {
    // Simplified for verification: show left items as labels, right items as
    // tappable selectors for each left item.
    final correctMap = q.correctAnswer is Map
        ? Map<String, dynamic>.from(q.correctAnswer as Map)
        : <String, dynamic>{};

    // Parse left/right items from options or correctAnswer
    final leftLabels = correctMap.keys.toList();
    final rightValues = correctMap.values.map((v) => v.toString()).toList();
    final allRightOptions = q.options.isNotEmpty
        ? q.options
        : rightValues.toSet().toList();

    // Current selections: leftIndex → rightValue
    final current = _answers[qIndex] is Map
        ? Map<int, String>.from(_answers[qIndex] as Map)
        : <int, String>{};

    final accent = _accent();

    return Column(
      children: [
        for (var li = 0; li < leftLabels.length; li++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left label
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: MiddlePalette.softBlue,
                      borderRadius: BorderRadius.circular(Palette.radiusButton),
                    ),
                    child: Text(
                      leftLabels[li],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MiddlePalette.blueInk,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(Icons.arrow_back_rounded, size: 18, color: MiddlePalette.body),
                ),
                const SizedBox(width: 8),
                // Right options
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final opt in allRightOptions)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (current[li] == opt) {
                                current.remove(li);
                              } else {
                                current[li] = opt;
                              }
                              _answers[qIndex] = Map<int, String>.from(current);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: current[li] == opt
                                  ? accent.withValues(alpha: 0.12)
                                  : MiddlePalette.card,
                              borderRadius: BorderRadius.circular(Palette.radiusButton),
                              border: Border.all(
                                color: current[li] == opt
                                    ? accent
                                    : MiddlePalette.outline,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: current[li] == opt
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: current[li] == opt
                                    ? accent
                                    : MiddlePalette.blueInk,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Tap Image (multi-select) ───────────────────────────────────────────────

  Widget _tapImageRegions(int qIndex, CheckpointQuestion q) {
    final selected = _answers[qIndex] is Set
        ? Set<int>.from(_answers[qIndex] as Set)
        : <int>{};
    final accent = _accent();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < q.options.length; i++)
          GestureDetector(
            onTap: () {
              setState(() {
                if (selected.contains(i)) {
                  selected.remove(i);
                } else {
                  selected.add(i);
                }
                _answers[qIndex] = Set<int>.from(selected);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected.contains(i)
                    ? accent.withValues(alpha: 0.12)
                    : MiddlePalette.card,
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                border: Border.all(
                  color: selected.contains(i) ? accent : MiddlePalette.outline,
                  width: selected.contains(i) ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected.contains(i)
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color: selected.contains(i) ? accent : MiddlePalette.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    q.options[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected.contains(i) ? FontWeight.w700 : FontWeight.w500,
                      color: selected.contains(i) ? accent : MiddlePalette.blueInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Open Response ──────────────────────────────────────────────────────────

  Widget _openResponseField(int qIndex) {
    _textControllers.putIfAbsent(qIndex, () => TextEditingController());
    final controller = _textControllers[qIndex]!;
    final accent = _accent();

    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 2,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: MiddlePalette.blueInk,
      ),
      decoration: InputDecoration(
        hintText: 'اكتب إجابتك هنا ...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: MiddlePalette.body.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: MiddlePalette.softBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          borderSide: BorderSide(color: MiddlePalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          borderSide: BorderSide(color: MiddlePalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      onChanged: (value) {
        setState(() => _answers[qIndex] = value);
      },
    );
  }

  // ── Grading ────────────────────────────────────────────────────────────────

  void _submit() {
    _correctCount = 0;
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final answer = _answers[i];
      final correct = q.correctAnswer;

      final isCorrect = _gradeQuestion(q, answer, correct);
      if (isCorrect) _correctCount++;
    }

    final score = _correctCount / _questions.length;
    _passed = score >= 0.7;

    setState(() => _submitted = true);
  }

  bool _gradeQuestion(CheckpointQuestion q, dynamic answer, dynamic correct) {
    switch (q.type) {
      case 'choice':
        // answer is int (selected index), correct is int or string
        if (answer is int && correct is int) return answer == correct;
        if (answer is int && correct is String) {
          return q.options.length > answer && q.options[answer] == correct;
        }
        return false;

      case 'numeric_input':
        if (answer is num && correct is num) {
          return (answer.toDouble() - correct.toDouble()).abs() <= 0.5;
        }
        return false;

      case 'spin':
        // answer is int (segment index), correct is int or string (correctIndex/segment)
        if (answer is int && correct is int) return answer == correct;
        return false;

      case 'drag_drop':
        // answer is Map<String, String>, correct is Map
        if (answer is Map && correct is Map) {
          final aMap = answer.map((k, v) => MapEntry(k.toString(), v.toString()));
          final cMap = correct.map((k, v) => MapEntry(k.toString(), v.toString()));
          if (aMap.length != cMap.length) return false;
          for (final key in cMap.keys) {
            if (aMap[key] != cMap[key]) return false;
          }
          return true;
        }
        return false;

      case 'connect':
        // answer is Map<int, String>, correct is Map
        if (answer is Map && correct is Map) {
          // Compare values match
          final aValues = answer.values.map((v) => v.toString()).toSet();
          final cValues = correct.values.map((v) => v.toString()).toSet();
          // All correct values must be matched
          return aValues.containsAll(cValues) && aValues.length == cValues.length;
        }
        return false;

      case 'tap_image':
        // answer is Set<int>, correct is determined by which options are correct
        // For verification, we use a simple heuristic: check against correctAnswer
        if (answer is Set) {
          if (correct is List<int>) {
            return answer.containsAll(correct) && answer.length == correct.length;
          }
          if (correct is List<bool>) {
            final correctIndices = <int>[];
            for (var j = 0; j < correct.length; j++) {
              if (correct[j] == true) correctIndices.add(j);
            }
            return answer.containsAll(correctIndices) && answer.length == correctIndices.length;
          }
        }
        return false;

      case 'open_response':
        // Lenient keyword matching
        if (answer is String) {
          final normAnswer = answer.trim().toLowerCase();
          if (normAnswer.isEmpty) return false;
          if (correct is List) {
            for (final acceptable in correct) {
              final normAcceptable = acceptable.toString().trim().toLowerCase();
              if (normAnswer.contains(normAcceptable)) return true;
            }
            // Check for number overlap
            final answerNums = RegExp(r'\d+').allMatches(normAnswer).map((m) => m.group(0)!).toSet();
            for (final acceptable in correct) {
              final accNums = RegExp(r'\d+').allMatches(acceptable.toString()).map((m) => m.group(0)!).toSet();
              if (accNums.isNotEmpty && answerNums.containsAll(accNums)) return true;
            }
            return false;
          }
          if (correct is String) {
            return normAnswer.contains(correct.toLowerCase()) ||
                RegExp(r'\d+').allMatches(normAnswer).map((m) => m.group(0)!).toSet().intersection(
                    RegExp(r'\d+').allMatches(correct).map((m) => m.group(0)!).toSet()).isNotEmpty;
          }
        }
        return false;

      default:
        return false;
    }
  }

  // ── Result View ───────────────────────────────────────────────────────────

  Widget _resultView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _passed
                  ? MiddlePalette.success.withValues(alpha: 0.06)
                  : MiddlePalette.retryYellowSoft,
              border: Border.all(
                color: _passed
                    ? MiddlePalette.success.withValues(alpha: 0.4)
                    : MiddlePalette.retryYellow,
              ),
              borderRadius: BorderRadius.circular(Palette.radiusCard),
            ),
            child: Column(
              children: [
                const MascotAnimation(name: 'thinking', repeat: true, height: 100),
                const SizedBox(height: 16),
                Text(
                  _passed ? 'أحسنت! نجحت في التحقق!' : 'لم تصل للعتبة بعد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _passed ? MiddlePalette.success : MiddlePalette.retryYellowInk,
                  ),
                ),
                const SizedBox(height: 12),
                // Score bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _correctCount / _questions.length,
                          minHeight: 10,
                          color: _passed ? MiddlePalette.success : MiddlePalette.retryYellow,
                          backgroundColor: MiddlePalette.softBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$_correctCount/${_questions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _passed ? MiddlePalette.success : MiddlePalette.retryYellowInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'الحد الأدنى للنجاح: ٧٠%',
                  style: TextStyle(
                    fontSize: 12,
                    color: MiddlePalette.body,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          if (_passed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MiddlePalette.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'إكمال المهمة ✓',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submitted = false;
                    _correctCount = 0;
                    _answers.fillRange(0, _answers.length, null);
                    for (final c in _textControllers.values) {
                      c.clear();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MiddlePalette.retryYellowInk,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'حاول مجدداً',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
