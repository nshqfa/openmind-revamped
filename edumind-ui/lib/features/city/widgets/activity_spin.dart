/// Spin-the-wheel activity widget — shows a prompt, a row of segment cards,
/// and a "Spin" button that slot-machine-cycles through the segments before
/// landing on one. Correct → green feedback + XP. Wrong → yellow + hint + retry.
library;

import 'package:flutter/material.dart';
import '../city_models.dart';
import '../../../shared/widgets/activities/activity_spin.dart' as shared;

class ActivitySpin extends StatelessWidget {
  const ActivitySpin({super.key, required this.activity, required this.accent, required this.onCorrect});
  final CityActivity activity;
  final Color accent;
  final ValueChanged<int> onCorrect;
  @override
  Widget build(BuildContext context) => shared.ActivitySpin(question: activity.toQuestionData(), accent: accent, onCorrect: onCorrect);
}

class _ActivitySpinState extends State<ActivitySpin> {
  /// The index currently highlighted by the spinning animation.
  /// -1 means no highlight (idle, or resolved with a different variable).
  int _highlightIndex = -1;

  /// The index the wheel landed on after spinning.
  int? _landedIndex;

  bool _isSpinning = false;
  bool? _isCorrect;
  int _attemptCount = 0;
  int _hintIndex = -1;

  Timer? _spinTimer;
  int _spinStep = 0;
  final _rng = Random();

  /// Segment colors — derived from the accent with varying hue shifts.
  late final List<Color> _segmentColors;

  @override
  void initState() {
    super.initState();
    _segmentColors = _buildSegmentColors();
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  // ── Color helpers ─────────────────────────────────────────────────────────

  List<Color> _buildSegmentColors() {
    final hsl = HSLColor.fromColor(widget.accent);
    return List.generate(widget.activity.options.length, (i) {
      final hue = (hsl.hue + i * (360 / widget.activity.options.length)) % 360;
      return HSLColor.fromAHSL(0.85, hue, 0.45, 0.92).toColor();
    });
  }

  // ── Spin logic ───────────────────────────────────────────────────────────

  void _startSpin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _isCorrect = null;
      _landedIndex = null;
      _spinStep = 0;
      _attemptCount++;
    });

    _spinTick();
  }

  void _spinTick() {
    // Initial interval 60 ms, grows by ~12 ms each step.
    const baseInterval = 60;
    const intervalGrowth = 12;
    const totalSteps = 18;

    if (_spinStep >= totalSteps) {
      // Determine landing index.
      final landed = _highlightIndex;
      _spinTimer?.cancel();
      _spinTimer = null;

      final correct = landed == widget.activity.correctAnswer;

      setState(() {
        _isSpinning = false;
        _landedIndex = landed;
        _isCorrect = correct;
      });

      if (correct) {
        final multiplier = _attemptCount <= 1
            ? 1.0
            : _attemptCount == 2
                ? 0.7
                : 0.5;
        final xp = (widget.activity.xpReward * multiplier).round();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onCorrect(xp);
        });
      } else {
        // Show hint
        final hintLevel =
            (_attemptCount - 1).clamp(0, widget.activity.hints.length - 1);
        setState(() => _hintIndex = hintLevel);
      }
      return;
    }

    // Pick a random index each tick.
    final optionsCount = widget.activity.options.length;
    var next = _rng.nextInt(optionsCount);
    // Avoid staying on the same index to create visible motion.
    if (optionsCount > 1) {
      while (next == _highlightIndex) {
        next = _rng.nextInt(optionsCount);
      }
    }

    setState(() => _highlightIndex = next);

    _spinStep++;
    final delay = baseInterval + (_spinStep * intervalGrowth);
    _spinTimer = Timer(Duration(milliseconds: delay), _spinTick);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Prompt
          _promptCard(),
          const SizedBox(height: 16),
          // Segment cards
          _segmentsGrid(),
          const SizedBox(height: 20),
          // Spin button
          _spinButton(),
          // Feedback
          if (_isCorrect != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          // Hint
          if (_isCorrect == false &&
              _hintIndex >= 0 &&
              _hintIndex < widget.activity.hints.length) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Prompt card ──────────────────────────────────────────────────────────

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
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: MiddlePalette.body,
            ),
          ),
        ],
      ),
    );
  }

  // ── Segment cards ────────────────────────────────────────────────────────

  Widget _segmentsGrid() {
    final options = widget.activity.options;
    // If few options, show in a row; if many, use a wrap / two rows.
    if (options.length <= 4) {
      return Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _segmentCard(i, options[i])),
          ],
        ],
      );
    }
    // More than 4: wrap in two rows
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < options.length; i++)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 8 * (options.length <= 3 ? 1 : 2) - 32) /
                (options.length <= 3 ? options.length : 3),
            child: _segmentCard(i, options[i]),
          ),
      ],
    );
  }

  Widget _segmentCard(int index, String label) {
    final isHighlight = _isSpinning && _highlightIndex == index;
    final isLanded = _landedIndex == index;
    final isAnswer = widget.activity.correctAnswer == index;
    final showResult = _isCorrect != null;

    Color borderColor;
    Color bgColor;
    Color textColor;
    double borderWidth = 1.5;

    if (showResult && isLanded && _isCorrect!) {
      // Landed & correct → green
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.12);
      textColor = MiddlePalette.success;
      borderWidth = 2.5;
    } else if (showResult && isLanded && !_isCorrect!) {
      // Landed & wrong → yellow
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
      textColor = MiddlePalette.retryYellowInk;
      borderWidth = 2.5;
    } else if (showResult && isAnswer && !_isCorrect!) {
      // Reveal correct answer
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.06);
      textColor = MiddlePalette.success;
    } else if (isHighlight) {
      // Currently spinning highlight
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.14);
      textColor = widget.accent;
      borderWidth = 2.5;
    } else {
      // Default
      borderColor = MiddlePalette.outline;
      bgColor = _segmentColors[index];
      textColor = MiddlePalette.blueInk;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(Palette.radiusButton),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHighlight || (showResult && isLanded)
              ? FontWeight.w700
              : FontWeight.w500,
          color: textColor,
          height: 1.3,
        ),
      ),
    );
  }

  // ── Spin button ──────────────────────────────────────────────────────────

  Widget _spinButton() {
    final resolved = _isCorrect == true;
    final canSpin = !_isSpinning && !resolved;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: canSpin ? widget.accent : MiddlePalette.outline,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: canSpin ? _startSpin : null,
          child: Center(
            child: _isSpinning
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    resolved ? 'تمّ ✅' : 'أدر العجلة 🎡',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          canSpin ? Colors.white : MiddlePalette.body,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Feedback card ────────────────────────────────────────────────────────

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
            Icon(Icons.check_circle_rounded,
                size: 20, color: MiddlePalette.success),
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
            Icon(Icons.refresh_rounded,
                size: 20, color: MiddlePalette.retryYellowInk),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ليس تماماً — أدر العجلة مرة أخرى!',
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

  // ── Hint card ────────────────────────────────────────────────────────────

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
          const Icon(Icons.lightbulb_outline_rounded,
              size: 18, color: MiddlePalette.blueInk),
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
                  style: const TextStyle(
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
