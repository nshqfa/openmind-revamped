/// Connect (match-pairs) activity widget — shows a prompt, two columns of
/// items, and lets the learner tap left then right to form connections.
///
/// Each pair is colour-coded so the learner can see what they've connected.
/// Once all pairs are linked the learner taps "تحقق" to check; correct pairs
/// turn green, wrong pairs turn yellow, and hints appear on retry.
library;

import 'package:flutter/material.dart';
import '../city_models.dart';
import '../../../shared/widgets/activities/activity_connect.dart' as shared;

class ActivityConnect extends StatelessWidget {
  const ActivityConnect({super.key, required this.activity, required this.accent, required this.onCorrect});
  final CityActivity activity;
  final Color accent;
  final ValueChanged<int> onCorrect;
  @override
  Widget build(BuildContext context) => shared.ActivityConnect(question: activity.toQuestionData(), accent: accent, onCorrect: onCorrect);
}

class _ActivityConnectState extends State<ActivityConnect> {
  /// Five distinguishable colours — one per connected pair (cycles if >5).
  static const _pairColors = [
    Color(0xFF1C4E80), // MiddlePalette.primaryAction
    Color(0xFFE8872E), // MiddlePalette.discovery
    Color(0xFF3E7C59), // MiddlePalette.success
    Color(0xFF7B61C4), // violet
    Color(0xFFC74040), // warm red
  ];

  int? _selectedLeft;

  /// left-index → right-index (LinkedHashMap preserves insertion order).
  final Map<int, int> _connections = {};

  bool _submitted = false;

  /// After submission: left-index → whether that pair is correct.
  Map<int, bool>? _pairResults;

  int _attemptCount = 0;
  int _hintIndex = -1;

