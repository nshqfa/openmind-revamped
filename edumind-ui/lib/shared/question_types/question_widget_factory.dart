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

/// Callback when the learner provides an answer.
typedef QuestionAnswerCallback = void Function(bool isCorrect, int xp);

/// A stateless factory that routes to the correct question widget based on
/// [QuestionData.type]. The returned widget is self-contained and handles all
/// interaction, feedback, and XP logic internally.
///
/// Each question widget receives:
///   - [QuestionData]: the question payload (prompt, options, correct answer, hints, etc.)
///   - [Color]: the accent color for the current context (path/mission color)
///   - [QuestionAnswerCallback]: called once the learner gets the answer correct
class QuestionWidgetFactory {
  QuestionWidgetFactory._();

  /// Build the correct widget for [questionData].
  static Widget build({
    required QuestionData questionData,
    required Color accent,
    required QuestionAnswerCallback onAnswer,
  }) {
    // For now, build a generic question widget that renders based on type.
    // In the city feature, the dedicated activity widgets are used directly.
    // This factory is the shared entry point for non-city features.
    return _GenericQuestionWidget(
      data: questionData,
      accent: accent,
      onAnswer: onAnswer,
    );
  }
}

/// A generic question widget that renders any of the 7 question types.
/// This is the "outside city" renderer — city uses its dedicated widgets.
class _GenericQuestionWidget extends StatefulWidget {
  const _GenericQuestionWidget({
    required this.data,
    required this.accent,
    required this.onAnswer,
  });

  final QuestionData data;
  final Color accent;
  final QuestionAnswerCallback onAnswer;

  @override
  State<_GenericQuestionWidget> createState() => _GenericQuestionWidgetState();
}

class _GenericQuestionWidgetState extends State<_GenericQuestionWidget> {
  // ── State per type ──
  int? _choiceSelection;
  final _numericController = TextEditingController();
  final _openResponseController = TextEditingController();
  final Set<int> _tapSelections = {};
  final Map<String, String> _dragDropPlacements = {};
  int? _spinSelection;
  final Map<String, String> _connectPairs = {};

  bool? _isCorrect;
  bool _showResult = false;
  int _attemptCount = 0;
  int _hintIndex = -1;

