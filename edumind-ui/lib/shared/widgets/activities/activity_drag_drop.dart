/// Shared drag-and-drop activity widget — accepts [QuestionData].
library;

import 'package:flutter/material.dart';

import 'package:edumind/core/middle_palette.dart';
import 'package:edumind/core/palette.dart';
import 'package:edumind/shared/question_types/question_models.dart';

class ActivityDragDrop extends StatefulWidget {
  const ActivityDragDrop({
    super.key,
    required this.question,
    required this.accent,
    required this.onCorrect,
  });

  final QuestionData question;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityDragDrop> createState() => _ActivityDragDropState();
}

class _ActivityDragDropState extends State<ActivityDragDrop> {
  late final List<DragDropSlot> _slots;
  late final List<DragDropItem> _items;
  final Map<String, String?> _slotAssignments = {};
  final Map<String, bool> _slotResults = {};
  bool? _allCorrect;
  int _attemptCount = 0;
  int _hintIndex = -1;

  @override
  void initState() {
    super.initState();
    final dd = widget.question.dragDropData;
    _slots = dd?.slots ?? [];
    _items = dd?.items ?? [];
    for (final s in _slots) {
      _slotAssignments[s.id] = null;
    }
  }

  Set<String> get _placedIds =>
      _slotAssignments.values.whereType<String>().toSet();

  List<DragDropItem> get _available =>
      _items.where((i) => !_placedIds.contains(i.id)).toList();

  bool get _allFilled =>
      _slotAssignments.values.every((v) => v != null);

  bool get _interactive => _allCorrect != true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 16),
          for (final slot in _slots) _dropZone(slot),
          const SizedBox(height: 20),
          if (_interactive) ...[
            _itemsPool(),
            const SizedBox(height: 16),
            _submitButton(),
          ],
          if (_allCorrect != null) ...[
            const SizedBox(height: 16),
            _feedbackCard(),
          ],
          if (_allCorrect == false &&
              _hintIndex >= 0 &&
              _hintIndex < widget.question.hints.length) ...[
            const SizedBox(height: 12),
            _hintCard(),
          ],
          if (_allCorrect == false) ...[
            const SizedBox(height: 12),
            _retryButton(),
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
          Text(widget.question.promptAr,
              style: const TextStyle(fontSize: 16, height: 1.7,
                  fontWeight: FontWeight.w600, color: MiddlePalette.blueInk)),
          const SizedBox(height: 8),
          Text(widget.question.prompt,
              style: const TextStyle(fontSize: 13, height: 1.5,
                  color: MiddlePalette.body)),
        ],
      ),
    );
  }

  Widget _dropZone(DragDropSlot slot) {
    final assignedId = _slotAssignments[slot.id];
    final assignedLabel =
        _items.where((i) => i.id == assignedId).map((i) => i.label).firstOrNull;
    final showResult = _allCorrect != null;
    final isCorrect = _slotResults[slot.id] ?? false;

    Color borderColor, bgColor;
    if (showResult && isCorrect) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.08);
    } else if (showResult && assignedId != null && !isCorrect) {
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
    } else if (assignedId != null) {
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.08);
    } else {
      borderColor = MiddlePalette.outline;
      bgColor = MiddlePalette.card;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => _interactive,
        onAcceptWithDetails: (details) {
          if (!_interactive) return;
          setState(() {
            for (final key in _slotAssignments.keys) {
              if (_slotAssignments[key] == details.data && key != slot.id) {
                _slotAssignments[key] = null;
              }
            }
            _slotAssignments[slot.id] = details.data;
          });
        },
        builder: (context, candidate, rejected) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: candidate.isNotEmpty && assignedId == null
                  ? widget.accent.withValues(alpha: 0.12)
                  : bgColor,
              border: Border.all(
                  color: candidate.isNotEmpty && assignedId == null
                      ? widget.accent
                      : borderColor,
                  width: 1.5),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(slot.label,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MiddlePalette.body)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: assignedId != null
                          ? Colors.white
                          : MiddlePalette.softBlue,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      assignedLabel ?? 'اسحب هنا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: assignedId != null ? FontWeight.w700 : FontWeight.w400,
                        color: assignedId != null ? MiddlePalette.blueInk : MiddlePalette.body,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _itemsPool() {
    final available = _available;
    if (available.isEmpty) return const SizedBox();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final item in available)
          Draggable<String>(
            data: item.id,
            feedback: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(item.label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _itemChip(item.label),
            ),
            child: _itemChip(item.label),
          ),
      ],
    );
  }

  Widget _itemChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.1),
        border: Border.all(color: widget.accent),
        borderRadius: BorderRadius.circular(Palette.radiusButton),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: widget.accent)),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _allFilled ? MiddlePalette.primaryAction : MiddlePalette.outline,
        borderRadius: BorderRadius.circular(Palette.radiusButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusButton),
          onTap: _allFilled ? _check : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text('تحقق',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _allFilled ? Colors.white : MiddlePalette.body)),
          ),
        ),
      ),
    );
  }

  void _check() {
    setState(() {
      _attemptCount++;
      _slotResults.clear();
      var allOk = true;
      for (final slot in _slots) {
        final ok = _slotAssignments[slot.id] == slot.correctItemId;
        _slotResults[slot.id] = ok;
        if (!ok) allOk = false;
      }
      _allCorrect = allOk;
    });

    if (_allCorrect!) {
      final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
      final xp = (widget.question.xpReward * multiplier).round();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onCorrect(xp);
      });
    } else {
      final hintLevel = (_attemptCount - 1).clamp(0, widget.question.hints.length - 1);
      setState(() => _hintIndex = hintLevel);
    }
  }

  Widget _feedbackCard() {
    if (_allCorrect!) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MiddlePalette.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Palette.radiusButton),
        ),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, size: 20, color: MiddlePalette.success),
          const SizedBox(width: 8),
          const Expanded(child: Text('إجابة صحيحة! 🎉',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
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
        Icon(Icons.refresh_rounded, size: 20, color: MiddlePalette.retryYellowInk),
        const SizedBox(width: 8),
        const Expanded(child: Text('ليس تماماً — حاول مرة أخرى!',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: MiddlePalette.retryYellowInk))),
      ]),
    );
  }

  Widget _hintCard() {
    final hint = widget.question.hints[_hintIndex];
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
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تلميح:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MiddlePalette.body)),
              Text(hint.textAr.isNotEmpty ? hint.textAr : hint.text,
                  style: const TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.blueInk)),
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
        onPressed: () {
          setState(() {
            _allCorrect = null;
            _slotResults.clear();
            for (final key in _slotAssignments.keys) {
              _slotAssignments[key] = null;
            }
          });
        },
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