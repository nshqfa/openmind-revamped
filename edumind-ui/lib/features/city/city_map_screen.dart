/// مدينة لا تنهار — City map showing all 6 missions as nodes connected
/// by a road. Follows the MiddlePalette design language and the JourneyScreen
/// pattern from the existing codebase.
library;

import 'package:flutter/material.dart';

import '../../core/middle_palette.dart';
import '../../core/palette.dart';
import '../../widgets/mascot.dart';
import 'city_models.dart';
import 'city_mock_data.dart';
import 'city_progress_store.dart';
import 'city_mission_screen.dart';

/// The main city map — one decision: pick a mission. Each node shows its
/// Arabic title, emoji, status, and progress. Tapping an available/in_progress
/// mission opens the mission detail.
class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  Map<int, MissionProgress>? _progress;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    CityProgressStore.revision.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    CityProgressStore.revision.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) _load();
  }

  Future<void> _load() async {
    final store = await CityProgressStore.load();
    if (mounted) {
      setState(() {
        _progress = store.allProgress;
        _loaded = true;
      });
    }
  }

  void _openMission(CityMission mission) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CityMissionScreen(mission: mission),
      ),
    ).then((_) {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final progress = _progress;

    return Scaffold(
      backgroundColor: MiddlePalette.cream,
      appBar: AppBar(
        backgroundColor: MiddlePalette.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'مدينة لا تنهار',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: MiddlePalette.blueInk,
          ),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  _header(progress!),
                  const SizedBox(height: 16),
                  ..._buildRoad(progress!, rtl),
                ],
              ),
            ),
    );
  }

  Widget _header(Map<int, MissionProgress> progress) {
    final totalXp = progress.values.fold<int>(0, (sum, p) => sum + p.xpEarned);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiddlePalette.card,
        border: Border.all(color: MiddlePalette.outline),
        borderRadius: BorderRadius.circular(Palette.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Mascot(
                size: 48,
                accent: MiddlePalette.blueInk,
                expression: MascotExpression.happy,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 مرحباً في المدينة!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: MiddlePalette.blueInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'أكمل المهام لإنقاذ المدينة',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: MiddlePalette.body,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statChip(
                  icon: Icons.star_rounded,
                  label: 'نقاط الخبرة',
                  value: '$totalXp',
                  color: MiddlePalette.discovery,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statChip(
                  icon: Icons.check_circle_rounded,
                  label: 'المهام المكتملة',
                  value: '${progress.values.where((p) => p.status == NodeStatus.completed).length}/6',
                  color: MiddlePalette.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Palette.radiusButton),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: MiddlePalette.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoad(Map<int, MissionProgress> progress, bool rtl) {
    final widgets = <Widget>[];
    for (var i = 0; i < kCityMissions.length; i++) {
      final mission = kCityMissions[i]!;
      final prog = progress[mission.id]!;
      final isOpen = prog.status != NodeStatus.locked;

      // Road connector between nodes
      if (i > 0) {
        widgets.add(_roadConnector(
          color: Color(0xFF000000 | int.parse(mission.colorHex.replaceFirst('#', ''), radix: 16)),
          active: prog.status == NodeStatus.completed ||
              progress[kCityMissions[i - 1]!.id]!.status == NodeStatus.completed,
        ));
      }

      widgets.add(_MissionNodeCard(
        mission: mission,
        progress: prog,
        onTap: isOpen ? () => _openMission(mission) : null,
      ));
    }
    return widgets;
  }

  Widget _roadConnector({required Color color, required bool active}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: active ? color : MiddlePalette.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One mission node on the city map — follows the JourneyScreen._pathRow style.
class _MissionNodeCard extends StatelessWidget {
  const _MissionNodeCard({
    required this.mission,
    required this.progress,
    required this.onTap,
  });

  final CityMission mission;
  final MissionProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final accent = Color(0xFF000000 | int.parse(mission.colorHex.replaceFirst('#', ''), radix: 16));
    final isOpen = progress.status != NodeStatus.locked;
    final isCompleted = progress.status == NodeStatus.completed;
    final isInProgress = progress.status == NodeStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isCompleted
            ? MiddlePalette.success.withValues(alpha: 0.06)
            : MiddlePalette.card,
        borderRadius: BorderRadius.circular(Palette.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(Palette.radiusCard),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isCompleted
                    ? MiddlePalette.success.withValues(alpha: 0.4)
                    : isOpen
                        ? accent.withValues(alpha: 0.3)
                        : MiddlePalette.outline,
              ),
              borderRadius: BorderRadius.circular(Palette.radiusCard),
            ),
            child: Row(
              children: [
                // Mission number badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isOpen
                        ? accent.withValues(alpha: 0.12)
                        : MiddlePalette.softBlue,
                    borderRadius: BorderRadius.circular(Palette.radiusButton),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isCompleted ? '✅' : isOpen ? mission.emoji : '🔒',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                // Title and progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_arabicNumeral(mission.id)}. ${mission.titleAr}',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: isOpen
                                  ? MiddlePalette.blueInk
                                  : MiddlePalette.body,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mission.titleEn,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: MiddlePalette.body,
                        ),
                      ),
                      // Stage progress bar
                      if (isOpen && !isCompleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress.currentStageIndex / 6,
                                  minHeight: 6,
                                  color: accent,
                                  backgroundColor: MiddlePalette.softBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_arabicNumeral(progress.currentStageIndex + 1)}/٦',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isCompleted) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: MiddlePalette.success),
                            const SizedBox(width: 4),
                            Text(
                              'مكتمل — ${_arabicNumeral(progress.xpEarned)} نقطة',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: MiddlePalette.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                if (isCompleted)
                  const SizedBox()
                else if (isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MiddlePalette.discovery.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'جاري',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MiddlePalette.discovery,
                      ),
                    ),
                  )
                else if (isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'ابدأ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  )
                else
                  Text(
                    'قريباً',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MiddlePalette.body,
                    ),
                  ),
                const SizedBox(width: 4),
                if (isOpen)
                  Icon(
                    rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                    color: MiddlePalette.body,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _arabicNumeral(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null && d < 10 ? digits[d] : c;
    }).join();
  }
}
