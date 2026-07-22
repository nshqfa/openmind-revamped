/// Numeric input activity widget — shows a prompt and number input field.
/// Checks the answer server-style (with tolerance), shows feedback and hints.
library;

import 'package:flutter/material.dart';

import '../../../../core/middle_palette.dart';
import '../../../../core/palette.dart';
import '../city_models.dart';

class ActivityNumericInput extends StatefulWidget {
  const ActivityNumericInput({
    super.key,
    required this.activity,
    required this.accent,
    required this.onCorrect,
  });

  final CityActivity activity;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityNumericInput> createState() => _ActivityNumericInputState();
}

class _ActivityNumericInputState extends State<ActivityNumericInput> {
  final _controller = TextEditingController();
  bool? _isCorrect;
  bool _showResult = false;
  int _attemptCount = 0;
  int _hintIndex = -1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Prompt
          Container(
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
                  widget.activity.promptAr,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                    color: MiddlePalette.blueInk,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.activity.prompt,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: MiddlePalette.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Input field
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            readOnly: _showResult,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _showResult
                  ? (_isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellowInk)
                  : MiddlePalette.blueInk,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل الإجابة',
              hintStyle: TextStyle(
                fontSize: 16,
                color: MiddlePalette.body.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: _showResult
                  ? (_isCorrect!
                      ? MiddlePalette.success.withValues(alpha: 0.06)
                      : MiddlePalette.retryYellowSoft)
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
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          if (!_showResult)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _controller.text.isEmpty ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: MiddlePalette.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'تحقق',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          // Feedback
          if (_showResult) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          // Hint
          if (_showResult && !_isCorrect! && _hintIndex >= 0) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],
          // Retry button
          if (_showResult && !_isCorrect!) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showResult = false;
                    _isCorrect = null;
                    _controller.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: MiddlePalette.retryYellowInk,
                  side: BorderSide(color: MiddlePalette.retryYellow),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                ),
                child: const Text(
                  'حاول مجدداً',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submit() {
    final input = double.tryParse(_controller.text);
    if (input == null) return;

    final correct = (widget.activity.correctAnswer as num).toDouble();
    final isCorrect = (input - correct).abs() <= 0.5;

    setState(() {
      _attemptCount++;
      _isCorrect = isCorrect;
      _showResult = true;
    });

    if (isCorrect) {
      final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.activity.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onCorrect(xp);
      });
    } else {
      _hintIndex = (_attemptCount - 1).clamp(0, widget.activity.hints.length - 1);
    }
  }

  Widget _feedbackCard() {
    if (_isCorrect!) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MiddlePalette.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Palette.radiusButton),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: MiddlePalette.success),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'إجابة صحيحة! 🎉',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: MiddlePalette.success,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MiddlePalette.retryYellowSoft,
          borderRadius: BorderRadius.circular(Palette.radiusButton),
        ),
        child: Row(
          children: [
            Icon(Icons.refresh_rounded, size: 20, color: MiddlePalette.retryYellowInk),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ليس تماماً — حاول مرة أخرى!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: MiddlePalette.retryYellowInk,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _hintCard() {
    if (_hintIndex < 0 || _hintIndex >= widget.activity.hints.length) {
      return const SizedBox();
    }
    final hint = widget.activity.hints[_hintIndex];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MiddlePalette.softBlue,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: MiddlePalette.blueInk),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تلميح:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.body,
                  ),
                ),
                Text(
                  hint.ar,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: MiddlePalette.blueInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
