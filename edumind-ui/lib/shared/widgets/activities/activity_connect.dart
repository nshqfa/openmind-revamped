/// Shared connect (match-pairs) activity widget — shows a prompt, two columns
/// of items, and lets the learner tap left then right to form connections.
/// Uses [QuestionData.connectData] for structured left/right items and pairs.
library;

import 'package:flutter/material.dart';

import 'package:edumind/core/middle_palette.dart';
import 'package:edumind/core/palette.dart';
import 'package:edumind/shared/question_types/question_models.dart';

class ActivityConnect extends StatefulWidget {
  const ActivityConnect({
    super.key,
    required this.data,
    required this.accent,
    required this.onCorrect,
  });

  final QuestionData data;
  final Color accent;
  final ValueChanged<int> onCorrect;

  @override
  State<ActivityConnect> createState() => _ActivityConnectState();
}

class _ActivityConnectState extends State<ActivityConnect> {
  static const _pairColors = [
    Color(0xFF1C4E80),
    Color(0xFFE8872E),
    Color(0xFF3E7C59),
    Color(0xFF7B61C4),
    Color(0xFFC74040),
  ];

  int? _selectedLeft;
  final Map<int, int> _connections = {}; // left-index → right-index
  bool _submitted = false;
  Map<int, bool>? _pairResults;
  int _attemptCount = 0;
  int _hintIndex = -1;

  late final List<ConnectItem> _leftItems;
  late final List<ConnectItem> _rightItems;
  late final Map<int, int> _correctPairs; // left-index → right-index

  @override
  void initState() {
    super.initState();
    final cd = widget.data.connectData;
    if (cd != null) {
      _leftItems = cd.leftItems;
      _rightItems = cd.rightItems;
      _correctPairs = {};
      for (final pair in cd.correctPairs) {
        final li = cd.leftItems.indexWhere((i) => i.id == pair.leftId);
        final ri = cd.rightItems.indexWhere((i) => i.id == pair.rightId);
        if (li >= 0 && ri >= 0) _correctPairs[li] = ri;
      }
    } else {
      // Fallback: split options in half, sequential pairing.
      final half = widget.data.options.length ~/ 2;
      _leftItems = List.generate(half, (i) => ConnectItem(id: 'l$i', label: widget.data.options[i]));
      _rightItems = List.generate(widget.data.options.length - half, (i) => ConnectItem(id: 'r$i', label: widget.data.options[half + i]));
      _correctPairs = {for (var i = 0; i < _leftItems.length; i++) i: i};
    }
  }

  Color _colorForPair(int leftIndex) {
    final order = _connections.keys.toList().indexOf(leftIndex);
    return _pairColors[order % _pairColors.length];
  }

  int? _leftIndexForRight(int rightIndex) {
    for (final e in _connections.entries) {
      if (e.value == rightIndex) return e.key;
    }
    return null;
  }

  bool get _allConnected => _connections.length == _leftItems.length;
  bool get _allCorrect => _pairResults != null && _pairResults!.values.every((v) => v);

  void _onTapLeft(int index) {
    if (_submitted) return;
    if (_connections.containsKey(index)) {
      setState(() => _connections.remove(index));
      return;
    }
    if (_selectedLeft == index) {
      setState(() => _selectedLeft = null);
      return;
    }
    setState(() => _selectedLeft = index);
  }

