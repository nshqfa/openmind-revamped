/// Stage 4: التدريب (Training) — multiple practice activities.
/// Shows a list of activities; the learner works through them one by one.
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

class TrainingStage extends StatefulWidget {
  const TrainingStage({super.key, required this.mission, required this.onContinue});

  final CityMission mission;
  final VoidCallback onContinue;

  @override
  State<TrainingStage> createState() => _TrainingStageState();
}

class _TrainingStageState extends State<TrainingStage> {
  int _currentActivity = 0;
  int _xpEarned = 0;
  bool _allDone = false;

  List<CityActivity> get _activities => widget.mission.primarySkill.trainingActivities;

  @override
  Widget build(BuildContext context) {
    if (_allDone) return _completionView();
    if (_currentActivity >= _activities.length) {
      return const SizedBox();
    }
    return _activityView();
  }

  Widget _activityView() {
    final activity = _activities[_currentActivity];
    final accent = Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  'النشاط ${_currentActivity + 1} من ${_activities.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.body,
                  ),
                ),
                const Spacer(),
                if (_xpEarned > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MiddlePalette.discovery.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+$_xpEarned ⭐',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: MiddlePalette.discovery,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (_currentActivity) / _activities.length,
              minHeight: 4,
              color: accent,
              backgroundColor: MiddlePalette.softBlue,
            ),
          ),
          const SizedBox(height: 16),
          // Activity content
          Expanded(
            child: _buildActivityWidget(activity, accent),
          ),
        ],
      ),
    );
  }

  /// Routes to the correct shared activity widget based on [activity.activityType].
  Widget _buildActivityWidget(CityActivity activity, Color accent) {
    final key = ValueKey('activity_$_currentActivity');
    final qd = activity.toQuestionData();
    return switch (activity.activityType) {
      'choice' => ActivityChoice(
          key: key,
           data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'numeric_input' => ActivityNumericInput(
          key: key,
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'drag_drop' => ActivityDragDrop(
          key: key,
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'spin' => ActivitySpin(
          key: key,
          data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'connect' => ActivityConnect(
          key: key,
           data: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'tap_image' => ActivityTapImage(
          key: key,
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      'open_response' => ActivityOpenResponse(
          key: key,
          question: qd,
          accent: accent,
          onCorrect: _onCorrect,
        ),
      _ => ActivityChoice(
          key: key,
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
      });
      // Auto-advance after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _currentActivity++;
            if (_currentActivity >= _activities.length) {
              _allDone = true;
            }
          });
        }
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
                const Text('🎯', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'أحسنت! أكملت التدريب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: MiddlePalette.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$_xpEarned نقطة خبرة من التدريب',
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
                'تطبيق المدينة',
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