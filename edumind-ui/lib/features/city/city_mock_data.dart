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
    titleEn: 'شوارع لا تتصادم',
    emoji: '🛣️',
    colorHex: '#2196F3',
    scene: BilingualText(
      en: 'شارع جديد يعبر طريقين متوازيين، ويجب ضبط التقاطعات لوضع الإشارات بطريقة صحيحة.',
      ar: 'شارع جديد يعبر طريقين متوازيين، ويجب ضبط التقاطعات لوضع الإشارات بطريقة صحيحة.',
    ),
    discovery: BilingualText(
      en: 'اسحب القاطع وغير ميله، ثم اضغط على الزوايا وراقب ما يبقى متساوياً.',
      ar: 'اسحب القاطع وغير ميله، ثم اضغط على الزوايا وراقب ما يبقى متساوياً.',
    ),
    explanation: BilingualText(
      en: 'عندما يقطع مستقيم قاطع مستقيمين متوازيين، فإن الزوايا المتناظرة تكون متساوية دائماً.',
      ar: 'عندما يقطع مستقيم قاطع مستقيمين متوازيين، فإن الزوايا المتناظرة تكون متساوية دائماً.',
    ),
    skills: [
      // ── Depth 0: Introduction ──
      CitySkill(
        skillId: 'parallel_lines_intro',
        depth: 0,
        title: 'Parallel & Perpendicular Lines: Introduction',
        titleAr: 'المستقيم المتوازي والقاطع: مقدمة',
        topic: 'التعرف على المستقيمات المتوازية والمتعامدة والمتقاطعة',
        trainingActivities: [
          CityActivity(
            id: 'm1d0_t1',
            activityType: 'choice',
            prompt: 'مستقيمان لا يلتقيان في أي نقطة يُسميان:',
            promptAr: 'مستقيمان لا يلتقيان في أي نقطة يُسميان:',
            options: ['مستقيمان متوازيان', 'مستقيمان متعامدان', 'مستقيمان متقاطعان', 'خطوط منحنية'],
            correctAnswer: 0,
            dataJson: {'options': ['مستقيمان متوازيان', 'مستقيمان متعامدان', 'مستقيمان متقاطعان', 'خطوط منحنية']},
            correctionRulesJson: {'errorPatterns': [{'condition': 'chose_perpendicular', 'label': 'confused_parallel_perpendicular'}]},
            hints: [
              BilingualText(en: 'فكّر في قضبان القطار — هل تلتقي يوماً؟', ar: 'فكّر في قضبان القطار — هل تلتقي يوماً؟'),
              BilingualText(en: 'المستقيمات المتوازية تحافظ على نفس المسافة بينها.', ar: 'المستقيمات المتوازية تحافظ على نفس المسافة بينها.'),
              BilingualText(en: 'الإجابة تبدأ بكلمة "متوازية".', ar: 'الإجابة تبدأ بكلمة "متوازية".'),
            ],
            xpReward: 10,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d0_t2',
            activityType: 'drag_drop',
            prompt: 'صنّف كل زوج من المستقيمات في الفئة الصحيحة.',
            promptAr: 'اسحب كل زوج من المستقيمات وضعه في التصنيف الصحيح.',
            correctAnswer: {'placements': [{'slotId': 's1', 'itemId': 'a'}, {'slotId': 's2', 'itemId': 'b'}, {'slotId': 's3', 'itemId': 'c'}]},
            dataJson: {
              'items': [
                {'id': 'a', 'label': '↔ ↔ (مسافة متساوية)'},
                {'id': 'b', 'label': '↔ ⊥ ↔ (زاوية قائمة)'},
                {'id': 'c', 'label': '↔ ╳ ↔ (متقاطعان)'},
              ],
              'slots': [
                {'id': 's1', 'label': 'متوازيان', 'correctItemId': 'a'},
                {'id': 's2', 'label': 'متعامدان', 'correctItemId': 'b'},
                {'id': 's3', 'label': 'متقاطعان', 'correctItemId': 'c'},
              ],
            },
            hints: [
              BilingualText(en: 'متوازي = نفس الاتجاه، عمودي = زاوية قائمة، متقاطع = يتقاطعان.', ar: 'متوازي = نفس الاتجاه، عمودي = زاوية قائمة، متقاطع = يتقاطعان.'),
              BilingualText(en: 'الرمز ⊥ يعني العمودي (90°).', ar: 'الرمز ⊥ يعني العمودي (90°).'),
              BilingualText(en: 'الزوج المتساوي المسافة → متوازي. الزاوية القائمة → عمودي.', ar: 'الزوج المتساوي المسافة → متوازي. الزاوية القائمة → عمودي.'),
            ],
            xpReward: 15,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d0_t3',
            activityType: 'connect',
            prompt: 'طابق كل علاقة بين المستقيمات مع الوصف الصحيح لها.',
            promptAr: 'طابق كل علاقة بين المستقيمات بالوصف الصحيح.',
            correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}]},
            dataJson: {
              'leftItems': [
                {'id': 'l1', 'label': 'مستقيمات متوازية'},
                {'id': 'l2', 'label': 'مستقيمات متعامدة'},
              ],
              'rightItems': [
                {'id': 'r1', 'label': 'لا تلتقي أبداً، والمسافة بينها متساوية'},
                {'id': 'r2', 'label': 'تلتقي بزاوية 90°'},
                {'id': 'r3', 'label': 'تلتقي بزوايا مختلفة'},
              ],
              'correctPairs': [
                {'leftId': 'l1', 'rightId': 'r1'},
                {'leftId': 'l2', 'rightId': 'r2'},
              ],
            },
            hints: [
              BilingualText(en: 'المستقيمات المتوازية لا تلتقي أبداً — مثل قضبان السكة الحديدية.', ar: 'المستقيمات المتوازية لا تلتقي أبداً — مثل قضبان السكة الحديدية.'),
              BilingualText(en: 'العمودي يعني يتقاطعان بزاوية قائمة (90°).', ar: 'العمودي يعني يتقاطعان بزاوية قائمة (90°).'),
            ],
            xpReward: 15,
            skillId: 'parallel_lines',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm1d0_app',
          activityType: 'tap_image',
          prompt: 'في تقاطع المدينة، حدّد جميع أزواج الزوايا المتساوية. انقر على جميع العبارات الصحيحة.',
          promptAr: 'في تقاطع المدينة، حدّد جميع أزواج الزوايا المتساوية. انقر على جميع العبارات الصحيحة.',
          correctAnswer: [0, 1, 3],
          dataJson: {
            'regions': [
              {'id': 'r1', 'label': 'الزوايا المتناظرة متساوية', 'isCorrect': true},
              {'id': 'r2', 'label': 'الزوايا المتبادلة داخلاً متساوية', 'isCorrect': true},
              {'id': 'r3', 'label': 'الزوايا الداخلية في نفس الجهة متساوية', 'isCorrect': false},
              {'id': 'r4', 'label': 'الزوايا المتقابلة بالرأس متساوية', 'isCorrect': true},
            ],
          },
          correctionRulesJson: {'partialCredit': true},
          hints: [
            BilingualText(en: 'الزوايا الداخلية في نفس الجانب متكاملة (مجموعها 180°) وليست متساوية.', ar: 'الزوايا الداخلية في نفس الجانب متكاملة (مجموعها 180°) وليست متساوية.'),
            BilingualText(en: 'المناظرة، المتبادلة داخلية، والمتقابلة بالرأس كلها متساوية.', ar: 'المناظرة، المتبادلة داخلية، والمتقابلة بالرأس كلها متساوية.'),
          ],
          xpReward: 20,
          skillId: 'parallel_lines',
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm1d0_q1',
            type: 'choice',
            prompt: 'مستقيمان متوازيان يقطعهما قاطع. إحدى الزوايا 110°. ما قياس الزاوية المقابلة لها بالرأس؟',
            promptAr: 'مستقيمان متوازيان يقطعهما قاطع. إحدى الزوايا 110°. ما الزاوية المقابلة لها بالرأس؟',
            correctAnswer: 1,
            options: ['70°', '110°', '90°', '180°'],
            errorPatterns: [{'condition': 'supplement_confusion', 'label': 'chose_supplement_instead_of_vertical'}],
          ),
          CheckpointQuestion(
            id: 'm1d0_q2',
            type: 'connect',
            prompt: 'طابق كل زوج من الزوايا مع خاصيته عند قطع مستقيمين متوازيين بقاطع.',
            promptAr: 'طابق كل زوج زوايا بخصائصه عند قطع مستقيمين متوازيين بقاطع.',
            correctAnswer: {'المتناظرة': 'متساوية', 'الداخلية في نفس الجهة': 'متكاملة'},
            options: ['متساوية', 'متكاملة', 'متتامتان'],
          ),
          CheckpointQuestion(
            id: 'm1d0_q3',
            type: 'numeric_input',
            prompt: 'مستقيمان متوازيان يقطعهما قاطع. الزاوية أ = 45°. ما قياس الزاوية المتناظرة ب؟',
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
        topic: 'الزوايا المتبادلة داخلاً، المتبادلة خارجاً، والمتناظرة',
        trainingActivities: [
          CityActivity(
            id: 'm1d1_t1',
            activityType: 'spin',
            prompt: 'دوّر العجلة لإيجاد قياس الزاوية المتبادلة داخلاً عندما يقطع قاطع مستقيمين متوازيين بزاوية 130°.',
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
              BilingualText(en: 'الزوايا المتبادلة داخلية متساوية عند توازي المستقيمات.', ar: 'الزوايا المتبادلة داخلية متساوية عند توازي المستقيمات.'),
              BilingualText(en: 'نفس قياس الزاوية المعطاة.', ar: 'نفس قياس الزاوية المعطاة.'),
            ],
            xpReward: 10,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d1_t2',
            activityType: 'numeric_input',
            prompt: 'مستقيمان متوازيان يقطعهما قاطع. زاوية خارجية قياسها 120°. ما قياس الزاوية المتبادلة خارجاً المقابلة لها؟',
            promptAr: 'قاطع يقطع مستقيمين متوازيين. زاوية خارجية 120°. ما الزاوية المتبادلة الخارجية لها؟',
            correctAnswer: 120,
            dataJson: {},
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'الزوايا المتبادلة خارجية تتبع نفس قاعدة المتبادلة داخلية.', ar: 'الزوايا المتبادلة خارجية تتبع نفس قاعدة المتبادلة داخلية.'),
              BilingualText(en: 'تساويان.', ar: 'تساويان.'),
            ],
            xpReward: 15,
            skillId: 'parallel_lines',
          ),
          CityActivity(
            id: 'm1d1_t3',
            activityType: 'choice',
            prompt: 'إذا قطع قاطع مستقيمين متوازيين، أي زوج من الزوايا ليس متساوياً دائماً؟',
            promptAr: 'إذا قطع قاطع مستقيمين متوازيين، أي زوج ليس متساوياً دائماً؟',
            options: ['الزوايا المتناظرة', 'الزوايا المتبادلة داخلاً', 'الزوايا المتبادلة خارجاً', 'الزوايا الداخلية في نفس الجهة'],
            correctAnswer: 3,
            dataJson: {'options': ['الزوايا المتناظرة', 'الزوايا المتبادلة داخلاً', 'الزوايا المتبادلة خارجاً', 'الزوايا الداخلية في نفس الجهة']},
            hints: [
              BilingualText(en: 'الزوايا الداخلية في نفس الجانب متكاملة وليست متساوية.', ar: 'الزوايا الداخلية في نفس الجانب متكاملة وليست متساوية.'),
            ],
            xpReward: 10,
            skillId: 'parallel_lines',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm1d1_app',
          activityType: 'connect',
          prompt: 'صمّم دعامات الجسر: طابق كل علاقة زوايا بقيمتها عندما تكون زاوية القاطع 75°.',
          promptAr: 'صمّم دعامات الجسر: طابق كل علاقة زوايا بقيمتها عندما زاوية القاطع 75°.',
          correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r1'}]},
          dataJson: {
            'leftItems': [
              {'id': 'l1', 'label': 'زاوية متناظرة'},
              {'id': 'l2', 'label': 'زاوية داخلية في نفس الجهة'},
              {'id': 'l3', 'label': 'زاوية متبادلة داخلاً'},
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
            BilingualText(en: 'المناظرة والمتبادلة داخلية تساوي زاوية القاطع.', ar: 'المناظرة والمتبادلة داخلية تساوي زاوية القاطع.'),
            BilingualText(en: 'الداخلية في نفس الجانب = 180° − زاوية القاطع.', ar: 'الداخلية في نفس الجانب = 180° − زاوية القاطع.'),
            BilingualText(en: 'إذا إحدى الزوايا 75°، الداخلية في نفس الجانب = 180° - 75° = 105°.', ar: 'إذا إحدى الزوايا 75°، الداخلية في نفس الجانب = 180° - 75° = 105°.'),
          ],
          xpReward: 25,
          skillId: 'parallel_lines',
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm1d1_q1',
            type: 'numeric_input',
            prompt: 'مستقيمان متوازيان يقطعهما قاطع. إحدى الزوايا المتبادلة داخلاً 85°. ما قياس الأخرى؟',
            promptAr: 'قاطع يقطع مستقيمين متوازيين. إحدى الزوايا المتبادلة داخلية 85°. ما الأخرى؟',
            correctAnswer: 85,
          ),
          CheckpointQuestion(
            id: 'm1d1_q2',
            type: 'spin',
            prompt: 'زاوية خارجية في أحد الجانبين 140°. دوّر العجلة لإيجاد الزاوية الداخلية في نفس الجانب.',
            promptAr: 'زاوية خارجية في أحد الجانبين 140°. دوّر العجلة لإيجاد الزاوية الداخلية في نفس الجانب.',
            correctAnswer: 1,
            options: ['40°', '140°', '90°', '50°'],
          ),
          CheckpointQuestion(
            id: 'm1d1_q3',
            type: 'tap_image',
            prompt: 'انقر على جميع أزواج الزوايا التي تكون متساوية دائماً عند قطع مستقيمين متوازيين بقاطع.',
            promptAr: 'انقر على جميع أزواج الزوايا التي تكون متساوية دائماً عند قطع متوازيين بقاطع.',
            correctAnswer: [0, 1, 3],
            options: ['الزوايا المتناظرة', 'الداخلية في نفس الجهة', 'المتبادلة داخلاً', 'المتبادلة خارجاً', 'المتجاورتان'],
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
    titleEn: 'تقاطع الطرق الذكي',
    emoji: '🚦',
    colorHex: '#FF9800',
    scene: BilingualText(
      en: 'تقاطع ذكي يستخدم حساسات زوايا. نحتاج إلى برمجتها من خلال فهم علاقات الزوايا.',
      ar: 'تقاطع ذكي يستخدم حساسات زوايا. نحتاج برمجتها بفهم علاقات الزوايا.',
    ),
    discovery: BilingualText(
      en: 'غيّر الزوايا في التقاطع ولاحظ أي الأزواج مجموعها دائماً 180° وأيها متساوية دائماً.',
      ar: 'غيّر الزوايا في التقاطع ولاحظ أي أزواج مجموعها دائماً 180° وأيها متساوية دائماً.',
    ),
    explanation: BilingualText(
      en: 'في التقاطع، الزوايا المتقابلة بالرأس متساوية، والزوايا المتجاورة متكاملة (مجموعها 180°).',
      ar: 'في التقاطع، الزوايا المتقابلة بالرأس متساوية، والمجاورة متكاملة (مجموعها 180°).',
    ),
    skills: [
      // ── Depth 0 ──
      CitySkill(
        skillId: 'angles_intro',
        depth: 0,
        title: 'Angle Types: Acute, Right, Obtuse',
        titleAr: 'أنواع الزوايا: حادة، قائمة، منفرجة',
        topic: 'تصنيف الزوايا حسب قياسها',
        trainingActivities: [
          CityActivity(
            id: 'm2d0_t1',
            activityType: 'choice',
            prompt: 'زاوية قياسها 120° تُسمى:',
            promptAr: 'زاوية قياسها 120° تُسمى:',
            options: ['حادة', 'قائمة', 'منفرجة', 'مستقيمة'],
            correctAnswer: 2,
            dataJson: {'options': ['حادة', 'قائمة', 'منفرجة', 'مستقيمة']},
            hints: [
              BilingualText(en: 'حادة < 90°، قائمة = 90°، منفرجة > 90° و < 180°.', ar: 'حادة < 90°، قائمة = 90°، منفرجة > 90° و < 180°.'),
              BilingualText(en: '120° أكبر من 90°.', ar: '120° أكبر من 90°.'),
              BilingualText(en: 'الإجابة هي "منفرجة".', ar: 'الإجابة "منفرجة".'),
            ],
            xpReward: 10,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d0_t2',
            activityType: 'tap_image',
            prompt: 'انقر على جميع الزوايا الحادة (أقل من 90°).',
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
              BilingualText(en: 'الزوايا الحادة أقل من 90°. القائمة = بالضبط 90°.', ar: 'الزوايا الحادة أقل من 90°. القائمة = بالضبط 90°.'),
            ],
            xpReward: 15,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d0_t3',
            activityType: 'numeric_input',
            prompt: 'زاويتان متجاورتان تشكلان مستقيماً. إحداهما 70°. ما قياس الأخرى؟',
            promptAr: 'زاويتان متجاورتان تشكلان مستقيماً. إحداهما 70°. ما الأخرى؟',
            correctAnswer: 110,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'supplement_confusion', 'label': 'supplement_miscalculation'}]},
            hints: [
              BilingualText(en: 'الزاويتان المتجاورتان على مستقيم مجموعهما 180°.', ar: 'الزاويتان المتجاورتان على مستقيم مجموعهما 180°.'),
              BilingualText(en: '180° - 70° = ؟', ar: '180° - 70° = ؟'),
            ],
            xpReward: 10,
            skillId: 'angles',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm2d0_app',
          activityType: 'spin',
          prompt: 'في التقاطع الذكي، مستقيمان متقاطعان يشكلان أربع زوايا. إحداهما 35°. دوّر العجلة لإيجاد الزاوية المقابلة لها بالرأس.',
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
            BilingualText(en: 'الزوايا المتقابلة بالرأس متساوية دائماً.', ar: 'الزوايا المتقابلة بالرأس متساوية دائماً.'),
            BilingualText(en: 'الزاوية المقابلة لها نفس القياس.', ar: 'الزاوية المقابلة لها نفس القياس.'),
          ],
          xpReward: 20,
          skillId: 'angles',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm2d0_q1', type: 'choice', prompt: 'زاوية قياسها 45° تُصنف على أنها:', promptAr: 'زاوية قياسها 45° تُصنف:', correctAnswer: 0, options: ['حادة', 'قائمة', 'منفرجة', 'مستقيمة']),
          CheckpointQuestion(id: 'm2d0_q2', type: 'numeric_input', prompt: 'زاويتان متجاورتان على مستقيم: إحداهما 130°. ما قياس الأخرى؟', promptAr: 'زاويتان متجاورتان على مستقيم: إحداهما 130°. ما الأخرى؟', correctAnswer: 50),
          CheckpointQuestion(id: 'm2d0_q3', type: 'open_response', prompt: 'في جملة واحدة، ما هي العلاقة بين الزوايا المتقابلة بالرأس؟', promptAr: 'في جملة واحدة، ما علاقة الزوايا المتقابلة بالرأس؟', correctAnswer: ['متساوية', 'متساويتان', 'تتساوى', 'equal']),
        ],
      ),
      // ── Depth 1 ──
      CitySkill(
        skillId: 'angles_deep',
        depth: 1,
        title: 'Angle Relationships: Supplementary & Complementary',
        titleAr: 'علاقات الزوايا: المتكاملة والمتتامة',
        topic: 'أزواج الزوايا المتكاملة (180°) والمتتامّة (90°)',
        trainingActivities: [
          CityActivity(
            id: 'm2d1_t1',
            activityType: 'numeric_input',
            prompt: 'زاويتان متتامّتان. إحداهما 37°. ما قياس الأخرى؟',
            promptAr: 'زاويتان متتامتان. إحداهما 37°. ما الأخرى؟',
            correctAnswer: 53,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'الزوايا المتتامّتان مجموعها 90°.', ar: 'الزوايا المتتامان مجموعها 90°.'),
              BilingualText(en: '90° - 37° = ؟', ar: '90° - 37° = ؟'),
            ],
            xpReward: 10,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d1_t2',
            activityType: 'connect',
            prompt: 'طابق كل زوج من الزوايا مع نوع العلاقة بينهما.',
            promptAr: 'طابق كل زوج زوايا بنوع العلاقة.',
            correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r2'}]},
            dataJson: {
              'leftItems': [
                {'id': 'l1', 'label': '60° + 30°'},
                {'id': 'l2', 'label': '110° + 70°'},
                {'id': 'l3', 'label': '45° + 135°'},
              ],
              'rightItems': [
                {'id': 'r1', 'label': 'متتامّتان (90°)'},
                {'id': 'r2', 'label': 'متكاملتان (180°)'},
              ],
              'correctPairs': [
                {'leftId': 'l1', 'rightId': 'r1'},
                {'leftId': 'l2', 'rightId': 'r2'},
                {'leftId': 'l3', 'rightId': 'r2'},
              ],
            },
            hints: [
              BilingualText(en: 'متتامّتان = مجموع 90°. متكاملتان = مجموع 180°.', ar: 'متتامان = مجموع 90°. متكاملان = مجموع 180°.'),
              BilingualText(en: '60+30=90، 110+70=180، 45+135=180.', ar: '60+30=90، 110+70=180، 45+135=180.'),
            ],
            xpReward: 15,
            skillId: 'angles',
          ),
          CityActivity(
            id: 'm2d1_t3',
            activityType: 'open_response',
            prompt: 'اشرح لماذا لا يمكن لزاوية قياسها 100° أن يكون لها زاوية متتامّة.',
            promptAr: 'اشرح لماذا زاوية 100° لا يمكن أن يكون لها زاوية متتامة.',
            correctAnswer: ['أكبر من 90', 'أكثر من 90', 'greater than 90', 'exceeds 90', 'تتامان مجموعها 90'],
            hints: [
              BilingualText(en: 'فكّر ما معنى متتامّتان — مجموعهما.', ar: 'فكّر ما معنى متتامان — مجموعهما.'),
              BilingualText(en: 'الزوايا المتتامّة مجموعها 90°. هل يمكن لزاوية موجبة أن تجمع مع 100° وتعطي 90°؟', ar: 'الزوايا المتتامان مجموعها 90°. هل يمكن لزاوية موجبة أن تجمع مع 100° وتعطي 90°؟'),
            ],
            xpReward: 15,
            skillId: 'angles',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm2d1_app',
          activityType: 'drag_drop',
          prompt: 'صنّف مجموع كل زوج من الزوايا في الفئة الصحيحة: متتامّتان، متكاملتان، أو لا شيء منهما.',
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
              {'id': 's1', 'label': 'متتامّتان (90°)', 'correctItemId': 'a'},
              {'id': 's2', 'label': 'لا شيء منهما', 'correctItemId': 'b'},
              {'id': 's3', 'label': 'متكاملتان (180°)', 'correctItemId': 'c'},
              {'id': 's4', 'label': 'متتامّتان (90°)', 'correctItemId': 'd'},
            ],
          },
          hints: [
            BilingualText(en: '95° + 95° = 190° ≠ 90° و ≠ 180°، فلا ينتمي لأي فئة.', ar: '95° + 95° = 190° ≠ 90° و ≠ 180°، فلا ينتمي لأي فئة.'),
          ],
          xpReward: 20,
          skillId: 'angles',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm2d1_q1', type: 'numeric_input', prompt: 'زاويتان متتامّتان: إحداهما 23°. ما قياس الأخرى؟', promptAr: 'زاويتان متتامتان: إحداهما 23°. ما الأخرى؟', correctAnswer: 67),
          CheckpointQuestion(id: 'm2d1_q2', type: 'spin', prompt: 'إذا الزاوية أ = 90°، دوّر العجلة لإيجاد زاويتها المتتامّة.', promptAr: 'إذا الزاوية A = 90°، دوّر العجلة لإيجاد مكملتها.', correctAnswer: 0, options: ['0°', '45°', '90°', '180°']),
          CheckpointQuestion(id: 'm2d1_q3', type: 'connect', prompt: 'طابق كل علاقة مع مجموع الزوايا الخاص بها.', promptAr: 'طابق كل علاقة بمجموع الزوايا الخاص بها.', correctAnswer: {'متتامّتان': '90°', 'متكاملتان': '180°', 'دورة كاملة': '360°'}, options: ['90°', '180°', '270°', '360°']),
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
    titleEn: 'جسر يبقى ثابتاً',
    emoji: '🌉',
    colorHex: '#4CAF50',
    scene: BilingualText(
      en: 'الجسر القديم غير مستقر. نحتاج إلى التحقق من أن دعاماته ذات الشكل متوازي الأضلاع تمتلك الخصائص الصحيحة لتحمل الوزن.',
      ar: 'الجسر القديم غير مستقر. نحتاج التحقق من أن دعاماته على شكل متوازي أضلاع تمتلك الخصائص الصحيحة.',
    ),
    discovery: BilingualText(
      en: 'قِس أضلاع وزوايا دعامة الجسر. اسحب الرؤوس ولاحظ كيف يبقى الضلعان المتقابلان متساويين ومتوازيين.',
      ar: 'قِس أضلاع وزوايا دعامة الجسر. اسحب الرؤوس ولاحظ كيف يبقى الضلعان المتقابلان متساويين ومتوازيين.',
    ),
    explanation: BilingualText(
      en: 'في متوازي الأضلاع: الأضلاع المتقابلة متساوية ومتوازية، والزوايا المتقابلة متساوية، والأقطار ينصف كل منهما الآخر.',
      ar: 'في متوازي الأضلاع: الأضلاع المتقابلة متساوية ومتوازية، والزوايا المتقابلة متساوية، والأقطار تنصف بعضها.',
    ),
    skills: [
      CitySkill(
        skillId: 'parallelogram_intro',
        depth: 0,
        title: 'Parallelogram: Basic Properties',
        titleAr: 'متوازي الأضلاع: الخصائص الأساسية',
        topic: 'الأضلاع المتقابلة متوازية ومتساوية، والزوايا المتقابلة متساوية',
        trainingActivities: [
          CityActivity(
            id: 'm3d0_t1',
            activityType: 'choice',
            prompt: 'في متوازي الأضلاع، الأضلاع المتقابلة تكون:',
            promptAr: 'في متوازي الأضلاع، الأضلاع المتقابلة تكون:',
            options: ['متساوية ومتوازية', 'متساوية فقط', 'متوازية فقط', 'متعامدة'],
            correctAnswer: 0,
            dataJson: {'options': ['متساوية ومتوازية', 'متساوية فقط', 'متوازية فقط', 'متعامدة']},
            hints: [
              BilingualText(en: 'اسم "متوازي الأضلاع" يحتوي على كلمة "متوازي".', ar: 'اسم "متوازي الأضلاع" يحتوي "متوازي".'),
              BilingualText(en: 'متساوية ومتوازية معاً.', ar: 'متساوية ومتوازية معاً.'),
            ],
            xpReward: 10,
            skillId: 'parallelogram',
          ),
          CityActivity(
            id: 'm3d0_t2',
            activityType: 'tap_image',
            prompt: 'انقر على جميع الأشكال التي تمثل متوازيات أضلاع (كلا الزوجين من الأضلاع المتقابلة متوازيان).',
            promptAr: 'انقر على جميع الأشكال التي هي متوازيات أضلاع (كلا الزوجين من الأضلاع المتقابلة متوازيان).',
            correctAnswer: [0, 2, 4],
            dataJson: {
              'regions': [
                {'id': 'r1', 'label': 'مستطيل (4 زوايا قائمة)', 'isCorrect': true},
                {'id': 'r2', 'label': 'شبه منحرف (زوج واحد متوازي)', 'isCorrect': false},
                {'id': 'r3', 'label': 'معين (جميع الأضلاع متساوية)', 'isCorrect': true},
                {'id': 'r4', 'label': 'طائرة ورقية (لا توجد أضلاع متوازية)', 'isCorrect': false},
                {'id': 'r5', 'label': 'مربع (جميع الأضلاع متساوية + زوايا قائمة)', 'isCorrect': true},
              ],
            },
            hints: [
              BilingualText(en: 'شبه المنحرف لديه زوج واحد فقط من الأضلاع المتوازية.', ar: 'شبه المنحرف لديه زوج واحد فقط من الأضلاع المتوازية.'),
              BilingualText(en: 'الطائرة الورقية لا تملك أضلاعاً متوازية إطلاقاً.', ar: 'الطائرة الورقية لا تملك أضلاعاً متوازية إطلاقاً.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram',
          ),
          CityActivity(
            id: 'm3d0_t3',
            activityType: 'numeric_input',
            prompt: 'في متوازي أضلاع، طول أحد أضلاعه 8 سم. ما طول الضلع المقابل؟',
            promptAr: 'في متوازي أضلاع، أحد أضلاعه 8 سم. ما الضلع المقابل؟',
            correctAnswer: 8,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'الأضلاع المتقابلة في متوازي الأضلاع متساوية.', ar: 'الأضلاع المتقابلة في متوازي الأضلاع متساوية.'),
            ],
            xpReward: 10,
            skillId: 'parallelogram',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm3d0_app',
          activityType: 'choice',
          prompt: 'دعامة الجسر: شكل متوازي أضلاع. الزاوية أ = 110°. أوجد قياس الزاوية ب (المجاورة).',
          promptAr: 'دعامة الجسر: شكل متوازي أضلاع. الزاوية A = 110°. أوجد الزاوية B (المجاورة).',
          options: ['70°', '80°', '110°', '140°'],
          correctAnswer: 0,
          dataJson: {'options': ['70°', '80°', '110°', '140°']},
          hints: [
            BilingualText(en: 'الزوايا المجاورة مكملتان: مجموعهما 180°.', ar: 'الزوايا المجاورة مكملتان: مجموعهما 180°.'),
            BilingualText(en: '180 - 110 = ؟', ar: '180 - 110 = ؟'),
            BilingualText(en: 'الإجابة هي 70°.', ar: 'الإجابة 70°.'),
          ],
          xpReward: 20,
          skillId: 'parallelogram',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm3d0_q1', type: 'choice', prompt: 'في متوازي الأضلاع، إحدى الزوايا 50°. الزاوية المجاورة:', promptAr: 'في متوازي الأضلاع، إحدى الزوايا 50°. الزاوية المجاورة:', correctAnswer: 2, options: ['50°', '90°', '130°', '150°']),
          CheckpointQuestion(id: 'm3d0_q2', type: 'numeric_input', prompt: 'متوازي أضلاع: الضلع AB = 12 سم. الضلع CD (المقابل) = ؟', promptAr: 'متوازي أضلاع: الضلع AB = 12 سم. الضلع CD (المقابل) = ؟', correctAnswer: 12),
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
    titleEn: 'مبانٍ بأشكال مختلفة',
    emoji: '🏢',
    colorHex: '#9C27B0',
    scene: BilingualText(
      en: 'تخطيط المدينة يحتاج إلى أشكال مباني مختلفة: مستطيلات، مربعات، ومعينات.',
      ar: 'تخطيط المباني يحتاج أشكالاً مختلفة: مستطيلات، مربعات، ومعينات.',
    ),
    discovery: BilingualText(
      en: 'قارن بين الأشكال: اسحب الرؤوس ولاحظ أي الخصائص تتغير وأيها تبقى ثابتة.',
      ar: 'قارن الأشكال: اسحب الرؤوس ولاحظ أي الخصائص تتغير وأيها تبقى ثابتة.',
    ),
    explanation: BilingualText(
      en: 'المستطيل = متوازي أضلاع بزوايا قائمة. المربع = مستطيل بأضلاع متساوية. المعين = متوازي أضلاع بأضلاع متساوية.',
      ar: 'المستطيل = متوازي أضلاع بزوايا قائمة. المربع = مستطيل بأضلاع متساوية. المعين = متوازي أضلاع بأضلاع متساوية.',
    ),
    skills: [
      // ── Depth 0 ──
      CitySkill(
        skillId: 'rect_sq_rhomb_intro',
        depth: 0,
        title: 'Rectangle, Square & Rhombus: Identification',
        titleAr: 'المستطيل والمربع والمعين: التعرف والتمييز',
        topic: 'التعرف على أنواع الرباعيات والتمييز بينها',
        trainingActivities: [
          CityActivity(
            id: 'm4d0_t1',
            activityType: 'choice',
            prompt: 'متوازي الأضلاع الذي يحتوي على أربع زوايا قائمة هو:',
            promptAr: 'متوازي أضلاع بزوايا قائمة هو:',
            options: ['معين', 'مستطيل', 'مربع', 'شبه منحرف'],
            correctAnswer: 1,
            dataJson: {'options': ['معين', 'مستطيل', 'مربع', 'شبه منحرف']},
            hints: [
              BilingualText(en: 'زوايا قائمة + متوازي أضلاع = أي شكل؟', ar: 'زوايا قائمة + متوازي أضلاع = أي شكل؟'),
              BilingualText(en: 'فكّر في باب أو إطار نافذة.', ar: 'فكّر في باب أو إطار نافذة.'),
              BilingualText(en: 'الإجابة هي: مستطيل.', ar: 'الإجابة: مستطيل.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d0_t2',
            activityType: 'choice',
            prompt: 'المربع هو حالة خاصة من:',
            promptAr: 'المربع هو حالة خاصة من:',
            options: ['المعين فقط', 'المستطيل فقط', 'كل من المعين والمستطيل', 'لا شيء منهما'],
            correctAnswer: 2,
            dataJson: {'options': ['المعين فقط', 'المستطيل فقط', 'كل من المعين والمستطيل', 'لا شيء منهما']},
            hints: [
              BilingualText(en: 'المربع أضلاعه متساوية (معين) وزواياه قائمة (مستطيل).', ar: 'المربع أضلاعه متساوية (معين) وزواياه قائمة (مستطيل).'),
              BilingualText(en: 'يحقق كلا التعريفين.', ar: 'يحقق كلا التعريفين.'),
              BilingualText(en: 'الإجابة هي: المعين والمستطيل معاً.', ar: 'الإجابة: المعين والمستطيل معاً.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d0_t3',
            activityType: 'tap_image',
            prompt: 'افحص مواد البناء: انقر على جميع الأوصاف التي تنطبق على المستطيل.',
            promptAr: 'افحص مواد البناء: انقر على جميع الأوصاف التي تنطبق على المستطيل.',
            correctAnswer: [0, 2, 3],
            dataJson: {
              'regions': [
                {'id': 'r1', 'label': 'جميع الزوايا 90°', 'isCorrect': true},
                {'id': 'r2', 'label': 'جميع الأضلاع متساوية', 'isCorrect': false},
                {'id': 'r3', 'label': 'الأضلاع المتقابلة متساوية ومتوازية', 'isCorrect': true},
                {'id': 'r4', 'label': 'الأقطار متساوية', 'isCorrect': true},
                {'id': 'r5', 'label': 'الأقطار متعامدة', 'isCorrect': false},
              ],
            },
            correctionRulesJson: {'partialCredit': true},
            hints: [
              BilingualText(en: 'المستطيل ليس لديه أضلاع متساوية أو أقطار متعامدة.', ar: 'المستطيل ليس لديه أضلاع متساوية أو أقطار متعامدة.'),
            ],
            xpReward: 20,
            skillId: 'rectangle',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm4d0_app',
          activityType: 'choice',
          prompt: 'خطة المبنى: أي شكل يحتوي على 4 زوايا قائمة وجميع أضلاعه متساوية؟',
          promptAr: 'خطة مبنى: أي شكل له 4 زوايا قائمة وجميع أضلاعه متساوية؟',
          options: ['مستطيل', 'مربع', 'معين', 'متوازي أضلاع'],
          correctAnswer: 1,
          dataJson: {'options': ['مستطيل', 'مربع', 'معين', 'متوازي أضلاع']},
          hints: [
            BilingualText(en: 'زوايا قائمة ← مستطيل. أضلاع متساوية ← معين. شكل واحد فقط يمتلك كليهما.', ar: 'زوايا قائمة ← مستطيل. أضلاع متساوية ← معين. شكل واحد فقط يمتلك كليهما.'),
          ],
          xpReward: 20,
          skillId: 'rectangle',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm4d0_q1', type: 'choice', prompt: 'شكل جميع أضلاعه متساوية وجميع زواياه 90° هو:', promptAr: 'شكل جميع أضلاعه متساوية وجميع زواياه 90° هو:', correctAnswer: 1, options: ['مستطيل', 'مربع', 'معين', 'متوازي أضلاع']),
          CheckpointQuestion(id: 'm4d0_q2', type: 'numeric_input', prompt: 'أقطار مستطيل: أحدهما 13 م. الآخر:', promptAr: 'أقطار مستطيل: أحدهما 13 م. الآخر:', correctAnswer: 13),
          CheckpointQuestion(id: 'm4d0_q3', type: 'connect', prompt: 'طابق كل شكل مع الخاصية التي تميزه.', promptAr: 'طابق كل شكل بخاصية تميزه.', correctAnswer: {'مستطيل': '4 زوايا قائمة', 'معين': 'جميع الأضلاع متساوية', 'مربع': 'جميع الأضلاع متساوية + 4 زوايا قائمة'}, options: ['4 زوايا قائمة', 'جميع الأضلاع متساوية', 'جميع الأضلاع متساوية + 4 زوايا قائمة', 'زوج واحد متوازي']),
        ],
      ),
      // ── Depth 1 ──
      CitySkill(
        skillId: 'rect_sq_rhomb_deep',
        depth: 1,
        title: 'Comparing Quadrilaterals: Area & Perimeter',
        titleAr: 'مقارنة الرباعيات: المساحة والمحيط',
        topic: 'حساب المساحة والمحيط للمستطيلات والمربعات والمعينات',
        trainingActivities: [
          CityActivity(
            id: 'm4d1_t1',
            activityType: 'numeric_input',
            prompt: 'مستطيل: طوله 10 م وعرضه 7 م. احسب المساحة.',
            promptAr: 'مستطيل: طوله 10 م وعرضه 7 م. احسب المساحة.',
            correctAnswer: 70,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'مساحة المستطيل = الطول × العرض.', ar: 'مساحة المستطيل = الطول × العرض.'),
              BilingualText(en: '10 × 7 = ؟', ar: '10 × 7 = ؟'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d1_t2',
            activityType: 'spin',
            prompt: 'معين: طول ضلعه 5 م. دوّر العجلة لإيجاد المحيط.',
            promptAr: 'معين: طول ضلعه 5 م. دوّر العجلة لإيجاد المحيط.',
            correctAnswer: {'correctSegmentId': 'w3'},
            dataJson: {
              'wheelSegments': [
                {'id': 'w1', 'label': '10 م'},
                {'id': 'w2', 'label': '15 م'},
                {'id': 'w3', 'label': '20 م'},
                {'id': 'w4', 'label': '25 م'},
              ],
              'correctSegmentId': 'w3',
            },
            hints: [
              BilingualText(en: 'المحيط = 4 × الضلع (جميع الأضلاع متساوية).', ar: 'المحيط = 4 × الضلع (جميع الأضلاع متساوية).'),
              BilingualText(en: '4 × 5 = 20.', ar: '4 × 5 = 20.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
          CityActivity(
            id: 'm4d1_t3',
            activityType: 'open_response',
            prompt: 'ما هو قانون مساحة المستطيل؟',
            promptAr: 'ما قانون مساحة المستطيل؟',
            correctAnswer: ['الطول', 'العرض', 'length', 'width', 'ضرب', 'multiply', 'القاعدة', 'الارتفاع'],
            hints: [
              BilingualText(en: 'يتضمن ضرب قياسين من المستطيل.', ar: 'يتضمن ضرب قياسين من المستطيل.'),
            ],
            xpReward: 10,
            skillId: 'rectangle',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm4d1_app',
          activityType: 'connect',
          prompt: 'طابق كل شكل مع قانون مساحته الصحيح.',
          promptAr: 'طابق كل شكل بقانون مساحته الصحيح.',
          correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r3'}]},
          dataJson: {
            'leftItems': [
              {'id': 'l1', 'label': 'مستطيل'},
              {'id': 'l2', 'label': 'مربع'},
              {'id': 'l3', 'label': 'معين (باستخدام الأقطار)'},
            ],
            'rightItems': [
              {'id': 'r1', 'label': 'الطول × العرض'},
              {'id': 'r2', 'label': 'الضلع²'},
              {'id': 'r3', 'label': '(ق1 × ق2) ÷ 2'},
            ],
            'correctPairs': [
              {'leftId': 'l1', 'rightId': 'r1'},
              {'leftId': 'l2', 'rightId': 'r2'},
              {'leftId': 'l3', 'rightId': 'r3'},
            ],
          },
          hints: [
            BilingualText(en: 'المستطيل = الطول × العرض. المربع = الضلع × الضلع. المعين = (ق1 × ق2) / 2.', ar: 'المستطيل = الطول × العرض. المربع = الضلع × الضلع. المعين = (ق1 × ق2) / 2.'),
          ],
          xpReward: 20,
          skillId: 'rectangle',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm4d1_q1', type: 'numeric_input', prompt: 'مربع: ضلعه 9 م. المساحة = ؟', promptAr: 'مربع: ضلعه 9 م. المساحة = ؟', correctAnswer: 81),
          CheckpointQuestion(id: 'm4d1_q2', type: 'numeric_input', prompt: 'مستطيل: 15 م × 4 م. المحيط = ؟', promptAr: 'مستطيل: 15 م × 4 م. المحيط = ؟', correctAnswer: 38),
          CheckpointQuestion(id: 'm4d1_q3', type: 'choice', prompt: 'مساحة معين بالأقطار ق1=10, ق2=6:', promptAr: 'مساحة معين بالأقطار d1=10, d2=6:', correctAnswer: 0, options: ['30', '60', '16', '80']),
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
    titleEn: 'ساحة المدينة',
    emoji: '🏛️',
    colorHex: '#F44336',
    scene: BilingualText(
      en: 'ساحة المدينة تحتاج إلى تبليط. يجب علينا حساب مساحة الأقسام ذات الشكل متوازي الأضلاع لطلب الكمية الصحيحة من المواد.',
      ar: 'ساحة المدينة تحتاج تبليطاً. يجب حساب مساحة الأقسام على شكل متوازي أضلاع لطلب الكمية الصحيحة من المواد.',
    ),
    discovery: BilingualText(
      en: 'اسحب متوازي الأضلاع لتحويله إلى مستطيل. لاحظ كيف تبقى المساحة كما هي.',
      ar: 'اسحب متوازي الأضلاع لتحويله إلى مستطيل. لاحظ كيف تبقى المساحة كما هي.',
    ),
    explanation: BilingualText(
      en: 'مساحة متوازي الأضلاع = القاعدة × الارتفاع. متوازي الأضلاع له نفس مساحة المستطيل الذي له نفس القاعدة والارتفاع.',
      ar: 'مساحة متوازي الأضلاع = القاعدة × الارتفاع. متوازي الأضلاع له نفس مساحة المستطيل بنفس القاعدة والارتفاع.',
    ),
    skills: [
      // ── Depth 0 ──
      CitySkill(
        skillId: 'para_area_intro',
        depth: 0,
        title: 'Parallelogram Area: Base × Height',
        titleAr: 'مساحة متوازي الأضلاع: القاعدة × الارتفاع',
        topic: 'تحديد القاعدة والارتفاع، وتطبيق قانون المساحة',
        trainingActivities: [
          CityActivity(
            id: 'm5d0_t1',
            activityType: 'choice',
            prompt: 'متوازي الأضلاع له نفس مساحة المستطيل عندما يشتركان في:',
            promptAr: 'متوازي أضلاع له نفس مساحة المستطيل عندما يشتركان في:',
            options: ['نفس المحيط', 'نفس القاعدة والارتفاع', 'نفس أطوال الأضلاع', 'نفس الزوايا'],
            correctAnswer: 1,
            dataJson: {'options': ['نفس المحيط', 'نفس القاعدة والارتفاع', 'نفس أطوال الأضلاع', 'نفس الزوايا']},
            hints: [
              BilingualText(en: 'قانون المساحة لكليهما: القاعدة × الارتفاع.', ar: 'قانون المساحة لكليهما: القاعدة × الارتفاع.'),
            ],
            xpReward: 10,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d0_t2',
            activityType: 'drag_drop',
            prompt: 'ضع تسمية للقاعدة والارتفاع على متوازي الأضلاع.',
            promptAr: 'علّم القاعدة والارتفاع على متوازي الأضلاع.',
            correctAnswer: {'placements': [{'slotId': 's1', 'itemId': 'a'}, {'slotId': 's2', 'itemId': 'b'}]},
            dataJson: {
              'items': [
                {'id': 'a', 'label': 'القاعدة'},
                {'id': 'b', 'label': 'الارتفاع'},
              ],
              'slots': [
                {'id': 's1', 'label': 'الضلع السفلي', 'correctItemId': 'a'},
                {'id': 's2', 'label': 'المسافة العمودية', 'correctItemId': 'b'},
              ],
            },
            hints: [
              BilingualText(en: 'القاعدة هي الضلع السفلي. الارتفاع هو المسافة العمودية من القاعدة للضلع المقابل.', ar: 'القاعدة هي الضلع السفلي. الارتفاع هو المسافة العمودية من القاعدة للضلع المقابل.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d0_t3',
            activityType: 'numeric_input',
            prompt: 'متوازي أضلاع: القاعدة = 15 سم، الارتفاع = 8 سم. المساحة = ؟',
            promptAr: 'متوازي أضلاع: قاعدة = 15 سم، ارتفاع = 8 سم. المساحة = ؟',
            correctAnswer: 120,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'double', 'label': 'added_instead_of_multiplied'}]},
            hints: [
              BilingualText(en: 'المساحة = القاعدة × الارتفاع.', ar: 'المساحة = القاعدة × الارتفاع.'),
              BilingualText(en: '15 × 8 = ؟', ar: '15 × 8 = ؟'),
            ],
            xpReward: 10,
            skillId: 'parallelogram_area',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm5d0_app',
          activityType: 'spin',
          prompt: 'احسب كمية الزجاج المطلوبة للنافذة ذات الشكل متوازي الأضلاع: القاعدة 15 سم، الارتفاع 8 سم. دوّر العجلة للوصول إلى المساحة الصحيحة.',
          promptAr: 'احسب الزجاج المطلوب لنافذة متوازي الأضلاع: قاعدة 15 سم، ارتفاع 8 سم. دوّر العجلة للمساحة الصحيحة.',
          correctAnswer: {'correctSegmentId': 'w2'},
          dataJson: {
            'wheelSegments': [
              {'id': 'w1', 'label': '23 سم²'},
              {'id': 'w2', 'label': '120 سم²'},
              {'id': 'w3', 'label': '60 سم²'},
              {'id': 'w4', 'label': '150 سم²'},
            ],
            'correctSegmentId': 'w2',
          },
          hints: [
            BilingualText(en: 'المساحة = القاعدة × الارتفاع = 15 × 8.', ar: 'المساحة = القاعدة × الارتفاع = 15 × 8.'),
            BilingualText(en: '15 × 8 = 120 سم².', ar: '15 × 8 = 120 سم².'),
          ],
          xpReward: 20,
          skillId: 'parallelogram_area',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm5d0_q1', type: 'choice', prompt: 'مساحة متوازي الأضلاع = مستطيل بنفس:', promptAr: 'مساحة متوازي الأضلاع = مستطيل بنفس:', correctAnswer: 1, options: ['المحيط', 'القاعدة والارتفاع', 'أطوال الأضلاع', 'الأقطار']),
          CheckpointQuestion(id: 'm5d0_q2', type: 'numeric_input', prompt: 'مساحة 200 م²، قاعدة 40 م. الارتفاع = ؟', promptAr: 'مساحة 200 م²، قاعدة 40 م. الارتفاع = ؟', correctAnswer: 5),
          CheckpointQuestion(id: 'm5d0_q3', type: 'tap_image', prompt: 'أي القوانين يمكنها حساب مساحة متوازي الأضلاع بشكل صحيح؟ انقر على جميع الصحيحة.', promptAr: 'أي القوانين يمكنها حساب مساحة متوازي الأضلاع بشكل صحيح؟ انقر على جميع الصحيحة.', correctAnswer: [0, 1], options: ['القاعدة × الارتفاع', 'الطول × العرض', 'الضلع × الضلع', '(ق1 × ق2) ÷ 2']),
        ],
      ),
      // ── Depth 1 ──
      CitySkill(
        skillId: 'para_area_deep',
        depth: 1,
        title: 'Parallelogram Area: Complex Problems',
        titleAr: 'مساحة متوازي الأضلاع: مسائل مركبة',
        topic: 'إيجاد الأبعاد المفقودة والتطبيقات الواقعية',
        trainingActivities: [
          CityActivity(
            id: 'm5d1_t1',
            activityType: 'numeric_input',
            prompt: 'مساحة موقف سيارات = 200 م²، القاعدة = 40 م. أوجد الارتفاع.',
            promptAr: 'مساحة موقف سيارات = 200 م²، القاعدة = 40 م. أوجد الارتفاع.',
            correctAnswer: 5,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'half', 'label': 'divided_wrong'}]},
            hints: [
              BilingualText(en: 'الارتفاع = المساحة ÷ القاعدة.', ar: 'الارتفاع = المساحة ÷ القاعدة.'),
              BilingualText(en: '200 ÷ 40 = ؟', ar: '200 ÷ 40 = ؟'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d1_t2',
            activityType: 'connect',
            prompt: 'طابق كل شكل مع قانون مساحته.',
            promptAr: 'طابق كل شكل بقانون مساحته.',
            correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r3'}]},
            dataJson: {
              'leftItems': [
                {'id': 'l1', 'label': 'متوازي أضلاع'},
                {'id': 'l2', 'label': 'معين'},
                {'id': 'l3', 'label': 'مستطيل'},
              ],
              'rightItems': [
                {'id': 'r1', 'label': 'القاعدة × الارتفاع'},
                {'id': 'r2', 'label': '(ق1 × ق2) ÷ 2'},
                {'id': 'r3', 'label': 'الطول × العرض'},
              ],
              'correctPairs': [
                {'leftId': 'l1', 'rightId': 'r1'},
                {'leftId': 'l2', 'rightId': 'r2'},
                {'leftId': 'l3', 'rightId': 'r3'},
              ],
            },
            hints: [
              BilingualText(en: 'المعين يستخدم الأقطار، وليس القاعدة والارتفاع.', ar: 'المعين يستخدم الأقطار، وليس القاعدة والارتفاع.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
          CityActivity(
            id: 'm5d1_t3',
            activityType: 'numeric_input',
            prompt: 'أقطار معين: ق1 = 10 سم، ق2 = 6 سم. المساحة = ؟',
            promptAr: 'أقطار معين: d1 = 10 سم، d2 = 6 سم. المساحة = ؟',
            correctAnswer: 30,
            correctionRulesJson: {'tolerance': 0, 'errorPatterns': [{'condition': 'double', 'label': 'used_wrong_formula'}]},
            hints: [
              BilingualText(en: 'مساحة المعين = (ق1 × ق2) ÷ 2.', ar: 'مساحة المعين = (d1 × d2) ÷ 2.'),
              BilingualText(en: '(10 × 6) ÷ 2 = 30.', ar: '(10 × 6) ÷ 2 = 30.'),
            ],
            xpReward: 15,
            skillId: 'parallelogram_area',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm5d1_app',
          activityType: 'tap_image',
          prompt: 'طلبت المدينة بلاطاً لمساحة على شكل متوازي أضلاع. ما هي الحسابات المطلوبة؟ انقر على جميع الخطوات الصحيحة.',
          promptAr: 'طلبت المدينة بلاطاً لمساحة متوازي أضلاع. أي الحسابات مطلوبة؟ انقر على جميع الخطوات الصحيحة.',
          correctAnswer: [0, 2],
          dataJson: {
            'regions': [
              {'id': 'r1', 'label': 'ضرب القاعدة × الارتفاع للحصول على المساحة', 'isCorrect': true},
              {'id': 'r2', 'label': 'جمع الأضلاع الأربعة للحصول على المساحة', 'isCorrect': false},
              {'id': 'r3', 'label': 'قسمة المساحة على حجم البلاطة للحصول على العدد', 'isCorrect': true},
              {'id': 'r4', 'label': 'ضرب المساحة في حجم البلاطة للحصول على العدد', 'isCorrect': false},
            ],
          },
          hints: [
            BilingualText(en: 'المساحة = القاعدة × الارتفاع. ثم عدد البلاط = المساحة ÷ مساحة البلاطة.', ar: 'المساحة = القاعدة × الارتفاع. ثم عدد البلاط = المساحة ÷ مساحة البلاطة.'),
          ],
          xpReward: 25,
          skillId: 'parallelogram_area',
        ),
        checkpointQuestions: [
          CheckpointQuestion(id: 'm5d1_q1', type: 'numeric_input', prompt: 'المساحة = 180 م²، الارتفاع = 12 م. القاعدة = ؟', promptAr: 'المساحة = 180 م²، الارتفاع = 12 م. القاعدة = ؟', correctAnswer: 15),
          CheckpointQuestion(id: 'm5d1_q2', type: 'numeric_input', prompt: 'معين: ق1=8, ق2=5. المساحة = ؟', promptAr: 'معين: d1=8, d2=5. المساحة = ؟', correctAnswer: 20),
          CheckpointQuestion(id: 'm5d1_q3', type: 'open_response', prompt: 'ما الخطأ الشائع الذي يقع فيه الطلاب عند حساب مساحة متوازي الأضلاع؟', promptAr: 'ما الخطأ الشائع الذي يقع فيه الطلاب عند حساب مساحة متوازي الأضلاع؟', correctAnswer: ['الجانب', 'الضلع', 'side', 'بدل الارتفاع', 'بدلا من الارتفاع']),
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
    titleEn: 'تحدي إنقاذ المدينة',
    emoji: '🦸',
    colorHex: '#E91E63',
    scene: BilingualText(
      en: 'تواجه المدينة أزمة كبرى! هناك هياكل متعددة تحتاج إلى الإصلاح في وقت واحد. طبّق كل ما تعلمته عن المستقيمات والزوايا ومتوازيات الأضلاع والمساحات لإنقاذ المدينة.',
      ar: 'المدينة تواجه أزمة كبرى! عدة هياكل تحتاج إصلاحاً في وقت واحد. طبّق كل ما تعلمته عن الخطوط والزوايا ومتوازي الأضلاع والمساحات لإنقاذ المدينة.',
    ),
    discovery: BilingualText(
      en: 'استكشف خريطة أزمة المدينة. كل هيكل متضرر يتطلب معرفة من مهمة مختلفة.',
      ar: 'استكشف خريطة أزمة المدينة. كل هيكل متضرر يحتاج معرفة من مهمة مختلفة.',
    ),
    explanation: BilingualText(
      en: 'يمكن حل كل مشكلة هندسية في المدينة باستخدام خصائص المستقيمات والزوايا والأشكال الرباعية التي أتقنتها.',
      ar: 'كل مشكلة هندسية في المدينة يمكن حلها باستخدام خصائص الخطوط والزوايا والأشكال الرباعية التي أتقنتها.',
    ),
    skills: [
      CitySkill(
        skillId: 'city_rescue',
        depth: 0,
        title: 'City Rescue: Combined Challenge',
        titleAr: 'تحدي إنقاذ المدينة: تطبيق شامل',
        topic: 'تطبيق جميع المهارات المكتسبة: المستقيمات المتوازية، الزوايا، متوازيات الأضلاع، المساحة',
        trainingActivities: [
          CityActivity(
            id: 'm6d0_t1',
            activityType: 'choice',
            prompt: 'دعامة جسر على شكل متوازي أضلاع. إحدى زواياه 75°. الزاوية المقابلة لها:',
            promptAr: 'دعامة جسر على شكل متوازي أضلاع. إحدى زواياه 75°. الزاوية المقابلة:',
            options: ['75°', '105°', '90°', '180°'],
            correctAnswer: 0,
            dataJson: {'options': ['75°', '105°', '90°', '180°']},
            hints: [
              BilingualText(en: 'الزوايا المتقابلة في متوازي الأضلاع متساوية.', ar: 'الزوايا المتقابلة في متوازي الأضلاع متساوية.'),
            ],
            xpReward: 10,
            skillId: 'combined',
          ),
          CityActivity(
            id: 'm6d0_t2',
            activityType: 'spin',
            prompt: 'رسم طريق: طريقان متوازيان يقطعهما قاطع بزاوية 55°. دوّر العجلة لإيجاد الزاوية المتناظرة على الطريق الآخر.',
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
              BilingualText(en: 'الزوايا المتناظرة متساوية.', ar: 'الزوايا المناظرة متساوية.'),
            ],
            xpReward: 10,
            skillId: 'combined',
          ),
          CityActivity(
            id: 'm6d0_t3',
            activityType: 'numeric_input',
            prompt: 'طلب بلاط ساحة المدينة: متوازي أضلاع قاعدته 18 م وارتفاعه 11 م. إجمالي عدد البلاط المطلوب (كل بلاطة 1 م²):',
            promptAr: 'طلب بلاط ساحة المدينة: متوازي أضلاع قاعدته 18 م وارتفاعه 11 م. عدد البلاط المطلوب (كل منها 1 م²):',
            correctAnswer: 198,
            correctionRulesJson: {'tolerance': 0},
            hints: [
              BilingualText(en: 'المساحة = القاعدة × الارتفاع = 18 × 11.', ar: 'المساحة = القاعدة × الارتفاع = 18 × 11.'),
              BilingualText(en: '18 × 11 = 198 م² = 198 بلاطة.', ar: '18 × 11 = 198 م² = 198 بلاطة.'),
            ],
            xpReward: 15,
            skillId: 'combined',
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm6d0_app',
          activityType: 'connect',
          prompt: 'التحدي النهائي: طابق كل هيكل مع المفهوم الرياضي الصحيح اللازم لإصلاحه.',
          promptAr: 'التحدي النهائي: طابق كل هيكل بالمفهوم الرياضي الصحيح لإصلاحه.',
          correctAnswer: {'pairs': [{'leftId': 'l1', 'rightId': 'r1'}, {'leftId': 'l2', 'rightId': 'r2'}, {'leftId': 'l3', 'rightId': 'r3'}, {'leftId': 'l4', 'rightId': 'r4'}]},
          dataJson: {
            'leftItems': [
              {'id': 'l1', 'label': 'لافتات الطرق المتوازية'},
              {'id': 'l2', 'label': 'شكل دعامة الجسر'},
              {'id': 'l3', 'label': 'بلاط ساحة المدينة'},
              {'id': 'l4', 'label': 'حساسات التقاطع'},
            ],
            'rightItems': [
              {'id': 'r1', 'label': 'المستقيمات المتوازية والقاطعة'},
              {'id': 'r2', 'label': 'خصائص متوازي الأضلاع'},
              {'id': 'r3', 'label': 'المساحة (القاعدة × الارتفاع)'},
              {'id': 'r4', 'label': 'علاقات الزوايا'},
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
            BilingualText(en: 'لافتات الطريق تحتاج قواعد التوازي. دعامات الجسر تستخدم خصائص متوازي الأضلاع.', ar: 'لافتات الطريق تحتاج قواعد التوازي. دعامات الجسر تستخدم خصائص متوازي الأضلاع.'),
          ],
          xpReward: 30,
          skillId: 'combined',
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm6d0_q1',
            type: 'choice',
            prompt: 'جدار مبنى مستطيل 8م × 5م. مساحته:',
            promptAr: 'جدار مبنى مستطيل 8م × 5م. مساحته:',
            correctAnswer: 0,
            options: ['40 م²', '26 م²', '13 م²', '80 م²'],
          ),
          CheckpointQuestion(
            id: 'm6d0_q2',
            type: 'tap_image',
            prompt: 'أي من هذه العبارات صحيحة دائماً؟ انقر على جميع الصحيحة.',
            promptAr: 'أي من هذه العبارات صحيحة دائماً؟ انقر على جميع الصحيحة.',
            correctAnswer: [0, 2, 3],
            options: ['الزوايا المتقابلة بالرأس متساوية', 'جميع متوازيات الأضلاع هي مستطيلات', 'أقطار المربع متساوية', 'المستقيمات المتوازية لا تلتقي أبداً'],
          ),
          CheckpointQuestion(
            id: 'm6d0_q3',
            type: 'open_response',
            prompt: 'اذكر خاصية واحدة يشترك فيها المربع والمعين.',
            promptAr: 'اذكر خاصية واحدة يشترك فيها المربع والمعين.',
            correctAnswer: ['متساوية', 'أضلاع', 'equal', 'sides', 'متوازية', 'parallel', 'متعامدة', 'perpendicular'],
          ),
        ],
      ),
    ],
  ),
];