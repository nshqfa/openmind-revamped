/// Choice activity widget — shows a prompt and 4 option buttons.
/// Highlights the selected option, shows correct/wrong feedback, and awards XP.
library;

import 'package:flutter/material.dart';

import '../../../../core/middle_palette.dart';
import '../../../../core/palette.dart';
import '../city_models.dart';

class ActivityChoice extends StatefulWidget {
  const ActivityChoice({
    super.key,
    required this.activity,
    required this.accent,
    required this.onCorrect,
  });

  final CityActivity activity;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityChoice> createState() => _ActivityChoiceState();
}

class _ActivityChoiceState extends State<ActivityChoice> {
  int? _selected;
  bool? _isCorrect;
  int _attemptCount = 0;
  int _hintIndex = -1;

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
          const SizedBox(height: 16),
          // Options
          for (var i = 0; i < widget.activity.options.length; i++)
            _optionTile(i, widget.activity.options[i]),
          // Feedback
          if (_isCorrect != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          // Hint
          if (_isCorrect == false && _hintIndex >= 0 && _hintIndex < widget.activity.hints.length) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _optionTile(int index, String label) {
    final selected = _selected == index;
    final isAnswer = widget.activity.correctAnswer == index;
    final showResult = _isCorrect != null;

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (showResult && selected && _isCorrect!) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.08);
      textColor = MiddlePalette.success;
    } else if (showResult && selected && !_isCorrect!) {
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
      textColor = MiddlePalette.retryYellowInk;
    } else if (showResult && isAnswer && !_isCorrect!) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.06);
      textColor = MiddlePalette.success;
    } else if (selected) {
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.08);
      textColor = widget.accent;
    } else {
      borderColor = MiddlePalette.outline;
      bgColor = MiddlePalette.card;
      textColor = MiddlePalette.blueInk;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: _isCorrect != null ? null : () => _pick(index),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? borderColor : Colors.transparent,
                    border: Border.all(color: borderColor),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Text(
                          isAnswer && _isCorrect == true ? '✓' : isAnswer && _isCorrect == false ? '' : _isCorrect == true ? '✓' : '✗',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
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

  void _pick(int index) {
    final correct = index == widget.activity.correctAnswer;
    setState(() {
      _selected = index;
      _attemptCount++;
      _isCorrect = correct;
    });

    if (correct) {
      // XP: 1st attempt 100%, 2nd 70%, 3rd+ 50%
      final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.activity.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onCorrect(xp);
      });
    } else {
      // Show hint
      final hintLevel = _attemptCount.clamp(0, widget.activity.hints.length - 1);
      setState(() => _hintIndex = hintLevel);
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
