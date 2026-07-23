/// Drag-and-drop activity widget — shows a prompt, labeled drop zones,
/// and draggable item cards. Learners match items to the correct slots.
/// Awards XP based on attempt count.
library;

import 'package:flutter/material.dart';

import '../../../../core/middle_palette.dart';
import '../../../../core/palette.dart';
import '../city_models.dart';

class ActivityDragDrop extends StatefulWidget {
  const ActivityDragDrop({
    super.key,
    required this.activity,
    required this.accent,
    required this.onCorrect,
  });

  final CityActivity activity;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityDragDrop> createState() => _ActivityDragDropState();
}

class _ActivityDragDropState extends State<ActivityDragDrop> {
  /// Ordered slot IDs derived from `correctAnswer` map keys.
  late final List<String> _slotIds;

  /// Ordered item labels from `options` list.
  late final List<String> _items;

  /// Current placement: slot ID → item label (null if empty).
  final Map<String, String?> _slotAssignments = {};

  /// Per-slot result after submit (populated on check).
  final Map<String, bool> _slotResults = {};

  /// `true` = all correct, `false` = has errors, `null` = not yet submitted.
  bool? _allCorrect;

  int _attemptCount = 0;
  int _hintIndex = -1;

  // ── Initialisation ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final answerMap = _answerMap;
    _slotIds = answerMap.keys.toList();
    _items = List<String>.from(widget.activity.options);
    for (final id in _slotIds) {
      _slotAssignments[id] = null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Parse `correctAnswer` as `Map<String, dynamic>`, falling back to empty.
  Map<String, dynamic> get _answerMap {
    if (widget.activity.correctAnswer is Map) {
      return Map<String, dynamic>.from(
        widget.activity.correctAnswer as Map,
      );
    }
    return {};
  }

  /// Resolve the correct item label for a given slot.
  String? _correctLabelFor(String slotId) {
    final value = _answerMap[slotId];
    if (value == null) return null;

    // Numeric index into _items
    int? idx;
    if (value is int) {
      idx = value;
    } else if (value is String) {
      idx = int.tryParse(value);
    }
    if (idx != null && idx >= 0 && idx < _items.length) {
      return _items[idx];
    }

    // Direct label match
    final str = value.toString();
    if (_items.contains(str)) return str;

    return null;
  }

  /// Labels currently sitting in a slot.
  Set<String> get _placedLabels {
    return _slotAssignments.values.whereType<String>().toSet();
  }

  /// Labels still available for dragging.
  List<String> get _availableItems {
    return _items.where((i) => !_placedLabels.contains(i)).toList();
  }

  bool get _allSlotsFilled {
    return _slotAssignments.values.every((v) => v != null);
  }

  /// Whether the user can interact (not yet answered correctly).
  bool get _interactive => _allCorrect != true;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 16),

          // ── Drop zones ──
          for (final id in _slotIds) _dropZone(id),

          const SizedBox(height: 20),

          // ── Draggable items pool ──
          if (_interactive) ...[
            _itemsPool(),
            const SizedBox(height: 16),
            _submitOrRetryButton(),
          ],

          // ── Feedback ──
          if (_allCorrect != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],