  void _onTapRight(int index) {
    if (_submitted) return;
    final existingLeft = _leftIndexForRight(index);
    if (existingLeft != null) {
      setState(() => _connections.remove(existingLeft));
      return;
    }
    if (_selectedLeft == null) return;
    if (_connections.containsKey(_selectedLeft!)) return;
    setState(() {
      _connections[_selectedLeft!] = index;
      _selectedLeft = null;
    });
  }

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
        final multiplier = _attemptCount <= 1 ? 1.0 : _attemptCount == 2 ? 0.7 : 0.5;
        final xp = (widget.data.xpReward * multiplier).round();
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onCorrect(xp);
        });
      } else {
        if (widget.data.hints.isEmpty) {
          _hintIndex = -1;
        } else {
          _hintIndex = (_attemptCount).clamp(0, widget.data.hints.length - 1);
        }
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _promptCard(),
          const SizedBox(height: 8),
          if (!_submitted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('اضغط على عنصر من كل عمود لتوصيلهما', style: TextStyle(fontSize: 12, color: MiddlePalette.body)),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (var i = 0; i < _leftItems.length; i++) ...[_itemCard(label: _leftItems[i].label, isLeft: true, index: i), const SizedBox(height: 8)]])),
              const SizedBox(width: 10),
              Expanded(child: Column(children: [for (var i = 0; i < _rightItems.length; i++) ...[_itemCard(label: _rightItems[i].label, isLeft: false, index: i), const SizedBox(height: 8)]])),
            ],
          ),
          const SizedBox(height: 8),
          Text(_submitted ? 'تم التحقق' : '${_connections.length} من ${_leftItems.length} أزواج', style: TextStyle(fontSize: 12, color: MiddlePalette.body)),
          if (!_submitted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: _allConnected ? MiddlePalette.primaryAction : MiddlePalette.outline,
                borderRadius: BorderRadius.circular(Palette.radiusButton),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Palette.radiusButton),
                  onTap: _allConnected ? _submit : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Palette.radiusButton)),
                    child: Text('تحقق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _allConnected ? Colors.white : MiddlePalette.body)),
                  ),
                ),
              ),
            ),
          ],
          if (_pairResults != null) ...[const SizedBox(height: 16), _feedbackCard()],
          if (_submitted && !_allCorrect && _hintIndex >= 0 && _hintIndex < widget.data.hints.length) ...[
            const SizedBox(height: 12), _hintCard(),
          ],
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
                    decoration: BoxDecoration(border: Border.all(color: MiddlePalette.retryYellow), borderRadius: BorderRadius.circular(Palette.radiusButton)),
                    child: Text('حاول مرة أخرى', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: MiddlePalette.retryYellowInk)),
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

  Widget _promptCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: MiddlePalette.card, border: Border.all(color: MiddlePalette.outline), borderRadius: BorderRadius.circular(Palette.radiusCard)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.data.promptAr, style: const TextStyle(fontSize: 16, height: 1.7, fontWeight: FontWeight.w600, color: MiddlePalette.blueInk)),
          const SizedBox(height: 8),
          Text(widget.data.prompt, style: TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.body)),
        ],
      ),
    );
  }

  Widget _itemCard({required String label, required bool isLeft, required int index}) {
    final isConnected = isLeft ? _connections.containsKey(index) : _leftIndexForRight(index) != null;
    final leftIdx = isLeft ? index : _leftIndexForRight(index);
    final pairColor = (leftIdx != null) ? _colorForPair(leftIdx) : null;
    final showResult = _submitted && leftIdx != null;
    final isCorrect = showResult ? _pairResults![leftIdx!]! : null;
    final isSelected = isLeft && _selectedLeft == index;

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (showResult && isCorrect!) {
      borderColor = MiddlePalette.success;
      bgColor = MiddlePalette.success.withValues(alpha: 0.08);
      textColor = MiddlePalette.success;
    } else if (showResult && !isCorrect!) {
      borderColor = MiddlePalette.retryYellow;
      bgColor = MiddlePalette.retryYellowSoft;
      textColor = MiddlePalette.retryYellowInk;
    } else if (isSelected) {
      borderColor = widget.accent;
      bgColor = widget.accent.withValues(alpha: 0.08);
      textColor = widget.accent;
    } else if (isConnected && pairColor != null) {
      borderColor = pairColor;
      bgColor = pairColor.withValues(alpha: 0.08);
      textColor = pairColor;
    } else {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: borderColor, width: 1.5), borderRadius: BorderRadius.circular(Palette.radiusButton)),
          child: Row(
            children: [
              if (isConnected && pairColor != null && !_submitted)
                Container(width: 10, height: 10, margin: const EdgeInsetsDirectional.only(end: 8), decoration: BoxDecoration(shape: BoxShape.circle, color: pairColor))
              else if (isConnected && showResult)
                Container(width: 10, height: 10, margin: const EdgeInsetsDirectional.only(end: 8), decoration: BoxDecoration(shape: BoxShape.circle, color: isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellow))
              else
                const SizedBox(width: 18),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isConnected || isSelected ? FontWeight.w700 : FontWeight.w500, color: textColor, height: 1.4), textAlign: TextAlign.center),
              ),
              if (showResult)
                Icon(isCorrect! ? Icons.check_circle_rounded : Icons.refresh_rounded, size: 16, color: isCorrect! ? MiddlePalette.success : MiddlePalette.retryYellowInk)
              else if (isSelected)
                Icon(Icons.radio_button_checked_rounded, size: 16, color: widget.accent)
              else
                const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackCard() {
    if (_allCorrect) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: MiddlePalette.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(Palette.radiusButton)),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, size: 20, color: MiddlePalette.success),
          const SizedBox(width: 8),
          const Expanded(child: Text('أحسنت! جميع الأزواج صحيحة! 🎉', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MiddlePalette.success))),
        ]),
      );
    }
    final correct = _pairResults!.values.where((v) => v).length;
    final total = _pairResults!.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: MiddlePalette.retryYellowSoft, borderRadius: BorderRadius.circular(Palette.radiusButton)),
      child: Row(children: [
        Icon(Icons.refresh_rounded, size: 20, color: MiddlePalette.retryYellowInk),
        const SizedBox(width: 8),
        Expanded(child: Text('$correct من $total أزواج صحيحة — حاول مرة أخرى!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MiddlePalette.retryYellowInk))),
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
              Text(hint.textAr, style: TextStyle(fontSize: 13, height: 1.5, color: MiddlePalette.blueInk)),
            ],
          )),
        ],
      ),
    );
  }
}
