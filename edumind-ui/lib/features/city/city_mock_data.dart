/// Complete mock data for مدينة لا تنهار — matches backend seed_city_content.ts.
///
/// Contains ALL 6 missions with depth-0 and depth-1 skills, 7 activity types,
/// structured dataJson, leveled hints, and error patterns.
library;

import 'city_models.dart';

final kCityMissions = [
  // ═══════════════════════════════════════════════════════════════════════════
  // MISSION 1: شوارع لا تتصادم — parallel_lines
  // ═══════════════════════════════════════════════════════════════════════════
  CityMission(
    id: 1,
    conceptKey: 'parallel_lines',
    cityMission: 'streets_no_collision',
    titleAr: 'شوارع لا تتصادم',
    titleEn: 'Streets Without Collisions',
    emoji: '🛣️',
    colorHex: '#2196F3',
    scene: BilingualText(
      en: 'A new road crosses two parallel streets. We need to set up the traffic signals at the intersections correctly.',
      ar: 'شارع جديد يعبر طريقين متوازيين، ويجب ضبط التقاطعات لوضع الإشارات بطريقة صحيحة.',
    ),
    discovery: BilingualText(
      en: 'Drag the transversal line and change its angle. Observe which angles remain equal and which change.',
      ar: 'اسحب القاطع وغير ميله، ثم اضغط على الزوايا وراقب ما يبقى متساوياً.',
    ),
    explanation: BilingualText(
      en: 'When parallel lines are cut by a transversal, corresponding angles are always equal.',
      ar: 'زاويتان متقابلتان بالرأس تتساويان دائماً عند تقاطع مستقيمين.',
    ),
    skills: [
      // ── Depth 0: Introduction ──
      CitySkill(
        skillId: 'parallel_lines_intro',
        depth: 0,
        title: 'Parallel & Perpendicular Lines: Introduction',
        titleAr: 'المستقيم المتوازي والقاطع: مقدمة',
        topic: 'Identifying parallel, perpendicular, and intersecting lines',
        trainingActivities: [
          CityActivity(
            id: 'm1d0_t1',
            activityType: 'choice',
            prompt: 'Two lines that never meet are called:',
            promptAr: 'مستقيمان لا يلتقيان في أي نقطة يُسميان:',
            options: ['Parallel lines', 'Perpendicular lines', 'Intersecting lines', 'Curved lines'],
            correctAnswer: 0,
            dataJson: {'options': ['Parallel lines', 'Perpendicular lines', 'Intersecting lines', 'Curved lines']},
            correctionRulesJson: {'errorPatterns': [{'condition': 'chose_perpendicular', 'label': 'confused_parallel_perpendicular'}]},
            hints: [
              BilingualText(en: 'Think about train tracks — do they ever meet?', ar: 'فكّر في قضبان القطار — هل تلتقي يوماً؟'),
              BilingualText(en: 'Parallel lines keep the same distance apart.', ar: 'المستقيمات المتوازية تحافظ على نفس المسافة بينها.'),
              BilingualText(en: 'The answer starts with "Para" — like "parallel".', ar: 'الإجابة تبدأ بـ "متوازية".'),
            ],
            xpReward: 10,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d0_t2',
            activityType: 'drag_drop',
            prompt: 'Sort each pair of lines into the correct category.',
            promptAr: 'اسحب كل زوج من المستقيمات وضعه في التصنيف الصحيح.',
            correctAnswer: {'placements': [{'slotId': 's1', 'itemId': 'a'}, {'slotId': 's2', 'itemId': 'b'}, {'slotId': 's3', 'itemId': 'c'}]},
            dataJson: {
              'items': [
                {'id': 'a', 'label': '↔ ↔ (equal distance)'},
                {'id': 'b', 'label': '↔ ⊥ ↔ (right angle)'},
                {'id': 'c', 'label': '↔ ╳ ↔ (crossing)'},
              ],
              'slots': [
                {'id': 's1', 'label': 'Parallel', 'correctItemId': 'a'},
                {'id': 's2', 'label': 'Perpendicular', 'correctItemId': 'b'},
                {'id': 's3', 'label': 'Intersecting', 'correctItemId': 'c'},
              ],
            },
            hints: [
              BilingualText(en: 'Parallel = same direction, Perpendicular = right angle, Intersecting = cross.', ar: 'متوازي = نفس الاتجاه، عمودي = زاوية قائمة، متقاطع = يتقاطعان.'),
              BilingualText(en: 'The ⊥ symbol means perpendicular (90°).', ar: 'الرمز ⊥ يعني العمودي (90°).'),
              BilingualText(en: 'Equal-distance pair → parallel. Right-angle pair → perpendicular.', ar: 'الزوج المتساوي المسافة → متوازي. الزاوية القائمة → عمودي.'),
            ],
            xpReward: 15,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d0_t3',
            activityType: 'connect',
            prompt: 'Match each line relationship with its correct description.',
            promptAr: 'طابق كل علاقة بين المستقيمات بالوصف الصحيح.',
            correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}]},
            dataJson: {
              'leftItems': [
                {'id': 'l1', 'label': 'Parallel lines (مستقيمات متوازية)'},
                {'id': 'l2', 'label': 'Perpendicular lines (مستقيمات عمودية)'},
              ],
              'rightItems': [
                {'id': 'r1', 'label': 'Never meet, same distance apart'},
                {'id': 'r2', 'label': 'Meet at 90°'},
                {'id': 'r3', 'label': 'Meet at various angles'},
              ],
              'correctPairs': [
                {'leftId': 'l1', 'rightId': 'r1'},
                {'leftId': 'l2', 'rightId': 'r2'},
              ],
            },
            hints: [
              BilingualText(en: 'Parallel lines never meet — like railroad tracks.', ar: 'المستقيمات المتوازية لا تلتقي أبداً — مثل قضبان السكة الحديدية.'),
              BilingualText(en: 'Perpendicular means they cross at a right angle (90°).', ar: 'العمودي يعني يتقاطعان بزاوية قائمة (90°).'),
            ],
            xpReward: 15,
            skillId: 'parallel_lines',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm1d0_app',
          activityType: 'tap_image',
          prompt: 'In the city intersection, identify all pairs of angles that are equal. Tap all the correct statements.',
          promptAr: 'في تقاطع المدينة، حدّد جميع أزواج الزوايا المتساوية. انقر على جميع العبارات الصحيحة.',
          correctAnswer: [0, 1, 3],
          dataJson: {
            'regions': [
              {'id': 'r1', 'label': 'Corresponding angles are equal', 'isCorrect': true},
              {'id': 'r2', 'label': 'Alternate interior angles are equal', 'isCorrect': true},
              {'id': 'r3', 'label': 'Same-side interior angles are equal', 'isCorrect': false},
              {'id': 'r4', 'label': 'Vertical angles are equal', 'isCorrect': true},
            ],
          },
          correctionRulesJson: {'partialCredit': true},
          hints: [
            BilingualText(en: 'Same-side interior angles are supplementary (add to 180°), not equal.', ar: 'الزوايا الداخلية في نفس الجانب متكاملة (مجموعها 180°) وليست متساوية.'),
            BilingualText(en: 'Corresponding, alternate interior, and vertical angles are all equal.', ar: 'المناظرة، المتبادلة داخلية، والمتقابلة بالرأس كلها متساوية.'),
          ],
          xpReward: 20,
          skillId: 'parallel_lines',
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm1d0_q1',
            type: 'choice',
            prompt: 'Two parallel lines are cut by a transversal. One angle is 110°. What is its vertically opposite angle?',
            promptAr: 'مستقيمان متوازيان يقطعهما قاطع. إحدى الزوايا 110°. ما الزاوية المقابلة لها بالرأس؟',
            correctAnswer: 1,
            options: ['70°', '110°', '90°', '180°'],
            errorPatterns: [{'condition': 'supplement_confusion', 'label': 'chose_supplement_instead_of_vertical'}],
          ),
          CheckpointQuestion(
            id: 'm1d0_q2',
            type: 'connect',
            prompt: 'Match each angle pair with its property when parallel lines are cut by a transversal.',
            promptAr: 'طابق كل زوج زوايا بخصائصه عند قطع مستقيمين متوازيين بقاطع.',
            correctAnswer: {'Corresponding': 'Equal', 'Same-side interior': 'Supplementary'},
            options: ['Equal', 'Supplementary', 'Complementary'],
          ),
          CheckpointQuestion(
            id: 'm1d0_q3',
            type: 'numeric_input',
            prompt: 'Two parallel lines are cut by a transversal. Angle A = 45°. What is the corresponding angle B?',
            promptAr: 'قاطع يقطع مستقيمين متوازيين. الزاوية A = 45°. ما الزاوية المناظرة B؟',
            correctAnswer: 45,
          ),
        ],
      ),
      // ── Depth 1: Angle Relationships ──
      CitySkill(
        skillId: 'parallel_lines_deep',
        depth: 1,
        title: 'Parallel Lines: Angle Relationships',
        titleAr: 'المستقيم المتوازي: علاقات الزوايا',
        topic: 'Alternate interior, alternate exterior, and corresponding angles',
        trainingActivities: [
          CityActivity(
            id: 'm1d1_t1',
            activityType: 'spin',
            prompt: 'Spin the wheel to find the alternate interior angle when parallel lines are cut by a transversal forming 130°.',
            promptAr: 'دوّر العجلة لإيجاد الزاوية المتبادلة داخلية عند قطع متوازيين بقاطع بزاوية 130°.',
            correctAnswer: {'correctSegmentId': 'w2'},
            dataJson: {
              'wheelSegments': [
                {'id': 'w1', 'label': '50°'},
                {'id': 'w2', 'label': '130°'},
                {'id': 'w3', 'label': '90°'},
                {'id': 'w4', 'label': '60°'},
              ],
              'correctSegmentId': 'w2',
            },
            hints: [
              BilingualText(en: 'Alternate interior angles are equal when lines are parallel.', ar: 'الزوايا المتبادلة داخلية متساوية عند توازي المستقيمات.'),
              BilingualText(en: 'Same measure as the given angle.', ar: 'نفس قياس الزاوية المعطاة.'),
            ],
            xpReward: 10,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d1_t2',
            activityType: 'numeric_input',
            prompt: 'Parallel lines are cut by a transversal. An exterior angle is 120°. What is its alternate exterior angle?',
            promptAr: 'قاطع يقطع مستقيمين متوازيين. زاوية خارجية 120°. ما الزاوية المتبادلة الخارجية لها؟',
            correctAnswer: 120,
            dataJson: {},
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'Alternate exterior angles follow the same rule as alternate interior.', ar: 'الزوايا المتبادلة خارجية تتبع نفس قاعدة المتبادلة داخلية.'),
              BilingualText(en: 'They are equal.', ar: 'تساويان.'),
            ],
            xpReward: 15,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d1_t3',
            activityType: 'choice',
            prompt: 'If two parallel lines are cut by a transversal, which pair is NOT always equal?',
            promptAr: 'إذا قطع قاطع مستقيمين متوازيين، أي زوج ليس متساوياً دائماً؟',
            options: ['Corresponding angles', 'Alternate interior angles', 'Alternate exterior angles', 'Same-side interior angles'],
            correctAnswer: 3,
            dataJson: {'options': ['Corresponding angles', 'Alternate interior angles', 'Alternate exterior angles', 'Same-side interior angles']},
            hints: [
              BilingualText(en: 'Same-side interior angles are supplementary, not equal.', ar: 'الزوايا الداخلية في نفس الجانب متكاملة وليست متساوية.'),
            ],
            xpReward: 10,
            skillId: 'parallel_lines',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm1d1_app',
          activityType: 'connect',
          prompt: 'Design the bridge supports: match each angle relationship to its value when the transversal cut angle is 75°.',
          promptAr: 'صمّم دعامات الجسر: طابق كل علاقة زوايا بقيمتها عندما زاوية القاطع 75°.',
          correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r1'}]},
          dataJson: {
            'leftItems': [
              {'id': 'l1', 'label': 'Corresponding angle'},
              {'id': 'l2', 'label': 'Same-side interior angle'},
              {'id': 'l3', 'label': 'Alternate interior angle'},
            ],
            'rightItems': [
              {'id': 'r1', 'label': '75°'},
              {'id': 'r2', 'label': '105°'},
            ],
            'correctPairs': [
              {'leftId': 'l1', 'rightId': 'r1'},
              {'leftId': 'l2', 'rightId': 'r2'},
              {'leftId': 'l3', 'rightId': 'r1'},
            ],
          },
          correctionRulesJson: {'partialCredit': true},
          hints: [
            BilingualText(en: 'Corresponding and alternate interior are equal to the transversal angle.', ar: 'المناظرة والمتبادلة داخلية تساوي زاوية القاطع.'),
            BilingualText(en: 'Same-side interior = 180° − transversal angle.', ar: 'الداخلية في نفس الجانب = 180° − زاوية القاطع.'),
            BilingualText(en: 'If one angle is 75°, the same-side interior is 180° - 75° = 105°.', ar: 'إذا إحدى الزوايا 75°، الداخلية في نفس الجانب = 180° - 75° = 105°.'),
          ],
          xpReward: 25,
          skillId: 'parallel_lines',
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm1d1_q1',
            type: 'numeric_input',
            prompt: 'Parallel lines cut by a transversal. One alternate interior angle is 85°. What is the other?',
            promptAr: 'قاطع يقطع مستقيمين متوازيين. إحدى الزوايا المتبادلة داخلية 85°. ما الأخرى؟',
            correctAnswer: 85,
          ),
          CheckpointQuestion(
            id: 'm1d1_q2',
            type: 'spin',
            prompt: 'An exterior angle on one side is 140°. Spin to find the interior angle on the same side.',
            promptAr: 'زاوية خارجية في أحد الجانبين 140°. دوّر العجلة لإيجاد الزاوية الداخلية في نفس الجانب.',
            correctAnswer: 1,
            options: ['40°', '140°', '90°', '50°'],
          ),
          CheckpointQuestion(
            id: 'm1d1_q3',
            type: 'tap_image',
            prompt: 'Tap all the angle pairs that are ALWAYS equal when parallel lines are cut by a transversal.',
            promptAr: 'انقر على جميع أزواج الزوايا التي تكون متساوية دائماً عند قطع متوازيين بقاطع.',
            correctAnswer: [0, 1, 3],
            options: ['Corresponding angles', 'Same-side interior', 'Alternate interior angles', 'Alternate exterior angles', 'Adjacent angles'],
          ),
        ],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // MISSION 2: تقاطع الطرق الذكي — angles
  // ═══════════════════════════════════════════════════════════════════════════
  CityMission(
    id: 2,
    conceptKey: 'angles',
    cityMission: 'smart_intersection',
    titleAr: 'تقاطع الطرق الذكي',
    titleEn: 'The Smart Intersection',
    emoji: '🚦',
    colorHex: '#FF9800',
    scene: BilingualText(
      en: 'The smart intersection uses angle sensors. We need to program the sensors by understanding angle relationships.',
      ar: 'تقاطع ذكي يستخدم حساسات زوايا. نحتاج برمجتها بفهم علاقات الزوايا.',
    ),
    discovery: BilingualText(
      en: 'Change the angles in the intersection and observe which pairs always add up to 180° and which are always equal.',
      ar: 'غيّر الزوايا في التقاطع ولاحظ أي أزواج مجموعها دائماً 180° وأيها متساوية دائماً.',
    ),
    explanation: BilingualText(
      en: 'At an intersection, vertical angles are equal, and adjacent angles are supplementary (add to 180°).',
      ar: 'في التقاطع، الزوايا المتقابلة بالرأس متساوية، والمجاورة متكاملة (مجموعها 180°).',
    ),
    skills: [
      // ── Depth 0 ──
      CitySkill(
        skillId: 'angles_intro',
        depth: 0,
        title: 'Angle Types: Acute, Right, Obtuse',
        titleAr: 'أنواع الزوايا: حادة، قائمة، منفرجة',
        topic: 'Classifying angles by their measure',
        trainingActivities: [
          CityActivity(
            id: 'm2d0_t1',
            activityType: 'choice',
            prompt: 'An angle that measures 120° is called:',
            promptAr: 'زاوية قياسها 120° تُسمى:',
            options: ['Acute', 'Right', 'Obtuse', 'Straight'],
            correctAnswer: 2,
            dataJson: {'options': ['Acute', 'Right', 'Obtuse', 'Straight']},
            hints: [
              BilingualText(en: 'Acute < 90°, Right = 90°, Obtuse > 90° and < 180°.', ar: 'حادة < 90°، قائمة = 90°، منفرجة > 90° و < 180°.'),
              BilingualText(en: '120° is greater than 90°.', ar: '120° أكبر من 90°.'),
              BilingualText(en: 'The answer is "Obtuse" (منفرجة).', ar: 'الإجابة "منفرجة".'),
            ],
            xpReward: 10,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d0_t2',
            activityType: 'tap_image',
            prompt: 'Tap all the angles that are acute (less than 90°).',
            promptAr: 'انقر على جميع الزوايا الحادة (أقل من 90°).',
            correctAnswer: [0, 3],
            dataJson: {
              'regions': [
                {'id': 'r1', 'label': '35°', 'isCorrect': true},
                {'id': 'r2', 'label': '90°', 'isCorrect': false},
                {'id': 'r3', 'label': '120°', 'isCorrect': false},
                {'id': 'r4', 'label': '60°', 'isCorrect': true},
                {'id': 'r5', 'label': '180°', 'isCorrect': false},
              ],
            },
            hints: [
              BilingualText(en: 'Acute angles are less than 90°. Right = exactly 90°.', ar: 'الزوايا الحادة أقل من 90°. القائمة = بالضبط 90°.'),
            ],
            xpReward: 15,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d0_t3',
            activityType: 'numeric_input',
            prompt: 'Two adjacent angles form a straight line. One is 70°. What is the other?',
            promptAr: 'زاويتان متجاورتان تشكلان مستقيماً. إحداهما 70°. ما الأخرى؟',
            correctAnswer: 110,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'supplement_confusion', 'label': 'supplement_miscalculation'}]},
            hints: [
              BilingualText(en: 'Adjacent angles on a straight line add up to 180°.', ar: 'الزاويتان المتجاورتان على مستقيم مجموعهما 180°.'),
              BilingualText(en: '180° - 70° = ?', ar: '180° - 70° = ؟'),
            ],
            xpReward: 10,
            skillId: 'angles',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm2d0_app',
          activityType: 'spin',
          prompt: 'At the smart intersection, two intersecting lines form four angles. One angle is 35°. Spin to find its vertically opposite angle.',
          promptAr: 'في التقاطع الذكي، مستقيمان يتقاطعان يكوّنان أربع زوايا. إحداها 35°. دوّر العجلة لإيجاد الزاوية المقابلة بالرأس.',
          correctAnswer: {'correctSegmentId': 'w1'},
          dataJson: {
            'wheelSegments': [
              {'id': 'w1', 'label': '35°'},
              {'id': 'w2', 'label': '145°'},
              {'id': 'w3', 'label': '55°'},
              {'id': 'w4', 'label': '90°'},
            ],
            'correctSegmentId': 'w1',
          },
          hints: [
            BilingualText(en: 'Vertical angles are always equal.', ar: 'الزوايا المتقابلة بالرأس متساوية دائماً.'),
            BilingualText(en: 'The opposite angle has the same measure.', ar: 'الزاوية المقابلة لها نفس القياس.'),
          ],
          xpReward: 20,
          skillId: 'angles',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm2d0_q1', type: 'choice', prompt: 'An angle measuring 45° is classified as:', promptAr: 'زاوية قياسها 45° تُصنف:', correctAnswer: 0, options: ['Acute', 'Right', 'Obtuse', 'Straight']),
          CheckpointQuestion(id: 'm2d0_q2', type: 'numeric_input', prompt: 'Adjacent angles on a straight line: one is 130°. What is the other?', promptAr: 'زاويتان متجاورتان على مستقيم: إحداهما 130°. ما الأخرى؟', correctAnswer: 50),
          CheckpointQuestion(id: 'm2d0_q3', type: 'open_response', prompt: 'In one sentence, what is the relationship between vertical angles?', promptAr: 'في جملة واحدة، ما علاقة الزوايا المتقابلة بالرأس؟', correctAnswer: ['متساوية', 'متساويتان', 'تساوي', 'equal']),
        ],
      ),
      // ── Depth 1 ──
      CitySkill(
        skillId: 'angles_deep',
        depth: 1,
        title: 'Angle Relationships: Supplementary & Complementary',
        titleAr: 'علاقات الزوايا: المتكاملة والمتتامة',
        topic: 'Supplementary (180°) and Complementary (90°) angle pairs',
        trainingActivities: [
          CityActivity(
            id: 'm2d1_t1',
            activityType: 'numeric_input',
            prompt: 'Two angles are complementary. One is 37°. What is the other?',
            promptAr: 'زاويتان متتامتان. إحداهما 37°. ما الأخرى؟',
            correctAnswer: 53,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'Complementary angles add up to 90°.', ar: 'الزوايا المتتامان مجموعها 90°.'),
              BilingualText(en: '90° - 37° = ?', ar: '90° - 37° = ؟'),
            ],
            xpReward: 10,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d1_t2',
            activityType: 'connect',
            prompt: 'Match each angle pair with its relationship type.',
            promptAr: 'طابق كل زوج زوايا بنوع العلاقة.',
            correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r2'}]},
            dataJson: {
              'leftItems': [
                {'id': 'l1', 'label': '60° + 30°'},
                {'id': 'l2', 'label': '110° + 70°'},
                {'id': 'l3', 'label': '45° + 135°'},
              ],
              'rightItems': [
                {'id': 'r1', 'label': 'Complementary (90°)'},
                {'id': 'r2', 'label': 'Supplementary (180°)'},
              ],
              'correctPairs': [
                {'leftId': 'l1', 'rightId': 'r1'},
                {'leftId': 'l2', 'rightId': 'r2'},
                {'leftId': 'l3', 'rightId': 'r2'},
              ],
            },
            hints: [
              BilingualText(en: 'Complementary = sum 90°. Supplementary = sum 180°.', ar: 'متتامان = مجموع 90°. متكاملان = مجموع 180°.'),
              BilingualText(en: '60+30=90, 110+70=180, 45+135=180.', ar: '60+30=90، 110+70=180، 45+135=180.'),
            ],
            xpReward: 15,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d1_t3',
            activityType: 'open_response',
            prompt: 'Explain why an angle of 100° cannot have a complementary angle.',
            promptAr: 'اشرح لماذا زاوية 100° لا يمكن أن يكون لها زاوية متتامة.',
            correctAnswer: ['أكبر من 90', 'أكثر من 90', 'greater than 90', 'exceeds 90', 'تتامان مجموعها 90'],
            hints: [
              BilingualText(en: 'Think about what complementary means — their sum.', ar: 'فكّر ما معنى متتامان — مجموعهما.'),
              BilingualText(en: 'Complementary angles add up to 90°. Can a positive angle add to 100° and give 90°?', ar: 'الزوايا المتتامان مجموعها 90°. هل يمكن لزاوية موجبة أن تجمع مع 100° وتعطي 90°؟'),
            ],
            xpReward: 15,
            skillId: 'angles',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm2d1_app',
          activityType: 'drag_drop',
          prompt: 'Sort each angle pair sum into the correct category: complementary, supplementary, or neither.',
          promptAr: 'صنّف كل مجموع زوايا في الفئة الصحيحة: متتامان، متكاملان، أو لا شيء.',
          correctAnswer: {'placements': [{'slotId': 's1', 'itemId': 'a'}, {'slotId': 's2', 'itemId': 'b'}, {'slotId': 's3', 'itemId': 'c'}, {'slotId': 's4', 'itemId': 'd'}]},
          dataJson: {
            'items': [
              {'id': 'a', 'label': '25° + 65°'},
              {'id': 'b', 'label': '95° + 95°'},
              {'id': 'c', 'label': '150° + 30°'},
              {'id': 'd', 'label': '50° + 50°'},
            ],
            'slots': [
              {'id': 's1', 'label': 'Complementary (90°)', 'correctItemId': 'a'},
              {'id': 's2', 'label': 'Neither', 'correctItemId': 'b'},
              {'id': 's3', 'label': 'Supplementary (180°)', 'correctItemId': 'c'},
              {'id': 's4', 'label': 'Complementary (90°)', 'correctItemId': 'd'},
            ],
          },
          hints: [
            BilingualText(en: '95° + 95° = 190° ≠ 90° and ≠ 180°, so it is neither.', ar: '95° + 95° = 190° ≠ 90° و ≠ 180°، فلا ينتمي لأي فئة.'),
          ],
          xpReward: 20,
          skillId: 'angles',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm2d1_q1', type: 'numeric_input', prompt: 'Two complementary angles: one is 23°. What is the other?', promptAr: 'زاويتان متتامتان: إحداهما 23°. ما الأخرى؟', correctAnswer: 67),
          CheckpointQuestion(id: 'm2d1_q2', type: 'spin', prompt: 'If angle A = 90°, spin to find its complement.', promptAr: 'إذا الزاوية A = 90°، دوّر العجلة لإيجاد مكملتها.', correctAnswer: 0, options: ['0°', '45°', '90°', '180°']),
          CheckpointQuestion(id: 'm2d1_q3', type: 'connect', prompt: 'Match each relationship to its angle sum.', promptAr: 'طابق كل علاقة بمجموع الزوايا الخاص بها.', correctAnswer: {'Complementary': '90°', 'Supplementary': '180°', 'Full rotation': '360°'}, options: ['90°', '180°', '270°', '360°']),
        ],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // MISSION 3: جسر يبقى ثابتا — parallelogram
  // ═══════════════════════════════════════════════════════════════════════════
  CityMission(
    id: 3,
    conceptKey: 'parallelogram',
    cityMission: 'stable_bridge',
    titleAr: 'جسر يبقى ثابتاً',
    titleEn: 'A Bridge That Stays',
    emoji: '🌉',
    colorHex: '#4CAF50',
    scene: BilingualText(
      en: 'The old bridge is unstable. We need to verify that its parallelogram-shaped supports have the correct properties to hold.',
      ar: 'الجسر القديم غير مستقر. نحتاج التحقق من أن دعاماته على شكل متوازي أضلاع تمتلك الخصائص الصحيحة.',
    ),
    discovery: BilingualText(
      en: 'Measure the sides and angles of the bridge support. Drag vertices and observe how opposite sides stay equal and parallel.',
      ar: 'قِس أضلاع وزوايا دعامة الجسر. اسحب الرؤوس ولاحظ كيف يبقى الضلعان المتقابلان متساويين ومتوازيين.',
    ),
    explanation: BilingualText(
      en: 'In a parallelogram: opposite sides are equal and parallel, opposite angles are equal, and diagonals bisect each other.',
      ar: 'في متوازي الأضلاع: الأضلاع المتقابلة متساوية ومتوازية، والزوايا المتقابلة متساوية، والأقطار تنصف بعضها.',
    ),
    skills: [
      CitySkill(
        skillId: 'parallelogram_intro',
        depth: 0,
        title: 'Parallelogram: Basic Properties',
        titleAr: 'متوازي الأضلاع: الخصائص الأساسية',
        topic: 'Opposite sides parallel and equal, opposite angles equal',
        trainingActivities: [
          CityActivity(
            id: 'm3d0_t1',
            activityType: 'choice',
            prompt: 'In a parallelogram, opposite sides are:',
            promptAr: 'في متوازي الأضلاع، الأضلاع المتقابلة تكون:',
            options: ['Equal and parallel', 'Equal only', 'Parallel only', 'Perpendicular'],
            correctAnswer: 0,
            dataJson: {'options': ['Equal and parallel', 'Equal only', 'Parallel only', 'Perpendicular']},
            hints: [
              BilingualText(en: 'The name "parallelogram" contains "parallel".', ar: 'اسم "متوازي الأضلاع" يحتوي "متوازي".'),
              BilingualText(en: 'Both equal AND parallel.', ar: 'متساوية ومتوازية معاً.'),
            ],
            xpReward: 10,
            skillId: 'parallelogram',
          ),
          CityActivity(
            id: 'm3d0_t2',
            activityType: 'tap_image',
            prompt: 'Tap all the shapes that are parallelograms (have both pairs of opposite sides parallel).',
            promptAr: 'انقر على جميع الأشكال التي هي متوازيات أضلاع (كلا الزوجين من الأضلاع المتقابلة متوازيان).',
            correctAnswer: [0, 2, 4],
            dataJson: {
              'regions': [
                {'id': 'r1', 'label': 'Rectangle (4 right angles)', 'isCorrect': true},
                {'id': 'r2', 'label': 'Trapezoid (1 pair parallel)', 'isCorrect': false},
                {'id': 'r3', 'label': 'Rhombus (all sides equal)', 'isCorrect': true},
                {'id': 'r4', 'label': 'Kite (no parallel sides)', 'isCorrect': false},
                {'id': 'r5', 'label': 'Square (all equal + right angles)', 'isCorrect': true},
              ],
            },
            hints: [
              BilingualText(en: 'A trapezoid has only ONE pair of parallel sides.', ar: 'شبه المنحرف لديه زوج واحد فقط من الأضلاع المتوازية.'),
              BilingualText(en: 'A kite has no parallel sides at all.', ar: 'الطائرة الورقية لا تملك أضلاعاً متوازية إطلاقاً.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram',
          ),
          CityActivity(
            id: 'm3d0_t3',
            activityType: 'numeric_input',
            prompt: 'In a parallelogram, one side is 8 cm. What is the opposite side?',
            promptAr: 'في متوازي أضلاع، أحد أضلاعه 8 سم. ما الضلع المقابل؟',
            correctAnswer: 8,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'Opposite sides of a parallelogram are equal.', ar: 'الأضلاع المتقابلة في متوازي الأضلاع متساوية.'),
            ],
            xpReward: 10,
            skillId: 'parallelogram',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm3d0_app',
          activityType: 'choice',
          prompt: 'Bridge support: parallelogram shape. Angle A = 110°. Find angle B (adjacent).',
          promptAr: 'دعامة الجسر: شكل متوازي أضلاع. الزاوية A = 110°. أوجد الزاوية B (المجاورة).',
          options: ['70°', '80°', '110°', '140°'],
          correctAnswer: 0,
          dataJson: {'options': ['70°', '80°', '110°', '140°']},
          hints: [
            BilingualText(en: 'Adjacent angles are supplementary: they add to 180°.', ar: 'الزوايا المجاورة مكملتان: مجموعهما 180°.'),
            BilingualText(en: '180 - 110 = ?', ar: '180 - 110 = ؟'),
            BilingualText(en: 'The answer is 70°.', ar: 'الإجابة 70°.'),
          ],
          xpReward: 20,
          skillId: 'parallelogram',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm3d0_q1', type: 'choice', prompt: 'In a parallelogram, one angle is 50°. An adjacent angle is:', promptAr: 'في متوازي الأضلاع، إحدى الزوايا 50°. الزاوية المجاورة:', correctAnswer: 2, options: ['50°', '90°', '130°', '150°']),
          CheckpointQuestion(id: 'm3d0_q2', type: 'numeric_input', prompt: 'Parallelogram: side AB = 12 cm. Side CD (opposite) = ?', promptAr: 'متوازي أضلاع: الضلع AB = 12 سم. الضلع CD (المقابل) = ؟', correctAnswer: 12),
        ],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // MISSION 4: مبان بأشكال مختلفة — rectangle + square_rhombus
  // ═══════════════════════════════════════════════════════════════════════════
  CityMission(
    id: 4,
    conceptKey: 'rectangle_square_rhombus',
    cityMission: 'diverse_buildings',
    titleAr: 'مبانٍ بأشكال مختلفة',
    titleEn: 'Buildings of Different Shapes',
    emoji: '🏢',
    colorHex: '#9C27B0',
    scene: BilingualText(
      en: 'The city plan needs different building shapes: rectangles, squares, and rhombuses.',
      ar: 'تخطيط المباني يحتاج أشكالاً مختلفة: مستطيلات، مربعات، ومعينات.',
    ),
    discovery: BilingualText(
      en: 'Compare the shapes: drag vertices and observe which properties change and which stay fixed.',
      ar: 'قارن الأشكال: اسحب الرؤوس ولاحظ أي الخصائص تتغير وأيها تبقى ثابتة.',
    ),
    explanation: BilingualText(
      en: 'Rectangle = parallelogram with right angles. Square = rectangle with equal sides. Rhombus = parallelogram with equal sides.',
      ar: 'المستطيل = متوازي أضلاع بزوايا قائمة. المربع = مستطيل بأضلاع متساوية. المعين = متوازي أضلاع بأضلاع متساوية.',
    ),
    skills: [
      // ── Depth 0 ──
      CitySkill(
        skillId: 'rect_sq_rhomb_intro',
        depth: 0,
        title: 'Rectangle, Square & Rhombus: Identification',
        titleAr: 'المستطيل والمربع والمعين: التعرف والتمييز',
        topic: 'Identifying and distinguishing between quadrilateral types',
        trainingActivities: [
          CityActivity(
            id: 'm4d0_t1',
            activityType: 'choice',
            prompt: 'A parallelogram with four right angles is a:',
            promptAr: 'متوازي أضلاع بزوايا قائمة هو:',
            options: ['Rhombus', 'Rectangle', 'Square', 'Trapezoid'],
            correctAnswer: 1,
            dataJson: {'options': ['Rhombus', 'Rectangle', 'Square', 'Trapezoid']},
            hints: [
              BilingualText(en: 'Right angles + parallelogram = which shape?', ar: 'زوايا قائمة + متوازي أضلاع = أي شكل؟'),
              BilingualText(en: 'Think about a door or a window frame.', ar: 'فكّر في باب أو إطار نافذة.'),
              BilingualText(en: 'The answer is Rectangle.', ar: 'الإجابة: مستطيل.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d0_t2',
            activityType: 'choice',
            prompt: 'A square is a special case of:',
            promptAr: 'المربع هو حالة خاصة من:',
            options: ['Rhombus only', 'Rectangle only', 'Both rhombus and rectangle', 'Neither'],
            correctAnswer: 2,
            dataJson: {'options': ['Rhombus only', 'Rectangle only', 'Both rhombus and rectangle', 'Neither']},
            hints: [
              BilingualText(en: 'A square has equal sides (rhombus) AND right angles (rectangle).', ar: 'المربع أضلاعه متساوية (معين) وزواياه قائمة (مستطيل).'),
              BilingualText(en: 'It satisfies both definitions.', ar: 'يحقق كلا التعريفين.'),
              BilingualText(en: 'The answer is: Both rhombus and rectangle.', ar: 'الإجابة: المعين والمستطيل معاً.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d0_t3',
            activityType: 'tap_image',
            prompt: 'Inspect the building materials: tap all descriptions that apply to a RECTANGLE.',
            promptAr: 'افحص مواد البناء: انقر على جميع الأوصاف التي تنطبق على المستطيل.',
            correctAnswer: [0, 2, 3],
            dataJson: {
              'regions': [
                {'id': 'r1', 'label': 'All angles are 90°', 'isCorrect': true},
                {'id': 'r2', 'label': 'All sides are equal', 'isCorrect': false},
                {'id': 'r3', 'label': 'Opposite sides are equal and parallel', 'isCorrect': true},
                {'id': 'r4', 'label': 'Diagonals are equal', 'isCorrect': true},
                {'id': 'r5', 'label': 'Diagonals are perpendicular', 'isCorrect': false},
              ],
            },
            correctionRulesJson: {'partialCredit': true},
            hints: [
              BilingualText(en: 'A rectangle does NOT have equal sides or perpendicular diagonals.', ar: 'المستطيل ليس لديه أضلاع متساوية أو أقطار متعامدة.'),
            ],
            xpReward: 20,
            skillId: 'rectangle',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm4d0_app',
          activityType: 'choice',
          prompt: 'Building plan: which shape has 4 right angles AND all sides equal?',
          promptAr: 'خطة مبنى: أي شكل له 4 زوايا قائمة وجميع أضلاعه متساوية؟',
          options: ['Rectangle', 'Square', 'Rhombus', 'Parallelogram'],
          correctAnswer: 1,
          dataJson: {'options': ['Rectangle', 'Square', 'Rhombus', 'Parallelogram']},
          hints: [
            BilingualText(en: 'Right angles → rectangle. Equal sides → rhombus. Only one shape has BOTH.', ar: 'زوايا قائمة ← مستطيل. أضلاع متساوية ← معين. شكل واحد فقط يمتلك كليهما.'),
          ],
          xpReward: 20,
          skillId: 'rectangle',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm4d0_q1', type: 'choice', prompt: 'A shape with all sides equal and all angles 90° is a:', promptAr: 'شكل جميع أضلاعه متساوية وجميع زواياه 90° هو:', correctAnswer: 'Square', options: ['Rectangle', 'Square', 'Rhombus', 'Parallelogram']),
          CheckpointQuestion(id: 'm4d0_q2', type: 'numeric_input', prompt: 'Rectangle diagonals: one is 13 m. The other is:', promptAr: 'أقطار مستطيل: أحدهما 13 م. الآخر:', correctAnswer: 13),
          CheckpointQuestion(id: 'm4d0_q3', type: 'connect', prompt: 'Match each shape to a property that uniquely describes it.', promptAr: 'طابق كل شكل بخاصية تميزه.', correctAnswer: {'Rectangle': '4 right angles', 'Rhombus': 'All sides equal', 'Square': 'All equal + 4 right angles'}, options: ['4 right angles', 'All sides equal', 'All equal + 4 right angles', 'One pair parallel']),
        ],
      ),
      // ── Depth 1 ──
      CitySkill(
        skillId: 'rect_sq_rhomb_deep',
        depth: 1,
        title: 'Comparing Quadrilaterals: Area & Perimeter',
        titleAr: 'مقارنة الرباعيات: المساحة والمحيط',
        topic: 'Calculating area and perimeter for rectangles, squares, and rhombuses',
        trainingActivities: [
          CityActivity(
            id: 'm4d1_t1',
            activityType: 'numeric_input',
            prompt: 'Rectangle: length 10 m, width 7 m. Calculate the area.',
            promptAr: 'مستطيل: طوله 10 م وعرضه 7 م. احسب المساحة.',
            correctAnswer: 70,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'Area of rectangle = length × width.', ar: 'مساحة المستطيل = الطول × العرض.'),
              BilingualText(en: '10 × 7 = ?', ar: '10 × 7 = ؟'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d1_t2',
            activityType: 'spin',
            prompt: 'Rhombus: side length 5 m. Spin to find the perimeter.',
            promptAr: 'معين: طول ضلعه 5 م. دوّر العجلة لإيجاد المحيط.',
            correctAnswer: {'correctSegmentId': 'w3'},
            dataJson: {
              'wheelSegments': [
                {'id': 'w1', 'label': '10 m'},
                {'id': 'w2', 'label': '15 m'},
                {'id': 'w3', 'label': '20 m'},
                {'id': 'w4', 'label': '25 m'},
              ],
              'correctSegmentId': 'w3',
            },
            hints: [
              BilingualText(en: 'Perimeter = 4 × side (all sides equal).', ar: 'المحيط = 4 × الضلع (جميع الأضلاع متساوية).'),
              BilingualText(en: '4 × 5 = 20.', ar: '4 × 5 = 20.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d1_t3',
            activityType: 'open_response',
            prompt: 'What is the formula for the area of a rectangle?',
            promptAr: 'ما قانون مساحة المستطيل؟',
            correctAnswer: ['الطول', 'العرض', 'length', 'width', 'ضرب', 'multiply', 'القاعدة', 'الارتفاع'],
            hints: [
              BilingualText(en: 'It involves multiplying two measurements of the rectangle.', ar: 'يتضمن ضرب قياسين من المستطيل.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm4d1_app',
          activityType: 'connect',
          prompt: 'Match each shape to its correct area formula.',
          promptAr: 'طابق كل شكل بقانون مساحته الصحيح.',
          correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r3'}]},
          dataJson: {
            'leftItems': [
              {'id': 'l1', 'label': 'Rectangle'},
              {'id': 'l2', 'label': 'Square'},
              {'id': 'l3', 'label': 'Rhombus (using diagonals)'},
            ],
            'rightItems': [
              {'id': 'r1', 'label': 'length × width'},
              {'id': 'r2', 'label': 'side²'},
              {'id': 'r3', 'label': '(d1 × d2) ÷ 2'},
            ],
            'correctPairs': [
              {'leftId': 'l1', 'rightId': 'r1'},
              {'leftId': 'l2', 'rightId': 'r2'},
              {'leftId': 'l3', 'rightId': 'r3'},
            ],
          },
          hints: [
            BilingualText(en: 'Rectangle = length × width. Square = side × side. Rhombus = (d1 × d2) / 2.', ar: 'المستطيل = الطول × العرض. المربع = الضلع × الضلع. المعين = (ق1 × ق2) / 2.'),
          ],
          xpReward: 20,
          skillId: 'rectangle',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm4d1_q1', type: 'numeric_input', prompt: 'Square: side 9 m. Area = ?', promptAr: 'مربع: ضلعه 9 م. المساحة = ؟', correctAnswer: 81),
          CheckpointQuestion(id: 'm4d1_q2', type: 'numeric_input', prompt: 'Rectangle: 15 m × 4 m. Perimeter = ?', promptAr: 'مستطيل: 15 م × 4 م. المحيط = ؟', correctAnswer: 38),
          CheckpointQuestion(id: 'm4d1_q3', type: 'choice', prompt: 'Rhombus area using diagonals d1=10, d2=6:', promptAr: 'مساحة معين بالأقطار d1=10, d2=6:', correctAnswer: '30', options: ['30', '60', '16', '80']),
        ],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // MISSION 5: ساحة المدينة — parallelogram_area
  // ═══════════════════════════════════════════════════════════════════════════
  CityMission(
    id: 5,
    conceptKey: 'parallelogram_area',
    cityMission: 'city_square',
    titleAr: 'ساحة المدينة',
    titleEn: 'The City Square',
    emoji: '🏛️',
    colorHex: '#F44336',
    scene: BilingualText(
      en: 'The city square needs paving. We must calculate the area of parallelogram-shaped sections to order the right amount of material.',
      ar: 'ساحة المدينة تحتاج تبليطاً. يجب حساب مساحة الأقسام على شكل متوازي أضلاع لطلب الكمية الصحيحة من المواد.',
    ),
    discovery: BilingualText(
      en: 'Drag the parallelogram to transform it into a rectangle. Observe how the area stays the same.',
      ar: 'اسحب متوازي الأضلاع لتحويله إلى مستطيل. لاحظ كيف تبقى المساحة كما هي.',
    ),
    explanation: BilingualText(
      en: 'Area of a parallelogram = base × height. A parallelogram has the same area as a rectangle with the same base and height.',
      ar: 'مساحة متوازي الأضلاع = القاعدة × الارتفاع. متوازي الأضلاع له نفس مساحة المستطيل بنفس القاعدة والارتفاع.',
    ),
    skills: [
      // ── Depth 0 ──
      CitySkill(
        skillId: 'para_area_intro',
        depth: 0,
        title: 'Parallelogram Area: Base × Height',
        titleAr: 'مساحة متوازي الأضلاع: القاعدة × الارتفاع',
        topic: 'Identifying base and height, applying the area formula',
        trainingActivities: [
          CityActivity(
            id: 'm5d0_t1',
            activityType: 'choice',
            prompt: 'A parallelogram has the same area as a rectangle when they share:',
            promptAr: 'متوازي أضلاع له نفس مساحة المستطيل عندما يشتركان في:',
            options: ['Same perimeter', 'Same base and height', 'Same side lengths', 'Same angles'],
            correctAnswer: 1,
            dataJson: {'options': ['Same perimeter', 'Same base and height', 'Same side lengths', 'Same angles']},
            hints: [
              BilingualText(en: 'The area formula for both is base × height.', ar: 'قانون المساحة لكليهما: القاعدة × الارتفاع.'),
            ],
            xpReward: 10,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d0_t2',
            activityType: 'drag_drop',
            prompt: 'Label the base and height on the parallelogram.',
            promptAr: 'علّم القاعدة والارتفاع على متوازي الأضلاع.',
            correctAnswer: {'placements': [{'slotId': 's1', 'itemId': 'a'}, {'slotId': 's2', 'itemId': 'b'}]},
            dataJson: {
              'items': [
                {'id': 'a', 'label': 'Base (القاعدة)'},
                {'id': 'b', 'label': 'Height (الارتفاع)'},
              ],
              'slots': [
                {'id': 's1', 'label': 'Bottom side', 'correctItemId': 'a'},
                {'id': 's2', 'label': 'Perpendicular distance', 'correctItemId': 'b'},
              ],
            },
            hints: [
              BilingualText(en: 'Base is the bottom side. Height is the perpendicular distance from base to opposite side.', ar: 'القاعدة هي الضلع السفلي. الارتفاع هو المسافة العمودية من القاعدة للضلع المقابل.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d0_t3',
            activityType: 'numeric_input',
            prompt: 'Parallelogram: base = 15 cm, height = 8 cm. Area = ?',
            promptAr: 'متوازي أضلاع: قاعدة = 15 سم، ارتفاع = 8 سم. المساحة = ؟',
            correctAnswer: 120,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'double', 'label': 'added_instead_of_multiplied'}]},
            hints: [
              BilingualText(en: 'Area = base × height.', ar: 'المساحة = القاعدة × الارتفاع.'),
              BilingualText(en: '15 × 8 = ?', ar: '15 × 8 = ؟'),
            ],
            xpReward: 10,
            skillId: 'parallelogram_area',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm5d0_app',
          activityType: 'spin',
          prompt: 'Calculate the glass needed for the parallelogram-shaped window: base 15 cm, height 8 cm. Spin to the correct area.',
          promptAr: 'احسب الزجاج المطلوب لنافذة متوازي الأضلاع: قاعدة 15 سم، ارتفاع 8 سم. دوّر العجلة للمساحة الصحيحة.',
          correctAnswer: {'correctSegmentId': 'w2'},
          dataJson: {
            'wheelSegments': [
              {'id': 'w1', 'label': '23 cm²'},
              {'id': 'w2', 'label': '120 cm²'},
              {'id': 'w3', 'label': '60 cm²'},
              {'id': 'w4', 'label': '150 cm²'},
            ],
            'correctSegmentId': 'w2',
          },
          hints: [
            BilingualText(en: 'Area = base × height = 15 × 8.', ar: 'المساحة = القاعدة × الارتفاع = 15 × 8.'),
            BilingualText(en: '15 × 8 = 120 cm².', ar: '15 × 8 = 120 سم².'),
          ],
          xpReward: 20,
          skillId: 'parallelogram_area',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm5d0_q1', type: 'choice', prompt: 'Area of parallelogram = rectangle with same:', promptAr: 'مساحة متوازي الأضلاع = مستطيل بنفس:', correctAnswer: 'base and height', options: ['Perimeter', 'Base and height', 'Side lengths', 'Diagonals']),
          CheckpointQuestion(id: 'm5d0_q2', type: 'numeric_input', prompt: 'Area = 200 m², base = 40 m. Height = ?', promptAr: 'مساحة 200 م²، قاعدة 40 م. الارتفاع = ؟', correctAnswer: 5),
          CheckpointQuestion(id: 'm5d0_q3', type: 'tap_image', prompt: 'Which formulas can correctly calculate parallelogram area? Tap all correct ones.', promptAr: 'أي القوانين يمكنها حساب مساحة متوازي الأضلاع بشكل صحيح؟ انقر على جميع الصحيحة.', correctAnswer: [0, 1], options: ['base × height', 'length × width', 'side × side', '(d1 × d2) ÷ 2']),
        ],
      ),
      // ── Depth 1 ──
      CitySkill(
        skillId: 'para_area_deep',
        depth: 1,
        title: 'Parallelogram Area: Complex Problems',
        titleAr: 'مساحة متوازي الأضلاع: مسائل مركبة',
        topic: 'Finding missing dimensions and real-world applications',
        trainingActivities: [
          CityActivity(
            id: 'm5d1_t1',
            activityType: 'numeric_input',
            prompt: 'Parking lot area = 200 m², base = 40 m. Find the height.',
            promptAr: 'مساحة موقف سيارات = 200 م²، القاعدة = 40 م. أوجد الارتفاع.',
            correctAnswer: 5,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'half', 'label': 'divided_wrong'}]},
            hints: [
              BilingualText(en: 'Height = Area ÷ Base.', ar: 'الارتفاع = المساحة ÷ القاعدة.'),
              BilingualText(en: '200 ÷ 40 = ?', ar: '200 ÷ 40 = ؟'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d1_t2',
            activityType: 'connect',
            prompt: 'Match each shape to its area formula.',
            promptAr: 'طابق كل شكل بقانون مساحته.',
            correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r3'}]},
            dataJson: {
              'leftItems': [
                {'id': 'l1', 'label': 'Parallelogram'},
                {'id': 'l2', 'label': 'Rhombus'},
                {'id': 'l3', 'label': 'Rectangle'},
              ],
              'rightItems': [
                {'id': 'r1', 'label': 'base × height'},
                {'id': 'r2', 'label': '(d1 × d2) ÷ 2'},
                {'id': 'r3', 'label': 'length × width'},
              ],
              'correctPairs': [
                {'leftId': 'l1', 'rightId': 'r1'},
                {'leftId': 'l2', 'rightId': 'r2'},
                {'leftId': 'l3', 'rightId': 'r3'},
              ],
            },
            hints: [
              BilingualText(en: 'Rhombus uses diagonals, not base and height.', ar: 'المعين يستخدم الأقطار، وليس القاعدة والارتفاع.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d1_t3',
            activityType: 'numeric_input',
            prompt: 'Rhombus diagonals: d1 = 10 cm, d2 = 6 cm. Area = ?',
            promptAr: 'أقطار معين: d1 = 10 سم، d2 = 6 سم. المساحة = ؟',
            correctAnswer: 30,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'double', 'label': 'used_wrong_formula'}]},
            hints: [
              BilingualText(en: 'Rhombus area = (d1 × d2) ÷ 2.', ar: 'مساحة المعين = (d1 × d2) ÷ 2.'),
              BilingualText(en: '(10 × 6) ÷ 2 = 30.', ar: '(10 × 6) ÷ 2 = 30.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm5d1_app',
          activityType: 'tap_image',
          prompt: 'The city ordered tiles for a parallelogram-shaped area. Which calculations are needed? Tap all correct steps.',
          promptAr: 'طلبت المدينة بلاطاً لمساحة متوازي أضلاع. أي الحسابات مطلوبة؟ انقر على جميع الخطوات الصحيحة.',
          correctAnswer: [0, 2],
          dataJson: {
            'regions': [
              {'id': 'r1', 'label': 'Multiply base × height to get area', 'isCorrect': true},
              {'id': 'r2', 'label': 'Add all four sides to get area', 'isCorrect': false},
              {'id': 'r3', 'label': 'Divide area by tile size for count', 'isCorrect': true},
              {'id': 'r4', 'label': 'Multiply area by tile size for count', 'isCorrect': false},
            ],
          },
          hints: [
            BilingualText(en: 'Area = base × height. Then tile count = area ÷ tile area.', ar: 'المساحة = القاعدة × الارتفاع. ثم عدد البلاط = المساحة ÷ مساحة البلاطة.'),
          ],
          xpReward: 25,
          skillId: 'parallelogram_area',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm5d1_q1', type: 'numeric_input', prompt: 'Area = 180 m², height = 12 m. Base = ?', promptAr: 'المساحة = 180 م²، الارتفاع = 12 م. القاعدة = ؟', correctAnswer: 15),
          CheckpointQuestion(id: 'm5d1_q2', type: 'numeric_input', prompt: 'Rhombus: d1=8, d2=5. Area = ?', promptAr: 'معين: d1=8, d2=5. المساحة = ؟', correctAnswer: 20),
          CheckpointQuestion(id: 'm5d1_q3', type: 'open_response', prompt: 'What is the common mistake students make when finding parallelogram area?', promptAr: 'ما الخطأ الشائع الذي يقع فيه الطلاب عند حساب مساحة متوازي الأضلاع؟', correctAnswer: ['الجانب', 'الضلع', 'side', 'بدل الارتفاع', 'بدلا من الارتفاع']),
        ],
      ),
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // MISSION 6: تحدي إنقاذ المدينة — combined_challenge
  // ═══════════════════════════════════════════════════════════════════════════
  CityMission(
    id: 6,
    conceptKey: 'combined_challenge',
    cityMission: 'city_rescue',
    titleAr: 'تحدي إنقاذ المدينة',
    titleEn: 'City Rescue Challenge',
    emoji: '🦸',
    colorHex: '#E91E63',
    scene: BilingualText(
      en: 'The city faces a major crisis! Multiple structures need fixing at once. Apply everything you have learned about lines, angles, parallelograms, and areas to save the city.',
      ar: 'المدينة تواجه أزمة كبرى! عدة هياكل تحتاج إصلاحاً في وقت واحد. طبّق كل ما تعلمته عن الخطوط والزوايا ومتوازي الأضلاع والمساحات لإنقاذ المدينة.',
    ),
    discovery: BilingualText(
      en: 'Explore the city crisis map. Each damaged structure requires knowledge from a different mission.',
      ar: 'استكشف خريطة أزمة المدينة. كل هيكل متضرر يحتاج معرفة من مهمة مختلفة.',
    ),
    explanation: BilingualText(
      en: 'Every engineering problem in the city can be solved using the properties of lines, angles, and quadrilaterals you have mastered.',
      ar: 'كل مشكلة هندسية في المدينة يمكن حلها باستخدام خصائص الخطوط والزوايا والأشكال الرباعية التي أتقنتها.',
    ),
    skills: [
      CitySkill(
        skillId: 'city_rescue',
        depth: 0,
        title: 'City Rescue: Combined Challenge',
        titleAr: 'تحدي إنقاذ المدينة: تطبيق شامل',
        topic: 'Applying all learned skills: parallel lines, angles, parallelograms, area',
        trainingActivities: [
          CityActivity(
            id: 'm6d0_t1',
            activityType: 'choice',
            prompt: 'A bridge support is a parallelogram. One angle is 75°. Its opposite angle is:',
            promptAr: 'دعامة جسر على شكل متوازي أضلاع. إحدى زواياه 75°. الزاوية المقابلة:',
            options: ['75°', '105°', '90°', '180°'],
            correctAnswer: 0,
            dataJson: {'options': ['75°', '105°', '90°', '180°']},
            hints: [
              BilingualText(en: 'Opposite angles in a parallelogram are equal.', ar: 'الزوايا المتقابلة في متوازي الأضلاع متساوية.'),
            ],
            xpReward: 10,
            skillId: 'combined',
          ),
          CityActivity(
            id: 'm6d0_t2',
            activityType: 'spin',
            prompt: 'Road marking: two parallel roads cut by a transversal at 55°. Spin to find the corresponding angle on the other road.',
            promptAr: 'رسم طريق: طريقان متوازيان يقطعهما قاطع بزاوية 55°. دوّر العجلة لإيجاد الزاوية المناظرة.',
            correctAnswer: {'correctSegmentId': 'w2'},
            dataJson: {
              'wheelSegments': [
                {'id': 'w1', 'label': '35°'},
                {'id': 'w2', 'label': '55°'},
                {'id': 'w3', 'label': '125°'},
                {'id': 'w4', 'label': '90°'},
              ],
              'correctSegmentId': 'w2',
            },
            hints: [
              BilingualText(en: 'Corresponding angles are equal.', ar: 'الزوايا المناظرة متساوية.'),
            ],
            xpReward: 10,
            skillId: 'combined',
          ),
          CityActivity(
            id: 'm6d0_t3',
            activityType: 'numeric_input',
            prompt: 'City square tile order: parallelogram base 18 m, height 11 m. Total tiles needed (each 1 m²):',
            promptAr: 'طلب بلاط ساحة المدينة: متوازي أضلاع قاعدته 18 م وارتفاعه 11 م. عدد البلاط المطلوب (كل منها 1 م²):',
            correctAnswer: 198,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'Area = base × height = 18 × 11.', ar: 'المساحة = القاعدة × الارتفاع = 18 × 11.'),
              BilingualText(en: '18 × 11 = 198 m² = 198 tiles.', ar: '18 × 11 = 198 م² = 198 بلاطة.'),
            ],
            xpReward: 15,
            skillId: 'combined',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm6d0_app',
          activityType: 'connect',
          prompt: 'Final challenge: match each structure to the correct mathematical concept needed to fix it.',
          promptAr: 'التحدي النهائي: طابق كل هيكل بالمفهوم الرياضي الصحيح لإصلاحه.',
          correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r3'}, {'leftId': 'l4', 'rightId': 'r4'}]},
          dataJson: {
            'leftItems': [
              {'id': 'l1', 'label': 'Parallel road signs'},
              {'id': 'l2', 'label': 'Bridge support shape'},
              {'id': 'l3', 'label': 'City square tiles'},
              {'id': 'l4', 'label': 'Intersection sensors'},
            ],
            'rightItems': [
              {'id': 'r1', 'label': 'Parallel lines & transversals'},
              {'id': 'r2', 'label': 'Parallelogram properties'},
              {'id': 'r3', 'label': 'Area (base × height)'},
              {'id': 'r4', 'label': 'Angle relationships'},
            ],
            'correctPairs': [
              {'leftId': 'l1', 'rightId': 'r1'},
              {'leftId': 'l2', 'rightId': 'r2'},
              {'leftId': 'l3', 'rightId': 'r3'},
              {'leftId': 'l4', 'rightId': 'r4'},
            ],
          },
          correctionRulesJson: {'partialCredit': true},
          hints: [
            BilingualText(en: 'Road signs need parallel line rules. Bridge supports use parallelogram properties.', ar: 'لافتات الطريق تحتاج قواعد التوازي. دعامات الجسر تستخدم خصائص متوازي الأضلاع.'),
          ],
          xpReward: 30,
          skillId: 'combined',
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm6d0_q1',
            type: 'choice',
            prompt: 'A building wall is a rectangle 8m × 5m. Its area is:',
            promptAr: 'جدار مبنى مستطيل 8م × 5م. مساحته:',
            correctAnswer: '40 m²',
            options: ['40 m²', '26 m²', '13 m²', '80 m²'],
          ),
          CheckpointQuestion(
            id: 'm6d0_q2',
            type: 'tap_image',
            prompt: 'Which of these statements are ALWAYS true? Tap all correct ones.',
            promptAr: 'أي من هذه العبارات صحيحة دائماً؟ انقر على جميع الصحيحة.',
            correctAnswer: [0, 2, 3],
            options: ['Vertical angles are equal', 'All parallelograms are rectangles', 'Square diagonals are equal', 'Parallel lines never meet'],
          ),
          CheckpointQuestion(
            id: 'm6d0_q3',
            type: 'open_response',
            prompt: 'Name one property that a square and a rhombus share.',
            promptAr: 'اذكر خاصية واحدة يشترك فيها المربع والمعين.',
            correctAnswer: ['متساوية', 'أضلاع', 'equal', 'sides', 'متوازية', 'parallel', 'متعامدة', 'perpendicular'],
          ),
        ],
      ),
    ],
  ),
];