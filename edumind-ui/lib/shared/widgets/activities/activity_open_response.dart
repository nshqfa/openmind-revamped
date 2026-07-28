/// Shared open-response question widget — accepts [QuestionData]./// Uses keyword-based matching against acceptable answers from OpenResponseData.library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../../question_types/question_models.dart';

class ActivityOpenResponse extends StatefulWidget {
  const ActivityOpenResponse({
    super.key,
    required this.question,
    required this.accent,
    required this.onCorrect,
  });

  final QuestionData question;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityOpenResponse> createState() => _ActivityOpenResponseState();
}

class _ActivityOpenResponseState extends State<ActivityOpenResponse> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool? _isCorrect;
  bool _showResult = false;
  int _attemptCount = 0;
  int _hintIndex = -1;

  static String _normalise(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

  static List<String> _extractNumbers(String s) {
    return RegExp(r'(?:^|[^\w])(\d+(?:\.\d+)?)(?=[^\w]|$)')
        .allMatches(s).map((m) => m.group(1)!).toList();
  }

  static List<String> _extractWords(String s) {
    return s.split(RegExp('r[\s,.;:!?()\[\]{}"\'\/-]+'))
        .where((w) => w.length >= 2).map(_normalise).where((w) => w.isNotEmpty).toList();
  }

  bool _checkMatch(String response) {
    final normResp = _normalise(response);
    if (normResp.isEmpty) return false;

    final data = widget.question.openResponseData;
    if (data == null) return false;

    final respNumbers = _extractNumbers(normResp);
    final respWords = _extractWords(normResp);

    for (final answer in data.acceptableAnswers) {
      final normAnswer = _normalise(answer);
      final answerNumbers = _extractNumbers(normAnswer);
      final answerWords = _extractWords(normAnswer);

      if (answerNumbers.isNotEmpty && respNumbers.isNotEmpty) {
        if (answerNumbers.any((n) => respNumbers.any((rn) => rn == n))) return true;
      }
      if (answerWords.isNotEmpty && respWords.isNotEmpty) {
        final overlap = answerWords.where((w) => respWords.contains(w)).length;
        final threshold = (answerWords.length * 0.3).ceil().clamp(1, 999);
        if (overlap >= threshold) return true;
      }
      if (normAnswer.length >= 3 && normResp.contains(normAnswer)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 4,
            minLines: 2,
            textDirection: TextDirection.rtl,
            readOnly: _showResult,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: _showResult
                  ? (_isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellowInk)
                  : MiddlePalette.blueInk,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب إجابتك هنا ...',
              hintStyle: TextStyle(fontSize: 14, color: MiddlePalette.body.withValues(alpha: 0.5)),
              alignLabelWithHint: true,
              filled: true,
              fillColor: _showResult
                  ? (_isCorrect! ? MiddlePalette.success.withValues(alpha: 0.06) : MiddlePalette.retryYellowSoft)
                  : MiddlePalette.softBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                borderSide: BorderSide(
                  color: _showResult
                      ? (_isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellow)
                      : MiddlePalette.outline,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                borderSide: BorderSide(
                  color: _showResult
                      ? (_isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellow)
                      : MiddlePalette.outline,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                borderSide: BorderSide(color: widget.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          if (!_showResult)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _controller.text.trim().isEmpty ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: MiddlePalette.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: const Text('تحقق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
          ),
          if (_showResult) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          if (_showResult && !_isCorrect! && _hintIndex >= 0) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],
          if (_showResult && !_isCorrect!) ...[
            const SizedBox(height: 12),
            _retryButton(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submit() {
    final response = _controller.text;
    if (response.trim().isEmpty) return;

    final matched = _checkMatch(response);

    setState(() {
      _attemptCount++;
      _isCorrect = matched;
      _showResult = true;
    });

    if (matched) {
      final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.question.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onCorrect(xp);
      });
    } else {
      _hintIndex = (_attemptCount - 1).clamp(0, widget.question.hints.length - 1);
    }
  }

  Widget _promptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MiddlePalette.card,
        border: Border.all(color: MiddlePalette.outline),
        borderRadius: BorderRadius.circular(Palette.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.promptAr,
            style: const TextStyle(fontSize: 16, height: 1.7, fontWeight: FontWeight.w600, color: MiddlePalette.blueInk),
          ),
          if (widget.question.prompt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.prompt,
              style: const TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.body),
            ),
          ],
        ],
      ),
    );
  }

  Widget _feedbackCard() {
    if (_isCorrect!) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: MiddlePalette.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(Palette.radiusButton)),
        child: const Row(children: [
          Icon(Icons.check_circle_rounded, size: 20, color: MiddlePalette.success),
          SizedBox(width: 8),
          Expanded(child: Text('إجابة صحيحة! 🎉', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MiddlePalette.success))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: MiddlePalette.retryYellowSoft, borderRadius: BorderRadius.circular(Palette.radiusButton)),
      child: const Row(children: [
        Icon(Icons.refresh_rounded, size: 20, color: MiddlePalette.retryYellowInk),
        SizedBox(width: 8),
        Expanded(child: Text('ليس تماماً — حاول مرة أخرى!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MiddlePalette.retryYellowInk))),
      ]),
    );
  }

  Widget _hintCard() {
    if (_hintIndex < 0 || _hintIndex >= widget.question.hints.length) return const SizedBox();
    final hint = widget.question.hints[_hintIndex];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: MiddlePalette.softBlue, borderRadius: BorderRadius.circular(Palette.radiusButton)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: MiddlePalette.blueInk),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('تلميح:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MiddlePalette.body)),
            Text(hint.textAr.isNotEmpty ? hint.textAr : hint.text, style: TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.blueInk)),
          ])),
        ],
      ),
    );
  }

  Widget _retryButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: () => setState(() { _showResult = false; _isCorrect = null; _controller.clear(); _focusNode.requestFocus(); }),
        style: OutlinedButton.styleFrom(
          foregroundColor: MiddlePalette.retryYellowInk,
          side: BorderSide(color: MiddlePalette.retryYellow),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Palette.radiusButton)),
        ),
        child: const Text('حاول مجدداً', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
