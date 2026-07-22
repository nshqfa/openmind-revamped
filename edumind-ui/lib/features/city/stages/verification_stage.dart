/// Stage 6: التحقق (Verification) — checkpoint quiz with 2-3 questions.
/// The learner must score ≥ 70% to pass and complete the mission.
library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../../../widgets/mascot.dart';
import '../city_models.dart';
import '../city_progress_store.dart';

class VerificationStage extends StatefulWidget {
  const VerificationStage({super.key, required this.mission, required this.onComplete});

  final CityMission mission;
  final VoidCallback onComplete;

  @override
  State<VerificationStage> createState() => _VerificationStageState();
}

class _VerificationStageState extends State<VerificationStage> {
  final List<int?> _answers = []; // null = unanswered
  bool _submitted = false;
  int _correctCount = 0;
  bool _passed = false;

  List<CheckpointQuestion> get _questions => widget.mission.primarySkill.checkpointQuestions;

  @override
  void initState() {
    super.initState();
    _answers.addAll(List.filled(_questions.length, null));
  }

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
                  '${_answers.where((a) => a != null).length}/${_questions.length}',
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
              onPressed: _answers.every((a) => a != null) ? _submit : null,
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
    final accent = Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

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
          // Question number
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
          // Answer input
          if (q.type == 'choice') ...[
            for (var i = 0; i < q.options.length; i++)
              _optionTile(index, i, q.options[i]),
          ] else
            _numericInput(index),
        ],
      ),
    );
  }

  Widget _optionTile(int qIndex, int optIndex, String label) {
    final selected = _answers[qIndex] == optIndex;
    final accent = Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: () {
            setState(() => _answers[qIndex] = optIndex);
          },
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

  Widget _numericInput(int qIndex) {
    final controller = TextEditingController(
      text: _answers[qIndex] != null ? '${_answers[qIndex]}' : '',
    );
    final accent = Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

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
          setState(() => _answers[qIndex] = num.toInt());
        }
      },
    );
  }

  void _submit() {
    // Grade each question
    _correctCount = 0;
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final answer = _answers[i]!;
      final correct = q.correctAnswer;

      bool isCorrect;
      if (q.type == 'choice') {
        isCorrect = answer == correct;
      } else {
        // numeric_input: check with tolerance
        final numAnswer = (answer as num).toDouble();
        final numCorrect = (correct as num).toDouble();
        isCorrect = (numAnswer - numCorrect).abs() <= 0.5;
      }
      if (isCorrect) _correctCount++;
    }

    final score = _correctCount / _questions.length;
    _passed = score >= 0.7;

    setState(() => _submitted = true);
  }

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
                Text(
                  _passed ? '🎉' : '💪',
                  style: const TextStyle(fontSize: 56),
                ),
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