/// Tap-image activity widget — shows a prompt and tappable region cards.
/// The learner must tap all correct regions, then press "تحقق" to check.
/// Correct taps turn green, missed ones get a dashed green outline,
/// wrong taps get the retry-yellow treatment.
library;

import 'package:flutter/material.dart';

import '../../../../core/middle_palette.dart';
import '../../../../core/palette.dart';
import '../city_models.dart';

class ActivityTapImage extends StatefulWidget {
  const ActivityTapImage({
    super.key,
    required this.activity,
    required this.accent,
    required this.onCorrect,
  });

  final CityActivity activity;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityTapImage> createState() => _ActivityTapImageState();
}

class _ActivityTapImageState extends State<ActivityTapImage> {
  /// Indices the learner has currently tapped.
  final Set<int> _selected = {};

  /// Null = not yet checked; true = all correct; false = has mistakes.
  bool? _isCorrect;

  int _attemptCount = 0;
  int _hintIndex = -1;

  // ── Parse correctAnswer into a Set<int> of correct option indices ──

  Set<int> get _correctIndices {
    final raw = widget.activity.correctAnswer;

    // List of bools: [true, false, true] → indices where true
    if (raw is List) {
      final result = <int>{};
      for (var i = 0; i < raw.length; i++) {
        final v = raw[i];
        if (v is bool && v) {
          result.add(i);
        } else if (v is int && v == 1) {
          result.add(i);
        }
      }
      if (result.isNotEmpty) return result;

      // List of ints: [0, 2, 4]
      if (raw.isNotEmpty && raw.first is int) {
        return (raw.cast<int>()).toSet();
      }
    }

    // Single int — the index of the one correct option
    if (raw is int) {
      return {raw.clamp(0, widget.activity.options.length - 1)};
    }

    // Fallback: empty set (hints will guide the learner)
    return <int>{};
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Prompt
          _promptCard(),
          const SizedBox(height: 16),
          // Instruction
          _instructionChip(),
          const SizedBox(height: 12),
          // Tappable region cards
          _regionGrid(),
          const SizedBox(height: 16),
          // Check button
          if (_isCorrect == null) _checkButton(),
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
          // Retry button after wrong answer
          if (_isCorrect == false) ...[
            const SizedBox(height: 16),
            _retryButton(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Prompt card (identical to ActivityChoice) ──

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

  // ── Instruction chip ──

  Widget _instructionChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: MiddlePalette.softBlue,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded,
              size: 16, color: MiddlePalette.blueInk),
          const SizedBox(width: 6),
          Text(
            'اختر جميع الإجابات الصحيحة ثم اضغط تحقق',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MiddlePalette.blueInk,
            ),
          ),
        ],
      ),
    );
  }

  // ── Region grid ──

  Widget _regionGrid() {
    final options = widget.activity.options;
    // Use 2-column grid when there are many options, otherwise a single column.
    final crossCount = options.length > 4 ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: crossCount > 1 ? 2.8 : 3.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) => _regionCard(index, options[index]),
    );
  }

  // ── Single region card ──

  Widget _regionCard(int index, String label) {
    final selected = _selected.contains(index);
    final isCorrect = _correctIndices.contains(index);
    final checked = _isCorrect != null;
    final locked = checked;

    // Determine visual state
    _CardState state;
    if (checked && _isCorrect!) {
      state = selected
          ? _CardState.correctSelected
          : (isCorrect ? _CardState.correctMissed : _CardState.neutral);
    } else if (checked && !_isCorrect!) {
      if (selected && isCorrect) {
        state = _CardState.correctSelected;
      } else if (selected && !isCorrect) {
        state = _CardState.wrongSelected;
      } else if (!selected && isCorrect) {
        state = _CardState.correctMissed;
      } else {
        state = _CardState.neutral;
      }
    } else {
      state = selected ? _CardState.tapped : _CardState.neutral;
    }

    return _RegionTile(
      label: label,
      index: index,
      state: state,
      accent: widget.accent,
      locked: locked,
      onTap: locked ? null : () => _toggle(index),
    );
  }

  // ── Toggle selection ──

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  // ── Check answer ──

  void _check() {
    final correct = _correctIndices;
    final allCorrect =
        _selected.containsAll(correct) && _selected.length == correct.length;

    setState(() {
      _attemptCount++;
      _isCorrect = allCorrect;
    });

    if (allCorrect) {
      final multiplier = _attemptCount <= 1
          ? 1.0
          : _attemptCount == 2
              ? 0.7
              : 0.5;
      final xp = (widget.activity.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onCorrect(xp);
      });
    } else {
      final hintLevel =
          (_attemptCount - 1).clamp(0, widget.activity.hints.length - 1);
      setState(() => _hintIndex = hintLevel);
    }
  }

  // ── Retry (reset selections) ──

  void _retry() {
    setState(() {
      _selected.clear();
      _isCorrect = null;
    });
  }

  // ── Check button ──

  Widget _checkButton() {
    final enabled = _selected.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled
            ? MiddlePalette.primaryAction
            : MiddlePalette.primaryAction.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: enabled ? _check : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: const Text(
              'تحقق',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Retry button ──

  Widget _retryButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: MiddlePalette.card,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: _retry,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: MiddlePalette.outline, width: 1.5),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: const Text(
              'حاول مرة أخرى',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: MiddlePalette.blueInk,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Feedback card (same patterns as ActivityChoice) ──

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

  // ── Hint card (same patterns as ActivityChoice) ──

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

// ── Visual states for a region card after checking ──

enum _CardState {
  /// Before checking — not tapped.
  neutral,

  /// Before checking — currently tapped by the learner.
  tapped,

  /// After checking — learner tapped it and it is correct.
  correctSelected,

  /// After checking — learner didn't tap it but it was correct (missed).
  correctMissed,

  /// After checking — learner tapped it but it was wrong.
  wrongSelected,
}

// ── Region tile ──

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.label,
    required this.index,
    required this.state,
    required this.accent,
    required this.locked,
    this.onTap,
  });

  final String label;
  final int index;
  final _CardState state;
  final Color accent;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();

    if (state == _CardState.correctMissed) {
      // Dashed green border + transparent fill
      return CustomPaint(
        painter: _DashedBorderPainter(
          color: MiddlePalette.success,
          strokeWidth: 2.0,
          dashWidth: 6.0,
          dashSpace: 4.0,
          radius: Palette.radiusButton,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: MiddlePalette.success.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(Palette.radiusButton),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded,
                  size: 16, color: MiddlePalette.success),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.success,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: colors.bg,
      borderRadius: BorderRadius.circular(Palette.radiusButton),
      child: InkWell(
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border, width: 1.5),
            borderRadius: BorderRadius.circular(Palette.radiusButton),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state == _CardState.correctSelected ||
                  state == _CardState.wrongSelected)
                Icon(
                  state == _CardState.correctSelected
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 18,
                  color: colors.icon,
                ),
              if (state == _CardState.correctSelected ||
                  state == _CardState.wrongSelected)
                const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: colors.fontWeight,
                    color: colors.text,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TileColors _resolveColors() {
    return switch (state) {
      _CardState.neutral => const _TileColors(
          border: MiddlePalette.outline,
          bg: MiddlePalette.card,
          text: MiddlePalette.blueInk,
          icon: MiddlePalette.blueInk,
          fontWeight: FontWeight.w500,
        ),
      _CardState.tapped => _TileColors(
          border: accent,
          bg: accent.withValues(alpha: 0.08),
          text: accent,
          icon: accent,
          fontWeight: FontWeight.w700,
        ),
      _CardState.correctSelected => _TileColors(
          border: MiddlePalette.success,
          bg: MiddlePalette.success.withValues(alpha: 0.08),
          text: MiddlePalette.success,
          icon: MiddlePalette.success,
          fontWeight: FontWeight.w700,
        ),
      _CardState.correctMissed => _TileColors(
          border: MiddlePalette.success,
          bg: MiddlePalette.success.withValues(alpha: 0.04),
          text: MiddlePalette.success,
          icon: MiddlePalette.success,
          fontWeight: FontWeight.w700,
        ),
      _CardState.wrongSelected => const _TileColors(
          border: MiddlePalette.retryYellow,
          bg: MiddlePalette.retryYellowSoft,
          text: MiddlePalette.retryYellowInk,
          icon: MiddlePalette.retryYellowInk,
          fontWeight: FontWeight.w700,
        ),
    };
  }
}

// ── Color bundle for a tile state ──

class _TileColors {
  const _TileColors({
    required this.border,
    required this.bg,
    required this.text,
    required this.icon,
    required this.fontWeight,
  });

  final Color border;
  final Color bg;
  final Color text;
  final Color icon;
  final FontWeight fontWeight;
}

// ── Custom painter for dashed border (used for missed-correct state) ──

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}