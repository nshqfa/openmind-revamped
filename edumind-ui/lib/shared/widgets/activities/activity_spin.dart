/// Shared spin / angle-rotation activity widget.
///
/// A circular protractor dial with an arrow the student rotates using two
/// step buttons (− / +) on either side.  Segment labels sit at equal angular
/// intervals around the rim; the student points the arrow at the correct one.
/// Correct → green feedback + XP.  Wrong → yellow + hint + retry.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _ActivitySpinState extends State<ActivitySpin>
    with TickerProviderStateMixin {
  /// Accumulated arrow angle in radians (unbounded so animation is natural).
  double _rawAngle = 0;

  bool? _isCorrect;
  int _attemptCount = 0;
  int _hintIndex = -1;
  bool _locked = false;

  late final List<String> _segments;
  late final int _correctIndex;

  /// Degrees per button press.
  static const double _stepDeg = 15;

  /// Angular tolerance (radians) for a "hit".
  static const double _tolerance = 18 * math.pi / 180;

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late Animation<double> _angleAnim =
      AlwaysStoppedAnimation<double>(_rawAngle);

  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    if (widget.data.spinData != null) {
      _segments =
          widget.data.spinData!.wheelSegments.map((s) => s.label).toList();
      final cid = widget.data.spinData!.correctSegmentId;
      _correctIndex =
          widget.data.spinData!.wheelSegments.indexWhere((s) => s.id == cid);
    } else {
      _segments = List<String>.from(widget.data.options);
      _correctIndex = widget.data.correctIndex ?? 0;
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────

  double _norm(double a) {
    a %= 2 * math.pi;
    if (a < 0) a += 2 * math.pi;
    return a;
  }

  double _angularDiff(double a, double b) {
    final d = _norm(a - b);
    return d > math.pi ? 2 * math.pi - d : d;
  }

  double _segmentAngle(int i) =>
      _segments.isEmpty ? 0 : (2 * math.pi * i) / _segments.length;

  int get _degrees => (_norm(_rawAngle) * 180 / math.pi).round() % 360;

  // ── rotation ───────────────────────────────────────────────────────────

  void _rotateBy(double deltaDeg) {
    if (_locked) return;
    final from = _rawAngle;
    _rawAngle += deltaDeg * math.pi / 180;
    _angleAnim = Tween<double>(begin: from, end: _rawAngle).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _animCtrl.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  void _startHold(double deltaDeg) {
    _rotateBy(deltaDeg);
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => _rotateBy(deltaDeg),
    );
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  // ── actions ────────────────────────────────────────────────────────────

  void _check() {
    if (_locked) return;
    final target = _segmentAngle(_correctIndex);
    final correct = _angularDiff(_norm(_rawAngle), target) <= _tolerance;

    setState(() {
      _attemptCount++;
      _isCorrect = correct;
      _locked = correct;
    });

    if (correct) {
      HapticFeedback.mediumImpact();
      final mult = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.data.xpReward * mult).round();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onCorrect(xp);
      });
    } else {
      setState(() {
        _hintIndex = widget.data.hints.isEmpty
            ? -1
            : (_attemptCount - 1).clamp(0, widget.data.hints.length - 1);
      });
    }
  }

  void _retry() {
    setState(() {
      _isCorrect = null;
      _locked = false;
    });
  }

  // ── build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 20),
          _dialRow(),
          const SizedBox(height: 10),
          _degreeLabel(),
          const SizedBox(height: 20),
          if (!_locked) _checkButton(),
          if (_isCorrect != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          if (_isCorrect == false &&
              _hintIndex >= 0 &&
              _hintIndex < widget.data.hints.length) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],
          if (_isCorrect == false) ...[
            const SizedBox(height: 12),
            _retryButton(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── prompt ─────────────────────────────────────────────────────────────

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
          Text(widget.data.promptAr,
              style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: MiddlePalette.blueInk)),
          if (widget.data.prompt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(widget.data.prompt,
                style: const TextStyle(
                    fontSize: 13, height: 1.5, color: MiddlePalette.body)),
          ],
        ],
      ),
    );
  }

  // ── dial + step buttons ────────────────────────────────────────────────

  Widget _dialRow() {
    // Force LTR so − is physically on the left and + on the right,
    // matching the rotate icons regardless of app locale.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StepButton(
            icon: Icons.rotate_left_rounded,
            accent: widget.accent,
            disabled: _locked,
            onTap: () => _rotateBy(-_stepDeg),
            onLongPressStart: () => _startHold(-_stepDeg),
            onLongPressEnd: _stopHold,
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 220,
            height: 220,
            child: AnimatedBuilder(
              animation: _angleAnim,
              builder: (_, __) => CustomPaint(
                painter: _DialPainter(
                  angle: _angleAnim.value,
                  segments: _segments,
                  correctIndex: _correctIndex,
                  accent: widget.accent,
                  showResult: _isCorrect != null,
                  isCorrect: _isCorrect ?? false,
                  tolerance: _tolerance,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          _StepButton(
            icon: Icons.rotate_right_rounded,
            accent: widget.accent,
            disabled: _locked,
            onTap: () => _rotateBy(_stepDeg),
            onLongPressStart: () => _startHold(_stepDeg),
            onLongPressEnd: _stopHold,
          ),
        ],
      ),
    );
  }

  // ── degree label ───────────────────────────────────────────────────────

  Widget _degreeLabel() {
    return AnimatedBuilder(
      animation: _angleAnim,
      builder: (_, __) {
        final deg = (_norm(_angleAnim.value) * 180 / math.pi).round() % 360;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: MiddlePalette.softBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$deg°',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: widget.accent,
            ),
          ),
        );
      },
    );
  }

  // ── buttons ────────────────────────────────────────────────────────────

  Widget _checkButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: widget.accent,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: _check,
          child: const Center(
            child: Text('تحقق',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _feedbackCard() {
    if (_isCorrect!) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MiddlePalette.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Palette.radiusButton),
        ),
        child: Row(children: [
          Icon(Icons.check_circle_rounded,
              size: 20, color: MiddlePalette.success),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('إجابة صحيحة! 🎉',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MiddlePalette.success))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MiddlePalette.retryYellowSoft,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
      ),
      child: Row(children: [
        Icon(Icons.refresh_rounded,
            size: 20, color: MiddlePalette.retryYellowInk),
        const SizedBox(width: 8),
        const Expanded(
            child: Text('ليس تماماً — حاول مرة أخرى!',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.retryYellowInk))),
      ]),
    );
  }

  Widget _hintCard() {
    final hint = widget.data.hints[_hintIndex];
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
              Text('تلميح:',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: MiddlePalette.body)),
              Text(hint.textAr.isNotEmpty ? hint.textAr : hint.text,
                  style: const TextStyle(
                      fontSize: 13, height: 1.5, color: MiddlePalette.blueInk)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _retryButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: _retry,
        style: OutlinedButton.styleFrom(
          foregroundColor: MiddlePalette.retryYellowInk,
          side: BorderSide(color: MiddlePalette.retryYellow),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Palette.radiusButton)),
        ),
        child: const Text('حاول مجدداً',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Step button (tap = one step, long-press = continuous rotation)
// ═══════════════════════════════════════════════════════════════════════════

class _StepButton extends StatefulWidget {
  const _StepButton({
    required this.icon,
    required this.accent,
    required this.disabled,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final IconData icon;
  final Color accent;
  final bool disabled;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.disabled ? MiddlePalette.outline : widget.accent;
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.disabled ? null : widget.onTap,
      onLongPressStart: widget.disabled
          ? null
          : (_) {
              setState(() => _pressed = true);
              widget.onLongPressStart();
            },
      onLongPressEnd: widget.disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onLongPressEnd();
            },
      onLongPressCancel: () {
        setState(() => _pressed = false);
        widget.onLongPressEnd();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: _pressed ? 0.22 : 0.12),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(widget.icon, size: 30, color: color),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Dial painter
// ═══════════════════════════════════════════════════════════════════════════

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.angle,
    required this.segments,
    required this.correctIndex,
    required this.accent,
    required this.showResult,
    required this.isCorrect,
    required this.tolerance,
  });

  final double angle;
  final List<String> segments;
  final int correctIndex;
  final Color accent;
  final bool showResult;
  final bool isCorrect;
  final double tolerance;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final outerR = math.min(cx, cy) - 4;
    final tickR = outerR - 12;
    final segLabelR = outerR - 46;

    // ── outer circle ──
    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = MiddlePalette.outline,
    );

    // ── inner fill ──
    canvas.drawCircle(center, outerR - 1, Paint()..color = MiddlePalette.card);

    // ── degree ticks every 10°, longer every 30° ──
    for (int deg = 0; deg < 360; deg += 10) {
      final rad = deg * math.pi / 180;
      final isMajor = deg % 30 == 0;
      final inner = isMajor ? tickR - 6 : tickR;
      final tickPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMajor ? 1.8 : 0.8
        ..color = isMajor
            ? MiddlePalette.body
            : MiddlePalette.body.withValues(alpha: 0.35);

      final p1 =
          Offset(cx + inner * math.sin(rad), cy - inner * math.cos(rad));
      final p2 = Offset(cx + (outerR - 2) * math.sin(rad),
          cy - (outerR - 2) * math.cos(rad));
      canvas.drawLine(p1, p2, tickPaint);

      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$deg°',
            style: TextStyle(
              fontSize: 9,
              color: MiddlePalette.body.withValues(alpha: 0.6),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final lx = cx + (tickR - 16) * math.sin(rad) - tp.width / 2;
        final ly = cy - (tickR - 16) * math.cos(rad) - tp.height / 2;
        tp.paint(canvas, Offset(lx, ly));
      }
    }

    // ── segment labels around the rim ──
    final n = segments.length;
    for (int i = 0; i < n; i++) {
      final segAngle = (2 * math.pi * i) / n;
      final sx = cx + segLabelR * math.sin(segAngle);
      final sy = cy - segLabelR * math.cos(segAngle);

      final dotColor = (showResult && i == correctIndex)
          ? MiddlePalette.success
          : accent.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(sx, sy), 4, Paint()..color = dotColor);

      final tp = TextPainter(
        text: TextSpan(
          text: segments[i],
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: (showResult && i == correctIndex)
                ? MiddlePalette.success
                : MiddlePalette.blueInk,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 64);
      tp.paint(canvas, Offset(sx - tp.width / 2, sy + 6));
    }

    // ── target zone arc when result is shown ──
    if (showResult) {
      final targetAngle = (2 * math.pi * correctIndex) / n;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR - 6),
        targetAngle - math.pi / 2 - tolerance,
        tolerance * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = MiddlePalette.success.withValues(alpha: 0.3),
      );
    }

    // ── arrow ──
    final arrowColor = showResult
        ? (isCorrect ? MiddlePalette.success : MiddlePalette.retryYellow)
        : accent;
    final arrowLen = outerR - 36;

    final tip = Offset(
      cx + arrowLen * math.sin(angle),
      cy - arrowLen * math.cos(angle),
    );

    canvas.drawLine(
      center,
      tip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..color = arrowColor,
    );

    final headLen = 14.0;
    final headAngle = 0.45;
    final h1 = Offset(
      tip.dx - headLen * math.sin(angle - headAngle),
      tip.dy + headLen * math.cos(angle - headAngle),
    );
    final h2 = Offset(
      tip.dx - headLen * math.sin(angle + headAngle),
      tip.dy + headLen * math.cos(angle + headAngle),
    );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(h1.dx, h1.dy)
        ..lineTo(h2.dx, h2.dy)
        ..close(),
      Paint()..color = arrowColor,
    );

    // center hub
    canvas.drawCircle(center, 7, Paint()..color = arrowColor);
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.angle != angle ||
      old.showResult != showResult ||
      old.isCorrect != isCorrect;
}