/// Complete mock data for مدينة لا تنهار — extracted from seed_city_content.ts.
///
/// This file contains ALL 6 missions with their scenes, activities, and checkpoints.
/// In production, this data comes from the backend API; the mock lets the UI work
/// standalone for development and testing.
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
      CitySkill(
        skillId: 'parallel_lines_intro',
        depth: 0,
        title: 'Parallel & Perpendicular Lines: Introduction',
        titleAr: 'المستقيم المتوازي والقاطع: مقدمة',
        topic: 'Identifying parallel, perpendicular, and intersecting lines',
        trainingActivities: [
          CityActivity(
            id: 'm1_t1',
            activityType: 'choice',
            prompt: 'Two lines that never meet are called:',
            promptAr: 'مستقيمان لا يلتقيان في أي نقطة يُسميان:',
            options: ['Parallel lines / خطوط متوازية', 'Perpendicular lines / خطوط متعامدة', 'Intersecting lines / خطوط متقاطعة', 'Curved lines / خطوط منحنية'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'Think about train tracks!', ar: 'فكّر في سكك القطار!'),
              BilingualText(en: 'They always stay the same distance apart.', ar: 'تبقى دائماً على نفس المسافة من بعضها.'),
              BilingualText(en: 'The answer starts with "Para".', ar: 'الإجابة تبدأ بـ "متواز".'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm1_t2',
            activityType: 'choice',
            prompt: 'If one angle is 110°, what is its supplementary angle on the same straight line?',
            promptAr: 'إذا كانت زاوية واحدة 110°، فما الزاوية المكملة لها على نفس المستقيم؟',
            options: ['70°', '90°', '110°', '180°'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'Supplementary angles add up to 180°.', ar: 'الزاويتان المكملتان مجموعهما 180°.'),
              BilingualText(en: '180 - 110 = ?', ar: '180 - 110 = ؟'),
              BilingualText(en: 'The answer is 70°.', ar: 'الإجابة 70°.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm1_t3',
            activityType: 'numeric_input',
            prompt: 'Find the value of x when the supplementary angle is 180° - x.',
            promptAr: 'أوجد قيمة x عندما الزاوية المكملة هي 180° - x.',
            options: [],
            correctAnswer: 45,
            hints: [
              BilingualText(en: 'The two angles are complementary: they add to 90°.', ar: 'الزاويتان متكاملتان: مجموعهما 90°.'),
              BilingualText(en: 'x + (180 - x - 90) = 90, so 2x = 90.', ar: 'x + (180 - x - 90) = 90، إذن 2x = 90.'),
              BilingualText(en: 'x = 45°.', ar: 'x = 45°.'),
            ],
            xpReward: 10,
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm1_app',
          activityType: 'numeric_input',
          prompt: 'A road intersection has parallel lanes and a crossing road. Angle α = 65°. Find angle β (alternate interior).',
          promptAr: 'تقاطع طريق به ممرات متوازية وطريق عابر. الزاوية α = 65°. أوجد الزاوية β (متبادلة داخلية).',
          options: [],
          correctAnswer: 65,
          hints: [
            BilingualText(en: 'Alternate interior angles are equal when lines are parallel.', ar: 'الزوايا المتبادلة داخلية متساوية عندما الخطوط متوازية.'),
            BilingualText(en: 'β = α because they are alternate interior.', ar: 'β = α لأنهما زاويتان متبادلتان داخليتان.'),
            BilingualText(en: 'β = 65°.', ar: 'β = 65°.'),
          ],
          xpReward: 20,
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm1_cp1',
            type: 'choice',
            prompt: 'Parallel lines are cut by a transversal. A pair of corresponding angles measure 75° and 105°. True or False?',
            promptAr: 'خطوط متوازية يقطعها قاطع. زاوية متقابلة بالوضع تقيس 75° والثانية 105°. صح أم خطأ؟',
            correctAnswer: 1,
            options: ['True / صح', 'False / خطأ'],
          ),
          CheckpointQuestion(
            id: 'm1_cp2',
            type: 'numeric_input',
            prompt: 'Corresponding angle = 55°. Find the alternate interior angle.',
            promptAr: 'الزاوية المتقابلة بالوضع = 55°. أوجد الزاوية المتبادلة داخلية.',
            correctAnswer: 55,
            options: [],
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
      en: 'The smart intersection needs precise angle calculations to operate the traffic signals correctly.',
      ar: 'التقاطع الذكي يحتاج حساب الزوايا بدقة لتشغيل الإشارات الضوئية.',
    ),
    discovery: BilingualText(
      en: 'Press on each angle and write its measure. Observe the relationships between them.',
      ar: 'اضغط على كل زاوية واكتب قياسها، ولاحظ العلاقات بينها.',
    ),
    explanation: BilingualText(
      en: 'At an intersection, vertical angles are equal, and adjacent angles are supplementary (add to 180°).',
      ar: 'في التقاطع، الزوايا المتقابلة بالرأس متساوية، والمجاورة متكاملة (مجموعها 180°).',
    ),
    skills: [
      CitySkill(
        skillId: 'angles_intro',
        depth: 0,
        title: 'Angle Types: Acute, Right, Obtuse, Straight',
        titleAr: 'أنواع الزوايا: حادة وقائمة ومنفرجة ومستقيمة',
        topic: 'Classifying and measuring angles at an intersection',
        trainingActivities: [
          CityActivity(
            id: 'm2_t1',
            activityType: 'choice',
            prompt: 'Two lines intersect. One angle is 40°. Its vertically opposite angle is:',
            promptAr: 'يقاطع مستقيمان. إحدى زواياهما 40°. الزاوية المقابلة لها بالرأس:',
            options: ['40°', '50°', '90°', '140°'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'Vertical angles are always equal.', ar: 'الزوايا المتقابلة بالرأس متساوية دائماً.'),
              BilingualText(en: 'They form an X shape.', ar: 'تشكّل شكل حرف X.'),
              BilingualText(en: 'The answer is 40°.', ar: 'الإجابة 40°.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm2_t2',
            activityType: 'choice',
            prompt: 'If angle A = 70°, what is its supplementary angle (adjacent)?',
            promptAr: 'إذا كانت الزاوية أ = 70°، فما الزاوية المكملة لها (المجاورة)؟',
            options: ['20°', '70°', '110°', '180°'],
            correctAnswer: 2,
            hints: [
              BilingualText(en: 'Adjacent angles on a straight line add to 180°.', ar: 'الزاويتان المجاورتان على مستقيم مجموعهما 180°.'),
              BilingualText(en: '180 - 70 = ?', ar: '180 - 70 = ؟'),
              BilingualText(en: 'The answer is 110°.', ar: 'الإجابة 110°.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm2_t3',
            activityType: 'numeric_input',
            prompt: 'At an intersection: angle α = 35°. Find the adjacent angle.',
            promptAr: 'في تقاطع: الزاوية α = 35°. أوجد الزاوية المجاورة.',
            options: [],
            correctAnswer: 145,
            hints: [
              BilingualText(en: 'Adjacent angles are supplementary.', ar: 'الزوايا المجاورتان مكملتان.'),
              BilingualText(en: '180 - 35 = ?', ar: '180 - 35 = ؟'),
              BilingualText(en: 'The answer is 145°.', ar: 'الإجابة 145°.'),
            ],
            xpReward: 10,
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm2_app',
          activityType: 'choice',
          prompt: 'Smart intersection: 4 roads cross at different angles. Angle A = 80°. Its vertically opposite angle is:',
          promptAr: 'تقاطع ذكي: 4 طرق تتقاطع بزوايا مختلفة. الزاوية أ = 80°. الزاوية المقابلة لها بالرأس:',
          options: ['80°', '100°', '90°', '180°'],
          correctAnswer: 0,
          hints: [
            BilingualText(en: 'Vertical angles are always equal.', ar: 'الزوايا المتقابلة بالرأس متساوية دائماً.'),
            BilingualText(en: 'The angle directly across is the same.', ar: 'الزاوية المقابلة مباشرة هي نفسها.'),
            BilingualText(en: 'The answer is 80°.', ar: 'الإجابة 80°.'),
          ],
          xpReward: 20,
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm2_cp1',
            type: 'choice',
            prompt: 'At an intersection, two angles are 60° and 120°. Are they adjacent angles?',
            promptAr: 'في التقاطع، زاويتان 60° و 120°. هل هما زاويتان مجاورتان؟',
            correctAnswer: 0,
            options: ['Yes / نعم', 'No / لا'],
          ),
          CheckpointQuestion(
            id: 'm2_cp2',
            type: 'numeric_input',
            prompt: 'Angle at intersection = 125°. Vertically opposite angle = ?',
            promptAr: 'زاوية في التقاطع = 125°. الزاوية المقابلة بالرأس = ؟',
            correctAnswer: 125,
            options: [],
          ),
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
      en: 'The old bridge is unstable. We need to verify that its supports are parallelograms with the correct properties.',
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
            id: 'm3_t1',
            activityType: 'choice',
            prompt: 'In a parallelogram, opposite sides are:',
            promptAr: 'في متوازي الأضلاع، الأضلاع المتقابلة:',
            options: ['Equal and parallel / متساوية ومتوازية', 'Equal and perpendicular / متساوية ومتعامدة', 'Unequal and parallel / غير متساوية ومتوازية', 'Equal only / متساوية فقط'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'Think about what "parallel" in the name means.', ar: 'فكّر ماذا يعني "متوازي" في الاسم.'),
              BilingualText(en: 'Both conditions: equal AND parallel.', ar: 'شرطان معاً: متساوية ومتوازية.'),
              BilingualText(en: 'The answer is "Equal and parallel".', ar: 'الإجابة: "متساوية ومتوازية".'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm3_t2',
            activityType: 'choice',
            prompt: 'One angle of a parallelogram is 70°. The opposite angle is:',
            promptAr: 'إحدى زوايا متوازي الأضلاع 70°. الزاوية المقابلة:',
            options: ['70°', '110°', '90°', '180°'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'Opposite angles in a parallelogram are always equal.', ar: 'الزوايا المتقابلة في متوازي الأضلاع متساوية دائماً.'),
              BilingualText(en: 'The opposite angle equals the given angle.', ar: 'الزاوية المقابلة تساوي الزاوية المعطاة.'),
              BilingualText(en: 'The answer is 70°.', ar: 'الإجابة 70°.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm3_t3',
            activityType: 'numeric_input',
            prompt: 'Parallelogram: angle A = 80°. Find angle D (adjacent).',
            promptAr: 'متوازي أضلاع: الزاوية A = 80°. أوجد الزاوية D (المجاورة).',
            options: [],
            correctAnswer: 100,
            hints: [
              BilingualText(en: 'Adjacent angles in a parallelogram are supplementary.', ar: 'الزوايا المجاورة في متوازي الأضلاع مكملتان.'),
              BilingualText(en: '180 - 80 = ?', ar: '180 - 80 = ؟'),
              BilingualText(en: 'The answer is 100°.', ar: 'الإجابة 100°.'),
            ],
            xpReward: 10,
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm3_app',
          activityType: 'choice',
          prompt: 'Bridge support: parallelogram shape. Angle A = 110°. Find angle B (adjacent).',
          promptAr: 'دعامة الجسر: شكل متوازي أضلاع. الزاوية A = 110°. أوجد الزاوية B (المجاورة).',
          options: ['70°', '80°', '110°', '140°'],
          correctAnswer: 0,
          hints: [
            BilingualText(en: 'Adjacent angles are supplementary: they add to 180°.', ar: 'الزوايا المجاورة مكملتان: مجموعهما 180°.'),
            BilingualText(en: '180 - 110 = ?', ar: '180 - 110 = ؟'),
            BilingualText(en: 'The answer is 70°.', ar: 'الإجابة 70°.'),
          ],
          xpReward: 20,
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm3_cp1',
            type: 'choice',
            prompt: 'In a parallelogram, one angle is 50°. An adjacent angle is:',
            promptAr: 'في متوازي الأضلاع، إحدى الزوايا 50°. الزاوية المجاورة:',
            correctAnswer: 2,
            options: ['50°', '90°', '130°', '150°'],
          ),
          CheckpointQuestion(
            id: 'm3_cp2',
            type: 'numeric_input',
            prompt: 'Parallelogram: side AB = 12 cm. Side CD (opposite) = ?',
            promptAr: 'متوازي أضلاع: الضلع AB = 12 سم. الضلع CD (المقابل) = ؟',
            correctAnswer: 12,
            options: [],
          ),
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
      CitySkill(
        skillId: 'rect_sq_rhomb_intro',
        depth: 0,
        title: 'Rectangle, Square & Rhombus: Identification',
        titleAr: 'المستطيل والمربع والمعين: التعرف والتمييز',
        topic: 'Identifying and distinguishing between quadrilateral types',
        trainingActivities: [
          CityActivity(
            id: 'm4_t1',
            activityType: 'choice',
            prompt: 'A parallelogram with four right angles is a:',
            promptAr: 'متوازي أضلاع بزوايا قائمة هو:',
            options: ['Rhombus / معين', 'Rectangle / مستطيل', 'Square / مربع', 'Trapezoid / شبه منحرف'],
            correctAnswer: 1,
            hints: [
              BilingualText(en: 'Right angles + parallelogram = which shape?', ar: 'زوايا قائمة + متوازي أضلاع = أي شكل؟'),
              BilingualText(en: 'Think about a door or a window frame.', ar: 'فكّر في باب أو إطار نافذة.'),
              BilingualText(en: 'The answer is Rectangle.', ar: 'الإجابة: مستطيل.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm4_t2',
            activityType: 'choice',
            prompt: 'A square is a special case of:',
            promptAr: 'المربع هو حالة خاصة من:',
            options: ['Rhombus only / المعين فقط', 'Rectangle only / المستطيل فقط', 'Both rhombus and rectangle / المعين والمستطيل معاً', 'Neither / لا هذا ولا ذاك'],
            correctAnswer: 2,
            hints: [
              BilingualText(en: 'A square has equal sides (rhombus) AND right angles (rectangle).', ar: 'المربع أضلاعه متساوية (معين) وزواياه قائمة (مستطيل).'),
              BilingualText(en: 'It satisfies both definitions.', ar: 'يحقق كلا التعريفين.'),
              BilingualText(en: 'The answer is: Both rhombus and rectangle.', ar: 'الإجابة: المعين والمستطيل معاً.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm4_t3',
            activityType: 'numeric_input',
            prompt: 'Rectangle length = 8 m, width = 5 m. Perimeter = ?',
            promptAr: 'مستطيل طوله 8 م وعرضه 5 م. المحيط = ؟',
            options: [],
            correctAnswer: 26,
            hints: [
              BilingualText(en: 'Perimeter = 2 × (length + width).', ar: 'المحيط = 2 × (الطول + العرض).'),
              BilingualText(en: '2 × (8 + 5) = ?', ar: '2 × (8 + 5) = ؟'),
              BilingualText(en: 'The answer is 26 m.', ar: 'الإجابة 26 م.'),
            ],
            xpReward: 10,
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm4_app',
          activityType: 'choice',
          prompt: 'Building plan: which shape has 4 right angles AND all sides equal?',
          promptAr: 'خطة مبنى: أي شكل له 4 زوايا قائمة وجميع أضلاعه متساوية؟',
          options: ['Rectangle / مستطيل', 'Square / مربع', 'Rhombus / معين', 'Parallelogram / متوازي أضلاع'],
          correctAnswer: 1,
          hints: [
            BilingualText(en: 'Right angles → it\'s a rectangle. Equal sides → it\'s also a rhombus.', ar: 'زوايا قائمة ← مستطيل. أضلاع متساوية ← معين أيضاً.'),
            BilingualText(en: 'Only one shape has BOTH properties.', ar: 'شكل واحد فقط يمتلك الخاصيتين معاً.'),
            BilingualText(en: 'The answer is: Square.', ar: 'الإجابة: مربع.'),
          ],
          xpReward: 20,
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm4_cp1',
            type: 'choice',
            prompt: 'All rectangles are parallelograms. All squares are rectangles. True or False?',
            promptAr: 'كل المستطيلات متوازيات أضلاع. كل المربعات مستطيلات. صح أم خطأ؟',
            correctAnswer: 0,
            options: ['True / صح', 'False / خطأ'],
          ),
          CheckpointQuestion(
            id: 'm4_cp2',
            type: 'numeric_input',
            prompt: 'Square: side = 9 cm. Perimeter = ?',
            promptAr: 'مربع: الضلع = 9 سم. المحيط = ؟',
            correctAnswer: 36,
            options: [],
          ),
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
      en: 'The city square needs tiling. We must calculate the area of the parallelogram-shaped square accurately.',
      ar: 'ساحة المدينة تحتاج تبليط. يجب حساب مساحة متوازي الأضلاع بدقة.',
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
      CitySkill(
        skillId: 'para_area_intro',
        depth: 0,
        title: 'Parallelogram Area: Base × Height',
        titleAr: 'مساحة متوازي الأضلاع: القاعدة × الارتفاع',
        topic: 'Identifying base and height, applying the area formula',
        trainingActivities: [
          CityActivity(
            id: 'm5_t1',
            activityType: 'choice',
            prompt: 'A parallelogram has the same area as a rectangle when they share:',
            promptAr: 'متوازي الأضلاع له نفس مساحة المستطيل إذا اشتركا في:',
            options: ['Same base / نفس القاعدة فقط', 'Same height / نفس الارتفاع فقط', 'Same base AND height / نفس القاعدة والارتفاع', 'Same perimeter / نفس المحيط'],
            correctAnswer: 2,
            hints: [
              BilingualText(en: 'Area = base × height. Both factors must match.', ar: 'المساحة = القاعدة × الارتفاع. كلا العاملين يجب أن يتطابقا.'),
              BilingualText(en: 'Think about what the formula needs.', ar: 'فكّر ماذا يحتاج القانون.'),
              BilingualText(en: 'The answer: Same base AND height.', ar: 'الإجابة: نفس القاعدة والارتفاع.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm5_t2',
            activityType: 'numeric_input',
            prompt: 'Parallelogram: base = 10 cm, height = 6 cm. Area = ?',
            promptAr: 'متوازي أضلاع: القاعدة = 10 سم، الارتفاع = 6 سم. المساحة = ؟',
            options: [],
            correctAnswer: 60,
            hints: [
              BilingualText(en: 'Area = base × height.', ar: 'المساحة = القاعدة × الارتفاع.'),
              BilingualText(en: '10 × 6 = ?', ar: '10 × 6 = ؟'),
              BilingualText(en: 'The answer is 60 cm².', ar: 'الإجابة 60 سم².'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm5_t3',
            activityType: 'numeric_input',
            prompt: 'Parallelogram area = 84 cm², base = 12 cm. Height = ?',
            promptAr: 'مساحة متوازي أضلاع = 84 سم²، القاعدة = 12 سم. الارتفاع = ؟',
            options: [],
            correctAnswer: 7,
            hints: [
              BilingualText(en: 'Height = Area ÷ base.', ar: 'الارتفاع = المساحة ÷ القاعدة.'),
              BilingualText(en: '84 ÷ 12 = ?', ar: '84 ÷ 12 = ؟'),
              BilingualText(en: 'The answer is 7 cm.', ar: 'الإجابة 7 سم.'),
            ],
            xpReward: 10,
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm5_app',
          activityType: 'numeric_input',
          prompt: 'City square: parallelogram shape. Base = 15 m, height = 8 m. Area = ? m²',
          promptAr: 'ساحة المدينة: شكل متوازي أضلاع. القاعدة = 15 م، الارتفاع = 8 م. المساحة = ؟ م²',
          options: [],
          correctAnswer: 120,
          hints: [
            BilingualText(en: 'Area = base × height for any parallelogram.', ar: 'المساحة = القاعدة × الارتفاع لأي متوازي أضلاع.'),
            BilingualText(en: '15 × 8 = ?', ar: '15 × 8 = ؟'),
            BilingualText(en: 'The answer is 120 m².', ar: 'الإجابة 120 م².'),
          ],
          xpReward: 20,
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm5_cp1',
            type: 'choice',
            prompt: 'To find parallelogram area, you need: base × ...',
            promptAr: 'لحساب مساحة متوازي الأضلاع، تحتاج: القاعدة × ...',
            correctAnswer: 1,
            options: ['Side / الضلع', 'Height / الارتفاع', 'Perimeter / المحيط', 'Diagonal / القطر'],
          ),
          CheckpointQuestion(
            id: 'm5_cp2',
            type: 'numeric_input',
            prompt: 'Base = 20 m, height = 11 m. Area = ?',
            promptAr: 'القاعدة = 20 م، الارتفاع = 11 م. المساحة = ؟',
            correctAnswer: 220,
            options: [],
          ),
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
      en: 'A city crisis! We must use everything we\'ve learned to save the infrastructure.',
      ar: 'أزمة في المدينة! يجب استخدام كل ما تعلمته لإنقاذ البنية التحتية.',
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
            id: 'm6_t1',
            activityType: 'choice',
            prompt: 'Bridge support is a parallelogram. One angle is 75°. Its opposite angle is:',
            promptAr: 'دعامة جسر متوازي أضلاع. إحدى زواياه 75°. الزاوية المقابلة:',
            options: ['75°', '105°', '90°', '150°'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'What do we know about opposite angles in a parallelogram?', ar: 'ماذا نعرف عن الزوايا المتقابلة في متوازي الأضلاع؟'),
              BilingualText(en: 'They are always equal.', ar: 'هي متساوية دائماً.'),
              BilingualText(en: 'The answer is 75°.', ar: 'الإجابة 75°.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm6_t2',
            activityType: 'choice',
            prompt: 'Road: parallel lines cut by transversal. Angle = 40°. Alternate interior angle = ?',
            promptAr: 'طريق: خطوط متوازية يقطعها قاطع. زاوية = 40°. الزاوية المتبادلة داخلية = ؟',
            options: ['40°', '50°', '90°', '140°'],
            correctAnswer: 0,
            hints: [
              BilingualText(en: 'Alternate interior angles are equal when lines are parallel.', ar: 'الزوايا المتبادلة داخلية متساوية عند الخطوط المتوازية.'),
              BilingualText(en: 'They are on opposite sides of the transversal.', ar: 'تكون على جهتي القاطع المتقابلتين.'),
              BilingualText(en: 'The answer is 40°.', ar: 'الإجابة 40°.'),
            ],
            xpReward: 10,
          ),
          CityActivity(
            id: 'm6_t3',
            activityType: 'choice',
            prompt: 'Square side = 6 m. Diagonal = ? (rounded)',
            promptAr: 'ضلع مربع = 6 م. القطر = ؟ (تقريباً)',
            options: ['6', '7.2', '8.5', '12'],
            correctAnswer: 2,
            hints: [
              BilingualText(en: 'Diagonal = side × √2 ≈ side × 1.414.', ar: 'القطر = الضلع × جذر2 ≈ الضلع × 1.414.'),
              BilingualText(en: '6 × 1.414 ≈ ?', ar: '6 × 1.414 ≈ ؟'),
              BilingualText(en: 'The answer is about 8.5.', ar: 'الإجابة تقريباً 8.5.'),
            ],
            xpReward: 10,
          ),
        ],
        applicationActivity: CityActivity(
          id: 'm6_app',
          activityType: 'choice',
          prompt: 'Final challenge: building with 4 equal sides and 4 right angles is:',
          promptAr: 'التحدي النهائي: مبنى بـ 4 أضلاع متساوية و 4 زوايا قائمة هو:',
          options: ['Rhombus / معين', 'Rectangle / مستطيل', 'Square / مربع', 'Trapezoid / شبه منحرف'],
          correctAnswer: 2,
          hints: [
            BilingualText(en: 'Equal sides = rhombus property. Right angles = rectangle property.', ar: 'أضلاع متساوية = خاصية المعين. زوايا قائمة = خاصية المستطيل.'),
            BilingualText(en: 'Only one shape has BOTH.', ar: 'شكل واحد فقط يمتلك كليهما.'),
            BilingualText(en: 'The answer is: Square.', ar: 'الإجابة: مربع.'),
          ],
          xpReward: 20,
        ),
        checkpointQuestions: [
          CheckpointQuestion(
            id: 'm6_cp1',
            type: 'choice',
            prompt: 'Parallel lines cut by transversal: angle = 40°. Alternate interior angle = ?',
            promptAr: 'خطوط متوازية يقطعها قاطع: زاوية = 40°. الزاوية المتبادلة داخلية = ؟',
            correctAnswer: 0,
            options: ['40°', '50°', '140°', '180°'],
          ),
          CheckpointQuestion(
            id: 'm6_cp2',
            type: 'choice',
            prompt: 'Square side = 6 m. Diagonal = ? (rounded)',
            promptAr: 'ضلع مربع = 6 م. القطر = ؟ (تقريباً)',
            correctAnswer: 2,
            options: ['6', '7.2', '8.5', '12'],
          ),
          CheckpointQuestion(
            id: 'm6_cp3',
            type: 'choice',
            prompt: 'Parallelogram angle A = 80°. Adjacent angle B = ?',
            promptAr: 'زاوية في متوازي أضلاع A = 80°. الزاوية المجاورة B = ؟',
            correctAnswer: 1,
            options: ['80°', '100°', '90°', '120°'],
          ),
        ],
      ),
    ],
  ),
];