/// Stage 5: تطبيق المدينة (Application) — one city-themed activity.
library;

import 'package:flutter/material.dart';

import '../../../core/middle_palette.dart';
import '../../../core/palette.dart';
import '../../../shared/widgets/activities/activity_choice.dart';
import '../../../shared/widgets/activities/activity_drag_drop.dart';
import '../../../shared/widgets/activities/activity_spin.dart';
import '../../../shared/widgets/activities/activity_connect.dart';
import '../../../shared/widgets/activities/activity_tap_image.dart';
import '../../../shared/widgets/activities/activity_open_response.dart';
import '../../../shared/widgets/activities/activity_numeric_input.dart';
import '../city_models.dart';
import '../city_progress_store.dart';
import '../../../shared/widgets/mascot_animation.dart';

class ApplicationStage extends StatefulWidget {
  const ApplicationStage({super.key, required this.mission, required this.onContinue});

  final CityMission mission;
  final VoidCallback onContinue;

  @override
  State<ApplicationStage> createState() => _ApplicationStageState();
}

class _ApplicationStageState extends State<ApplicationStage> {
  bool _done = false;
  int _xpEarned = 0;

  CityActivity get _activity => widget.mission.primarySkill.applicationActivity;

  @override
  Widget build(BuildContext context) {
    if (_done) return _completionView();

    final accent = Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Palette.radiusButton),
            ),
            child: Row(
              children: [
                const Text('🏗️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تطبيق المدينة — ${widget.mission.titleAr}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Activity
          Expanded(
            child: _buildActivityWidget(_activity, accent),
          ),
        ],
      ),
    );
  }

  /// Routes to the correct shared activity widget based on activity type.
  Widget _buildActivityWidget(CityActivity activity, Color accent) {
    final qd = activity.toQuestionData();
    return switch (activity.activityType) {
      'choice' => ActivityChoice(
           data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'numeric_input' => ActivityNumericInput(
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'drag_drop' => ActivityDragDrop(
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'spin' => ActivitySpin(
          data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'connect' => ActivityConnect(
           data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'tap_image' => ActivityTapImage(
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'open_response' => ActivityOpenResponse(
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      _ => ActivityChoice(
          data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
    };
  }

  void _onCorrect(int xp) async {
    final store = await CityProgressStore.load();
    final prog = store.getProgress(widget.mission.id);
    if (prog != null) {
      prog.xpEarned += xp;
      await store.updateMission(prog);
    }

    if (mounted) {
      setState(() {
        _xpEarned += xp;
        _done = true;
      });
    }
  }

  Widget _completionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MiddlePalette.success.withValues(alpha: 0.06),
              border: Border.all(color: MiddlePalette.success.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(Palette.radiusCard),
            ),
            child: Column(
              children: [
                const Text('🏗️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'تطبيق ممتاز!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: MiddlePalette.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$_xpEarned نقطة خبرة',
                  style: const TextStyle(
                    fontSize: 14,
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
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: MiddlePalette.primaryAction,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Palette.radiusButton),
                ),
                elevation: 0,
              ),
              child: const Text(
                'التحقق',
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