  late final List<String> _leftItems;
  late final List<String> _rightItems;
  late final Map<int, int> _correctPairs;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final half = widget.activity.options.length ~/ 2;
    _leftItems = widget.activity.options.sublist(0, half);
    _rightItems = widget.activity.options.sublist(half);
    _correctPairs = _parseCorrectPairs();
  }

  /// Interpret [CityActivity.correctAnswer]:
  ///   * `Map` → `{leftIdx: rightIdx}` explicit pair mapping.
  ///   * `int` → sequential (0→0, 1→1, …).
  Map<int, int> _parseCorrectPairs() {
    final answer = widget.activity.correctAnswer;
    if (answer is Map) {
      return answer.map((k, v) => MapEntry(k as int, v as int));
    }
    return {for (var i = 0; i < _leftItems.length; i++) i: i};
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Colour for a given left-index based on its insertion order.
  Color _colorForPair(int leftIndex) {
    final order = _connections.keys.toList().indexOf(leftIndex);
    return _pairColors[order % _pairColors.length];
  }

  /// Returns the left-index whose right side is [rightIndex], or null.
  int? _leftIndexForRight(int rightIndex) {
    for (final e in _connections.entries) {
      if (e.value == rightIndex) return e.key;
    }
    return null;
  }

  bool get _allConnected => _connections.length == _leftItems.length;
  bool get _allCorrect =>
      _pairResults != null && _pairResults!.values.every((v) => v);

  // ── Tap handlers ────────────────────────────────────────────────────────

  void _onTapLeft(int index) {
    if (_submitted) return;

    if (_connections.containsKey(index)) {
      // Disconnect — remove pair
      setState(() => _connections.remove(index));
      return;
    }

    if (_selectedLeft == index) {
      // Deselect
      setState(() => _selectedLeft = null);
      return;
    }

    // Select this left item
    setState(() => _selectedLeft = index);
  }

  void _onTapRight(int index) {
    if (_submitted) return;

    // If this right is already connected — remove its connection
    final existingLeft = _leftIndexForRight(index);
    if (existingLeft != null) {
      setState(() => _connections.remove(existingLeft));
      return;
    }

    // No left selected → ignore (user must pick left first)
    if (_selectedLeft == null) return;

    // Left is already connected → ignore
    if (_connections.containsKey(_selectedLeft!)) return;

    // Create connection
    setState(() {
      _connections[_selectedLeft!] = index;
      _selectedLeft = null;
    });
  }

  // ── Submit / Retry ───────────────────────────────────────────────────────

  void _submit() {
    if (!_allConnected) return;

    setState(() {
      _attemptCount++;
      _submitted = true;
      _pairResults = {};

      for (final e in _connections.entries) {
        _pairResults![e.key] = _correctPairs[e.key] == e.value;
      }

      if (_allCorrect) {
        final multiplier =
            _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
        final xp = (widget.activity.xpReward * multiplier).round();
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onCorrect(xp);
        });
      } else {
        // Show next hint
        final hintLevel =
            _attemptCount.clamp(0, widget.activity.hints.length - 1);
        _hintIndex = hintLevel;
      }
    });
  }

  void _retry() {
    setState(() {
      _submitted = false;
      _pairResults = null;
      _selectedLeft = null;
      _connections.clear();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // ── Prompt card ───────────────────────────────────────────────────
          _promptCard(),
          const SizedBox(height: 8),

          // ── Instruction ──────────────────────────────────────────────────
          if (!_submitted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اضغط على عنصر من كل عمود لتوصيلهما',
                  style: TextStyle(
                    fontSize: 12,
                    color: MiddlePalette.body,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // ── Two-column pair grid ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _leftItems.length; i++) ...[
                      _itemCard(
                        label: _leftItems[i],
                        isLeft: true,
                        index: i,
                        connectedLeft: _connections.containsKey(i),
                        connectedRight: false,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Right column
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _rightItems.length; i++) ...[
                      _itemCard(
                        label: _rightItems[i],
                        isLeft: false,
                        index: i,
                        connectedLeft: false,
                        connectedRight: _leftIndexForRight(i) != null,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Pair count indicator ────────────────────────────────────────
          const SizedBox(height: 8),
          Text(
            _submitted
                ? 'تم التحقق'
                : '${_connections.length} من ${_leftItems.length} أزواج',
            style: TextStyle(
              fontSize: 12,
              color: MiddlePalette.body,
            ),
          ),

          // ── Submit button ────────────────────────────────────────────────
          if (!_submitted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: _allConnected
                    ? MiddlePalette.primaryAction
                    : MiddlePalette.outline,
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Palette.radiusButton),
                  onTap: _allConnected ? _submit : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Palette.radiusButton),
                    ),
                    child: Text(
                      'تحقق',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _allConnected ? Colors.white : MiddlePalette.body,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── Feedback ────────────────────────────────────────────────────
          if (_pairResults != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],

          // ── Hint ────────────────────────────────────────────────────────
          if (_submitted &&
              !_allCorrect &&
              _hintIndex >= 0 &&
              _hintIndex < widget.activity.hints.length) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],

          // ── Retry button ────────────────────────────────────────────────
          if (_submitted && !_allCorrect) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: MiddlePalette.retryYellowSoft,
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Palette.radiusButton),
                  onTap: _retry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: MiddlePalette.retryYellow),
                      borderRadius: BorderRadius.circular(Palette.radiusButton),
                    ),
                    child: Text(
                      'حاول مرة أخرى',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: MiddlePalette.retryYellowInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Prompt card (same style as ActivityChoice) ──────────────────────────

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
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: MiddlePalette.body,
            ),
          ),
        ],
      ),
    );
  }

  // ── Item card (left or right) ──────────────────────────────────────────

  Widget _itemCard({
    required String label,
    required bool isLeft,
    required int index,
    required bool connectedLeft,
    required bool connectedRight,
  }) {
    final isConnected =
        isLeft ? _connections.containsKey(index) : connectedRight;
    final leftIdx =
        isLeft ? index : _leftIndexForRight(index); // null when unconnected
    final pairColor = (leftIdx != null) ? _colorForPair(leftIdx) : null;

    final showResult = _submitted && leftIdx != null;
    final isCorrect = showResult ? _pairResults![leftIdx!]! : null;

    // Selected (only applies to left column)
    final isSelected = isLeft && _selectedLeft == index;

    // Determine visual state
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (showResult && isCorrect!) {
      // Correct pair
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.08);
      textColor = MiddlePalette.success;
    } else if (showResult && !isCorrect!) {
      // Wrong pair
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
      textColor = MiddlePalette.retryYellowInk;
    } else if (isSelected) {
      // Selected left item (waiting for right tap)
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.08);
      textColor = widget.accent;
    } else if (isConnected && pairColor != null) {
      // Connected — pair colour
      borderColor = pairColor;
      bgColor = pairColor.withValues(alpha: 0.08);
      textColor = pairColor;
    } else {
      // Default unconnected
      borderColor = MiddlePalette.outline;
      bgColor = MiddlePalette.card;
      textColor = MiddlePalette.blueInk;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(Palette.radiusButton),
      child: InkWell(
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        onTap: isLeft ? () => _onTapLeft(index) : () => _onTapRight(index),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(Palette.radiusButton),
          ),
          child: Row(
            children: [
              // Pair colour dot
              if (isConnected && pairColor != null && !_submitted)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pairColor,
                  ),
                )
              else if (isConnected && showResult)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellow,
                  ),
                )
              else
                const SizedBox(width: 18),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isConnected || isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: textColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Result icon
              if (showResult)
                Icon(
                  isCorrect!
                      ? Icons.check_circle_rounded
                      : Icons.refresh_rounded,
                  size: 16,
                  color: isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellowInk,
                )
              else if (isSelected)
                Icon(
                  Icons.radio_button_checked_rounded,
                  size: 16,
                  color: widget.accent,
                )
              else
                const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Feedback card ──────────────────────────────────────────────────────

  Widget _feedbackCard() {
    if (_allCorrect) {
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
                'أحسنت! جميع الأزواج صحيحة! 🎉',
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
    }

    // Count correct vs total
    final correct = _pairResults!.values.where((v) => v).length;
    final total = _pairResults!.length;

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
          Expanded(
            child: Text(
              '$correct من $total أزواج صحيحة — حاول مرة أخرى!',
              style: const TextStyle(
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

  // ── Hint card ──────────────────────────────────────────────────────────

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
