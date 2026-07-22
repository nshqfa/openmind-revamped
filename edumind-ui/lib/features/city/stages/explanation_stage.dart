/// Stage 3: الشرح (Explanation) — the concept explanation card.
library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../city_models.dart';

class ExplanationStage extends StatelessWidget {
  const ExplanationStage({super.key, required this.mission, required this.onContinue});

  final CityMission mission;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = Color(0xFF000000 | int.parse(mission.colorHex.replaceFirst('#', ''), radix: 16));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MiddlePalette.card,
              border: Border.all(color: MiddlePalette.success.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(Palette.radiusCard),
            ),
            child: Column(
              children: [
                const Text(
                  '💡',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MiddlePalette.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '💡 الشرح',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MiddlePalette.success,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Key concept box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MiddlePalette.success.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                    border: Border.all(color: MiddlePalette.success.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_rounded,
                              size: 18, color: MiddlePalette.success),
                          const SizedBox(width: 6),
                          const Text(
                            'القاعدة الأساسية',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MiddlePalette.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mission.explanation.ar,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                          color: MiddlePalette.blueInk,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mission.explanation.en,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: MiddlePalette.body,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: MiddlePalette.primaryAction,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Palette.radiusButton),
                ),
                elevation: 0,
              ),
              child: const Text(
                'التدريب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
