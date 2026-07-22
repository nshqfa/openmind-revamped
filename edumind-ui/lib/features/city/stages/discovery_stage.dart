/// Stage 2: الاكتشاف (Discovery) — interactive exploration instructions.
/// Shows the discovery text with a visual prompt to explore.
library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../city_models.dart';

class DiscoveryStage extends StatelessWidget {
  const DiscoveryStage({super.key, required this.mission, required this.onContinue});

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
              border: Border.all(color: accent.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(Palette.radiusCard),
            ),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🔍',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '🔍 الاكتشاف',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Arabic instruction
                Text(
                  mission.discovery.ar,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    color: MiddlePalette.blueInk,
                  ),
                ),
                const SizedBox(height: 12),
                // English
                Text(
                  mission.discovery.en,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: MiddlePalette.body,
                  ),
                ),
                const SizedBox(height: 20),
                // Interactive placeholder hint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MiddlePalette.softBlue,
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app_rounded,
                          size: 20, color: MiddlePalette.blueInk),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'استكشف وشاهد — لا تتردد في التجربة!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MiddlePalette.blueInk,
                          ),
                        ),
                      ),
                    ],
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
                'فهمت — التالي',
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