          // ── Hint ──
          if (_allCorrect == false &&
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

  // ── Prompt card (same style as ActivityChoice) ───────────────────────────

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

  // ── Drop zone for a single slot ──────────────────────────────────────────

  Widget _dropZone(String slotId) {
    final assigned = _slotAssignments[slotId];
    final showResult = _allCorrect != null;
    final isSlotCorrect = _slotResults[slotId] ?? false;

    Color borderColor;
    Color bgColor;

    if (showResult && isSlotCorrect) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.08);
    } else if (showResult && assigned != null && !isSlotCorrect) {
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
    } else if (assigned != null) {
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.08);
    } else {
      borderColor = MiddlePalette.outline;
      bgColor = MiddlePalette.card;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => _interactive,
        onAcceptWithDetails: (details) {
          if (!_interactive) return;
          final label = details.data;

          setState(() {
            // If this label sits in another slot, remove it first.
            for (final key in _slotIds) {
              if (_slotAssignments[key] == label && key != slotId) {
                _slotAssignments[key] = null;
                break;
              }
            }
            // Place into this slot (overwrites any previous occupant).
            _slotAssignments[slotId] = label;
          });
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty && assigned == null;
          final activeBorderColor =
              isHovering ? widget.accent : borderColor;
          final activeBgColor = isHovering
              ? widget.accent.withValues(alpha: 0.12)
              : bgColor;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: activeBgColor,
              border: Border.all(color: activeBorderColor, width: 1.5),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: Row(
              children: [
                // Slot label
                Expanded(
                  flex: 2,
                  child: Text(
                    slotId,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MiddlePalette.blueInk,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Assigned item or placeholder
                Expanded(
                  flex: 3,
                  child: assigned != null
                      ? _assignedChip(slotId, assigned, showResult, isSlotCorrect)
                      : Text(
                          '— اسحب هنا —',
                          style: TextStyle(
                            fontSize: 12,
                            color: MiddlePalette.body.withValues(alpha: 0.5),
                          ),
                        ),
                ),
                // Result icon after submit
                if (showResult && assigned != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    isSlotCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 20,
                    color: isSlotCorrect
                        ? MiddlePalette.success
                        : MiddlePalette.retryYellow,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// The chip displayed inside a slot when an item is placed there.
  Widget _assignedChip(
    String slotId,
    String label,
    bool showResult,
    bool isSlotCorrect,
  ) {
    final chipColor = showResult
        ? (isSlotCorrect
            ? MiddlePalette.success.withValues(alpha: 0.12)
            : MiddlePalette.retryYellowSoft)
        : widget.accent.withValues(alpha: 0.15);
    final textColor = showResult
        ? (isSlotCorrect ? MiddlePalette.success : MiddlePalette.retryYellowInk)
        : widget.accent;

    return GestureDetector(
      onTap: _interactive ? () => _removeFromSlot(slotId) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (_interactive)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: MiddlePalette.body,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Draggable items pool ─────────────────────────────────────────────────

  Widget _itemsPool() {
    final items = _availableItems;
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: items.map((label) => _draggableItem(label)).toList(),
      ),
    );
  }

  Widget _draggableItem(String label) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: _itemChip(
          label,
          color: widget.accent,
          textColor: Colors.white,
          bg: widget.accent.withValues(alpha: 0.9),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _itemChip(label),
      ),
      child: _itemChip(label),
    );
  }

  Widget _itemChip(
    String label, {
    Color? color,
    Color? textColor,
    Color? bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg ?? MiddlePalette.card,
        border: Border.all(color: color ?? widget.accent, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor ?? widget.accent,
        ),
      ),
    );
  }

  // ── Submit / Retry button ─────────────────────────────────────────────────

  Widget _submitOrRetryButton() {
    // After a wrong submission, show retry instead of submit.
    if (_allCorrect == false) {
      return SizedBox(
        width: double.infinity,
        child: Material(
          color: MiddlePalette.retryYellow,
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          child: InkWell(
            borderRadius: BorderRadius.circular(Palette.radiusButton),
            onTap: _retry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: const Text(
                'حاول مجددًا',
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

    final enabled = _allSlotsFilled;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? widget.accent : MiddlePalette.outline,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: enabled ? _checkAnswers : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              'تحقق',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : MiddlePalette.body,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _removeFromSlot(String slotId) {
    setState(() => _slotAssignments[slotId] = null);
  }

  void _retry() {
    setState(() {
      _allCorrect = null;
      _slotResults.clear();
    });
  }

  void _checkAnswers() {
    _attemptCount++;

    final results = <String, bool>{};
    var allCorrect = true;

    for (final slotId in _slotIds) {
      final assigned = _slotAssignments[slotId];
      final correct = _correctLabelFor(slotId);
      final ok = assigned == correct;
      results[slotId] = ok;
      if (!ok) allCorrect = false;
    }

    setState(() {
      _allCorrect = allCorrect;
      _slotResults.addAll(results);
    });

    if (allCorrect) {
      // XP: 1st attempt 100%, 2nd 70%, 3rd+ 50%
      final multiplier =
          _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.activity.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onCorrect(xp);
      });
    } else {
      // Show progressive hints.
      final hintLevel =
          (_attemptCount - 1).clamp(0, widget.activity.hints.length - 1);
      setState(() => _hintIndex = hintLevel);
    }
  }

  // ── Feedback card (same style as ActivityChoice) ──────────────────────────

  Widget _feedbackCard() {
    if (_allCorrect == true) {
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
    }

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

  // ── Hint card (same style as ActivityChoice) ─────────────────────────────

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
