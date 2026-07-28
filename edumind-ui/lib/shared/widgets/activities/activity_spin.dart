/// Shared spin-the-wheel activity widget — shows a prompt, segment cards,
/// and a “Spin” button that slot-machine-cycles through segments.
/// Correct → green feedback + XP. Wrong → yellow + hint + retry.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:edumind/core/middle_palette.dart';
import 'package:edumind/core/palette.dart';
import 'package:edumind/shared/question_types/question_models.dart';

class ActivitySpin extends StatefulWidget {
  const ActivitySpin({
    super.key,
    required this.data,
    required this.accent,
    required this.onCorrect,
  });

  final QuestionData data;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivitySpin> createState() => _ActivitySpinState();
}

class _ActivitySpinState extends State<ActivitySpin> {
  int _highlightIndex = -1;
  int? _landedIndex;
  bool _isSpinning = false;
  bool? _isCorrect;
  int _attemptCount = 0;
  int _hintIndex = -1;

  Timer? _spinTimer;
  int _spinStep = 0;
  final _rng = Random();

  late final List<Color> _segmentColors;

  /// Segment labels from spinData (preferred) or options fallback.
  late final List<String> _segments;

  /// The correct segment index.
  late final int _correctSegmentIndex;

  @override
  void initState() {
    super.initState();
    if (widget.data.spinData != null) {
      _segments = widget.data.spinData!.wheelSegments.map((s) => s.label).toList();
      final correctId = widget.data.spinData!.correctSegmentId;
      _correctSegmentIndex = widget.data.spinData!.wheelSegments
          .indexWhere((s) => s.id == correctId);
    } else {
      _segments = List<String>.from(widget.data.options);
      _correctSegmentIndex = widget.data.correctIndex ?? 0;
    }
    _segmentColors = _buildSegmentColors();
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  List<Color> _buildSegmentColors() {
    final hsl = HSLColor.fromColor(widget.accent);
    return List.generate(_segments.length, (i) {
      final hue = (hsl.hue + i * (360 / _segments.length)) % 360;
      return HSLColor.fromAHSL(0.85, hue, 0.45, 0.92).toColor();
    });
  }

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
    const baseInterval = 60;
    const intervalGrowth = 12;
    const totalSteps = 18;

    if (_spinStep >= totalSteps) {
      final landed = _highlightIndex;
      _spinTimer?.cancel();
      _spinTimer = null;

      final correct = landed == _correctSegmentIndex;

      setState(() {
        _isSpinning = false;
        _landedIndex = landed;
        _isCorrect = correct;
      });

      if (correct) {
        final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
        final xp = (widget.data.xpReward * multiplier).round();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onCorrect(xp);
        });
      } else {
        if (widget.data.hints.isEmpty) {
          setState(() => _hintIndex = -1);
        } else {
          final hintLevel = (_attemptCount - 1).clamp(0, widget.data.hints.length - 1);
          setState(() => _hintIndex = hintLevel);
        }
      }
      return;
    }

    var next = _rng.nextInt(_segments.length);
    if (_segments.length > 1) {
      while (next == _highlightIndex) next = _rng.nextInt(_segments.length);
    }

    setState(() => _highlightIndex = next);
    _spinStep++;
    final delay = baseInterval + (_spinStep * intervalGrowth);
    _spinTimer = Timer(Duration(milliseconds: delay), _spinTick);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 16),
          _segmentsGrid(),
          const SizedBox(height: 20),
          _spinButton(),
          if (_isCorrect != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          if (_isCorrect == false && _hintIndex >= 0 && _hintIndex < widget.data.hints.length) ...[
            const SizedBox(height: 12),
            _hintCard(),
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
        color: MiddlePalette.card,
        border: Border.all(color: MiddlePalette.outline),
        borderRadius: BorderRadius.circular(Palette.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.data.promptAr, style: const TextStyle(fontSize: 16, height: 1.7, fontWeight: FontWeight.w600, color: MiddlePalette.blueInk)),
          const SizedBox(height: 8),
          Text(widget.data.prompt, style: const TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.body)),
        ],
      ),
    );
  }

  Widget _segmentsGrid() {
    if (_segments.length <= 4) {
      return Row(
        children: [
          for (var i = 0; i < _segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _segmentCard(i, _segments[i])),
          ],
        ],
      );
    }
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: [
        for (var i = 0; i < _segments.length; i++)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 8 * (_segments.length <= 3 ? 1 : 2) - 32) / (_segments.length <= 3 ? _segments.length : 3),
            child: _segmentCard(i, _segments[i]),
          ),
      ],
    );
  }

  Widget _segmentCard(int index, String label) {
    final isHighlight = _isSpinning && _highlightIndex == index;
    final isLanded = _landedIndex == index;
    final isAnswer = _correctSegmentIndex == index;
    final showResult = _isCorrect != null;

    Color borderColor;
    Color bgColor;
    Color textColor;
    double borderWidth = 1.5;

    if (showResult && isLanded && _isCorrect!) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.12);
      textColor = MiddlePalette.success;
      borderWidth = 2.5;
    } else if (showResult && isLanded && !_isCorrect!) {
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
      textColor = MiddlePalette.retryYellowInk;
      borderWidth = 2.5;
    } else if (showResult && isAnswer && !_isCorrect!) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.06);
      textColor = MiddlePalette.success;
    } else if (isHighlight) {
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.14);
      textColor = widget.accent;
      borderWidth = 2.5;
    } else {
      borderColor = MiddlePalette.outline;
      bgColor = index < _segmentColors.length ? _segmentColors[index] : MiddlePalette.card;
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
          fontWeight: isHighlight || (showResult && isLanded) ? FontWeight.w700 : FontWeight.w500,
          color: textColor,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _spinButton() {
    final resolved = _isCorrect == true;
    final canSpin = !_isSpinning && !resolved;
    return SizedBox(
      width: double.infinity, height: 50,
      child: Material(
        color: canSpin ? widget.accent : MiddlePalette.outline,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: canSpin ? _startSpin : null,
          child: Center(
            child: _isSpinning
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(
                    resolved ? 'تمّ ✅' : 'أدر العجلة 🎡',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: canSpin ? Colors.white : MiddlePalette.body),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _feedbackCard() {
    if (_isCorrect!) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: MiddlePalette.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(Palette.radiusButton)),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, size: 20, color: MiddlePalette.success),
          const SizedBox(width: 8),
          const Expanded(child: Text('إجابة صحيحة! 🎉', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MiddlePalette.success))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: MiddlePalette.retryYellowSoft, borderRadius: BorderRadius.circular(Palette.radiusButton)),
      child: Row(children: [
        Icon(Icons.refresh_rounded, size: 20, color: MiddlePalette.retryYellowInk),
        const SizedBox(width: 8),
        const Expanded(child: Text('ليس تماماً — أدر العجلة مرة أخرى!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MiddlePalette.retryYellowInk))),
      ]),
    );
  }

  Widget _hintCard() {
    final hint = widget.data.hints[_hintIndex];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: MiddlePalette.softBlue, borderRadius: BorderRadius.circular(Palette.radiusButton)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: MiddlePalette.blueInk),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تلميح:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MiddlePalette.body)),
              Text(hint.textAr, style: const TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.blueInk)),
            ],
          )),
        ],
      ),
    );
  }
}
