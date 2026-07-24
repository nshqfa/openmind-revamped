/// Mission detail screen — shows the 6 stages (scene → discovery → explanation
/// → training → application → verification) as a stepper with content panels.
/// Follows the ExperienceScreen pattern: advancing stages, recording progress.
library;

import 'package:flutter/material.dart';

import '../../core/middle_palette.dart';
import '../../core/palette.dart';
import '../../widgets/mascot.dart';
import 'city_models.dart';
import 'city_progress_store.dart';
import 'stages/scene_stage.dart';
import 'stages/discovery_stage.dart';
import 'stages/explanation_stage.dart';
import 'stages/training_stage.dart';
import 'stages/application_stage.dart';
import 'stages/verification_stage.dart';

/// The 6-stage mission player. Shows a horizontal step indicator at the top
/// and the current stage's content below. The learner advances through stages
/// in order; the verification (checkpoint) is the final gate.
class CityMissionScreen extends StatefulWidget {
  const CityMissionScreen({super.key, required this.mission});

  final CityMission mission;

  @override
  State<CityMissionScreen> createState() => _CityMissionScreenState();
}

class _CityMissionScreenState extends State<CityMissionScreen> {
  int _stageIndex = 0;
  MissionProgress? _progress;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await CityProgressStore.load();
    final prog = store.getProgress(widget.mission.id);
    if (prog != null && mounted) {
      setState(() {
        _progress = prog;
        _stageIndex = prog.currentStageIndex;
        _loaded = true;
      });
    }
  }

  Future<void> _advanceStage(int newIndex) async {
    final store = await CityProgressStore.load();
    final prog = store.getProgress(widget.mission.id);
    if (prog == null) return;

    // Never go backward
    final target = newIndex > prog.currentStageIndex ? newIndex : prog.currentStageIndex;
    prog.currentStageIndex = target;
    if (prog.status == NodeStatus.available) {
      prog.status = NodeStatus.inProgress;
    }
    await store.updateMission(prog);

    if (mounted) {
      setState(() {
        _progress = prog;
        _stageIndex = target;
      });
    }
  }

  Future<void> _onComplete() async {
    final store = await CityProgressStore.load();
    final prog = store.getProgress(widget.mission.id);
    if (prog == null) return;

    prog.status = NodeStatus.completed;
    prog.checkpointPassed = true;
    prog.checkpointScore = 1.0;
    prog.xpEarned += 50; // checkpoint XP
    await store.updateMission(prog);

    // Unlock next mission
    if (widget.mission.id < 6) {
      final nextProg = store.getProgress(widget.mission.id + 1);
      if (nextProg != null && nextProg.status == NodeStatus.locked) {
        nextProg.status = NodeStatus.available;
        await store.updateMission(nextProg);
      }
    }

    if (mounted) {
      setState(() => _progress = prog);
      // Show completion dialog
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: MiddlePalette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Palette.radiusCard),
        ),
        title: Row(
          children: [
            const Mascot(
              size: 40,
              accent: MiddlePalette.success,
              expression: MascotExpression.celebrating,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '🎉 أحسنت!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: MiddlePalette.success,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'أكملت مهمة "${widget.mission.titleAr}" بنجاح!\n+٥٠ نقطة خبرة',
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: MiddlePalette.blueInk,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // back to map
            },
            child: const Text(
              'العودة للخريطة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: MiddlePalette.primaryAction,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final accent = Color(0xFF000000 | int.parse(widget.mission.colorHex.replaceFirst('#', ''), radix: 16));

    if (!_loaded || _progress == null) {
      return Scaffold(
        backgroundColor: MiddlePalette.cream,
        appBar: AppBar(
          backgroundColor: MiddlePalette.cream,
          surfaceTintColor: Colors.transparent,
          title: Text(widget.mission.titleAr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MiddlePalette.blueInk)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: MiddlePalette.cream,
      appBar: AppBar(
        backgroundColor: MiddlePalette.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mission.titleAr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: MiddlePalette.blueInk,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: MiddlePalette.discovery.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 14, color: MiddlePalette.discovery),
                const SizedBox(width: 4),
                Text(
                  '${_progress!.xpEarned}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MiddlePalette.discovery,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stage stepper
            _StageStepper(
              currentIndex: _stageIndex,
              accent: accent,
              completed: _progress!.checkpointPassed,
            ),
            const SizedBox(height: 8),
            // Stage content
            Expanded(
              child: _buildStageContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    final stage = kStageDefs[_stageIndex];
    final skill = widget.mission.primarySkill;

    switch (stage.type) {
      case 'scene':
        return SceneStage(
          key: const ValueKey('stage_scene'),
          mission: widget.mission,
          onContinue: () => _advanceStage(_stageIndex + 1),
        );
      case 'discovery':
        return DiscoveryStage(
          key: const ValueKey('stage_discovery'),
          mission: widget.mission,
          onContinue: () => _advanceStage(_stageIndex + 1),
        );
      case 'explanation':
        return ExplanationStage(
          key: const ValueKey('stage_explanation'),
          mission: widget.mission,
          onContinue: () => _advanceStage(_stageIndex + 1),
        );
      case 'training':
        return TrainingStage(
          key: const ValueKey('stage_training'),
          mission: widget.mission,
          onContinue: () => _advanceStage(_stageIndex + 1),
        );
      case 'application':
        return ApplicationStage(
          key: const ValueKey('stage_application'),
          mission: widget.mission,
          onContinue: () => _advanceStage(_stageIndex + 1),
        );
      case 'verification':
        return VerificationStage(
          key: const ValueKey('stage_verification'),
          mission: widget.mission,
          onComplete: _onComplete,
        );
      default:
        return const SizedBox();
    }
  }
}

/// The horizontal 6-step indicator at the top of the mission screen.
class _StageStepper extends StatelessWidget {
  const _StageStepper({
    required this.currentIndex,
    required this.accent,
    required this.completed,
  });

  final int currentIndex;
  final Color accent;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < kStageDefs.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? accent.withValues(alpha: 0.5)
                        : MiddlePalette.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            _StepDot(
              stage: kStageDefs[i]!,
              isActive: i == currentIndex,
              isCompleted: i < currentIndex || completed,
              accent: accent,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.stage,
    required this.isActive,
    required this.isCompleted,
    required this.accent,
  });

  final StageDef stage;
  final bool isActive;
  final bool isCompleted;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? accent
        : isCompleted
            ? MiddlePalette.success
            : MiddlePalette.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isActive ? 36 : 30,
          height: isActive ? 36 : 30,
          decoration: BoxDecoration(
            color: isActive
                ? accent.withValues(alpha: 0.15)
                : isCompleted
                    ? MiddlePalette.success.withValues(alpha: 0.12)
                    : MiddlePalette.softBlue,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: accent, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            isCompleted && !isActive ? '✓' : stage.icon,
            style: TextStyle(
              fontSize: isActive ? 16 : 13,
              color: isCompleted && !isActive ? MiddlePalette.success : color,
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 48,
          child: Text(
            stage.titleAr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? accent : MiddlePalette.body,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}