/// Stage 1: الموقف (Scene) — the story context that sets up the mission.
/// Shows the mission emoji, Arabic text, and a "Continue" button.
library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../city_models.dart';
import '../../../shared/widgets/mascot_animation.dart';

class SceneStage extends StatelessWidget {
  const SceneStage({
    super.key,
    required this.mission,
    required this.onContinue,
  });

  final CityMission mission;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Scene card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MiddlePalette.card,
              border: Border.all(color: MiddlePalette.outline),
              borderRadius: BorderRadius.circular(Palette.radiusCard),
            ),
            child: Column(
              children: [
                // Mission emoji
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF000000 | int.parse(mission.colorHex.replaceFirst('#', ''), radix: 16))
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    mission.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Stage label (FIXED: uses 'child', not 'children')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MiddlePalette.softBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '📖 الموقف',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MiddlePalette.blueInk,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Mascot (Moved outside the Container so it displays correctly)
                const MascotAnimation(name: 'thinking', repeat: true, height: 100),
                
                const SizedBox(height: 16),
                
                // Arabic text
                Text(
                  mission.scene.ar,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    color: MiddlePalette.blueInk,
                  ),
                ),
                const SizedBox(height: 12),
                
                // English text (smaller)
                Text(
                  mission.scene.en,
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
          
          // Continue button
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
                'التالي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}