  bool get _hasAnswer {
    switch (widget.data.type) {
      case QuestionType.choice:
        return _choiceSelection != null;
      case QuestionType.numericInput:
        return _numericController.text.isNotEmpty;
      case QuestionType.tapImage:
        return _tapSelections.isNotEmpty;
      case QuestionType.dragDrop:
        return _dragDropPlacements.length >= (widget.data.dragDropData?.slots.length ?? 1);
      case QuestionType.spin:
        return _spinSelection != null;
      case QuestionType.connect:
        return _connectPairs.length >= (widget.data.connectData?.leftItems.length ?? 1);
      case QuestionType.openResponse:
        return _openResponseController.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    _numericController.dispose();
    _openResponseController.dispose();
    super.dispose();
  }

  void _submit() {
    bool correct = false;

    switch (widget.data.type) {
      case QuestionType.choice:
        correct = _choiceSelection == widget.data.correctIndex;
        break;
      case QuestionType.numericInput:
        final input = double.tryParse(_numericController.text);
        final target = (widget.data.correctAnswer as num?)?.toDouble();
        if (input != null && target != null) {
          correct = (input - target).abs() <= widget.data.numericTolerance;
        }
        break;
      case QuestionType.tapImage:
        final correctIndices = _getCorrectTapIndices();
        correct = _tapSelections.containsAll(correctIndices) &&
            _tapSelections.length == correctIndices.length;
        break;
      case QuestionType.dragDrop:
        final data = widget.data.dragDropData;
        if (data != null) {
          for (final slot in data.slots) {
            if (_dragDropPlacements[slot.id] != slot.correctItemId) {
              correct = false;
              break;
            }
            correct = true;
          }
        }
        break;
      case QuestionType.spin:
        final data = widget.data.spinData;
        if (data != null) {
          final correctIdx = data.wheelSegments.indexWhere(
            (s) => s.id == data.correctSegmentId,
          );
          correct = _spinSelection == correctIdx;
        }
        break;
      case QuestionType.connect:
        final data = widget.data.connectData;
        if (data != null) {
          for (final pair in data.correctPairs) {
            if (_connectPairs[pair.leftId] != pair.rightId) {
              correct = false;
              break;
            }
            correct = true;
          }
        }
        break;
      case QuestionType.openResponse:
        correct = _checkOpenResponse();
        break;
    }

    setState(() {
      _attemptCount++;
      _isCorrect = correct;
      _showResult = true;
    });

    if (correct) {
      final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.data.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 600), () {
        widget.onAnswer(true, xp);
      });
    } else {
      _hintIndex = (_attemptCount - 1).clamp(0, widget.data.hints.length - 1);
    }
  }

  Set<int> _getCorrectTapIndices() {
    final data = widget.data.tapImageData;
    if (data != null) {
      return data.regions
          .asMap()
          .entries
          .where((e) => e.value.isCorrect)
          .map((e) => e.key)
          .toSet();
    }
    return {};
  }

  bool _checkOpenResponse() {
    final response = _openResponseController.text.trim().toLowerCase();
    if (response.isEmpty) return false;

    final data = widget.data.openResponseData;
    if (data == null) return false;

    for (final acceptable in data.acceptableAnswers) {
      if (response.contains(acceptable.toLowerCase())) return true;
    }

    // Number overlap check
    final respNums = RegExp(r'\d+(?:\.\d+)?').allMatches(response).map((m) => m.group(0)!).toSet();
    for (final acceptable in data.acceptableAnswers) {
      final accNums = RegExp(r'\d+(?:\.\d+)?').allMatches(acceptable).map((m) => m.group(0)!).toSet();
      if (accNums.isNotEmpty && respNums.containsAll(accNums)) return true;
    }

    return false;
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _isCorrect = null;
      _choiceSelection = null;
      _numericController.clear();
      _openResponseController.clear();
      _tapSelections.clear();
      _dragDropPlacements.clear();
      _spinSelection = null;
      _connectPairs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 16),
          _answerInput(),
          const SizedBox(height: 12),
          if (!_showResult && _hasAnswer)
            _submitButton(),
          if (_showResult) ...[
            _feedbackCard(),
            if (!_isCorrect! && _hintIndex >= 0) _hintCard(),
            if (!_isCorrect!) _retryButton(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _promptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0),
        border: Border.all(color: const Color(0xFFD9D9D0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data.promptAr,
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A3A5C),
            ),
          ),
          if (widget.data.prompt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.data.prompt,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF5C6370),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerInput() {
    switch (widget.data.type) {
      case QuestionType.choice:
        return _choiceOptions();
      case QuestionType.numericInput:
        return _numericField();
      case QuestionType.tapImage:
        return _tapRegions();
      case QuestionType.dragDrop:
        return _dragDropUI();
      case QuestionType.spin:
        return _spinOptions();
      case QuestionType.connect:
        return _connectUI();
      case QuestionType.openResponse:
        return _openResponseField();
    }
  }

  Widget _choiceOptions() => Column(
    children: [
      for (var i = 0; i < widget.data.options.length; i++)
        _selectableTile(
          label: widget.data.options[i],
          selected: _choiceSelection == i,
          onTap: () => setState(() => _choiceSelection = i),
        ),
    ],
  );

  Widget _numericField() => TextField(
    controller: _numericController,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C)),
    decoration: InputDecoration(
      hintText: 'اكتب الإجابة',
      filled: true,
      fillColor: const Color(0xFFEAF0F6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFD9D9D0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  Widget _tapRegions() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (var i = 0; i < widget.data.options.length; i++)
        GestureDetector(
          onTap: () => setState(() {
            if (_tapSelections.contains(i)) {
              _tapSelections.remove(i);
            } else {
              _tapSelections.add(i);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _tapSelections.contains(i)
                  ? widget.accent.withValues(alpha: 0.12)
                  : const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _tapSelections.contains(i) ? widget.accent : const Color(0xFFD9D9D0),
                width: _tapSelections.contains(i) ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _tapSelections.contains(i) ? Icons.check_box_rounded : Icons.check_box_outline_blank,
                  size: 20,
                  color: _tapSelections.contains(i) ? widget.accent : const Color(0xFFD9D9D0),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.data.options[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _tapSelections.contains(i) ? FontWeight.w700 : FontWeight.w500,
                    color: _tapSelections.contains(i) ? widget.accent : const Color(0xFF1A3A5C),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget _dragDropUI() {
    final data = widget.data.dragDropData;
    if (data == null) return const SizedBox();
    return Column(
      children: [
        // Items
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final item in data.items)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0F6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFD9D9D0)),
                ),
                child: Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Slots
        for (final slot in data.slots)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5C6370))),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in data.items)
                      GestureDetector(
                        onTap: () => setState(() {
                          if (_dragDropPlacements[slot.id] == item.id) {
                            _dragDropPlacements.remove(slot.id);
                          } else {
                            _dragDropPlacements[slot.id] = item.id;
                          }
                        }),
                        child: _selectableTile(
                          label: item.label,
                          selected: _dragDropPlacements[slot.id] == item.id,
                          onTap: () => setState(() {
                            if (_dragDropPlacements[slot.id] == item.id) {
                              _dragDropPlacements.remove(slot.id);
                            } else {
                              _dragDropPlacements[slot.id] = item.id;
                            }
                          }),
                        ),
                      ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _spinOptions() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (var i = 0; i < widget.data.options.length; i++)
        _selectableTile(
          label: widget.data.options[i],
          selected: _spinSelection == i,
          onTap: () => setState(() => _spinSelection = i),
        ),
    ],
  );

  Widget _connectUI() {
    final data = widget.data.connectData;
    if (data == null) return const SizedBox();
    return Column(
      children: [
        for (final left in data.leftItems) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEAF0F6), borderRadius: BorderRadius.circular(8)),
                    child: Text(left.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF5C6370)),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final right in data.rightItems)
                        GestureDetector(
                          onTap: () => setState(() {
                            if (_connectPairs[left.id] == right.id) {
                              _connectPairs.remove(left.id);
                            } else {
                              _connectPairs[left.id] = right.id;
                            }
                          }),
                          child: _selectableTile(
                            label: right.label,
                            selected: _connectPairs[left.id] == right.id,
                            onTap: () => setState(() {
                              if (_connectPairs[left.id] == right.id) {
                                _connectPairs.remove(left.id);
                              } else {
                                _connectPairs[left.id] = right.id;
                              }
                            }),
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

  Widget _openResponseField() => TextField(
    controller: _openResponseController,
    maxLines: 4,
    minLines: 2,
    textDirection: TextDirection.rtl,
    style: const TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w500, color: Color(0xFF1A3A5C)),
    decoration: InputDecoration(
      hintText: 'اكتب إجابتك هنا ...',
      filled: true,
      fillColor: const Color(0xFFEAF0F6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFD9D9D0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  Widget _selectableTile({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? widget.accent.withValues(alpha: 0.12) : const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? widget.accent : const Color(0xFFD9D9D0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? widget.accent : const Color(0xFF1A3A5C),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text('تحقق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
    ),
  );

  Widget _feedbackCard() => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _isCorrect! ? const Color(0xFFE6F4EA) : const Color(0xFFFDF2E9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          _isCorrect! ? Icons.check_circle_rounded : Icons.refresh_rounded,
          size: 20,
          color: _isCorrect! ? const Color(0xFF2E7D32) : const Color(0xFFE67E22),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _isCorrect! ? 'إجابة صحيحة! 🎉' : 'ليس تماماً — حاول مرة أخرى!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _isCorrect! ? const Color(0xFF2E7D32) : const Color(0xFFE67E22),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _hintCard() {
    if (_hintIndex < 0 || _hintIndex >= widget.data.hints.length) return const SizedBox();
    final hint = widget.data.hints[_hintIndex];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFF1A3A5C)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تلميح:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5C6370))),
                Text(hint.textAr.isNotEmpty ? hint.textAr : hint.text,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1A3A5C))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _retryButton() => SizedBox(
    width: double.infinity,
    height: 44,
    child: OutlinedButton(
      onPressed: _reset,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE67E22),
        side: const BorderSide(color: Color(0xFFE67E22)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('حاول مجدداً', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    ),
  );
}