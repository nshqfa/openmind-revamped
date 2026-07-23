// **
//  * Seed script for مدينة لا تنهار (Unshakable City) — Full Learning Content.
//  *   npm -w backend run seed:city
//  *
//  * Seeds the COMPLETE learning content for all 6 missions:
//  *   - Updates existing nodes with conceptKey, cityMission, titleAr, nodeStatus
//  *   - Creates 6 PathNodeStages per node (scene → discovery → explanation → training → application → verification)
//  *   - Creates PathNodeActivities with server-side correct answers, hints, and correction rules
//  *   - Creates PathNodeCheckpoint (2-3 questions, 70% pass threshold) per node
//  *
//  * Mission mapping (from openmind_middle_school_city_plan_ar.pdf):
//  *   1. شوارع لا تتصادم — parallel_lines
//  *   2. تقاطع الطرق الذكي — angles
//  *   3. جسر يبقى ثابتا — parallelogram
//  *   4. مبان بأشكال مختلفة — rectangle + square_rhombus
//  *   5. ساحة المدينة — parallelogram_area
//  *   6. تحدي إنقاذ المدينة — combined_challenge
//  *
//  * Idempotent: skips if stages/activities/checkpoints already exist.
//  */
import 'dotenv/config';
import { dirname, join, fileURLToPath } from 'node:fs';
import { createStore } from '../store/index.js';
import type { Store } from '../store/types.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

// ════════════════════════════════════════════════════════════════════════════
// Mission definitions
// ════════════════════════════════════════════════════════════════════════════

interface MissionDef {
  conceptKey: string;
  cityMission: string;
  titleAr: string;
  nodeStatus: 'available' | 'soon';
  scene: { text: string; sentenceAr: string };
  discovery: { instruction: string; instructionAr: string };
  explanation: { sentence: string; sentenceAr: string };
  skills: MissionSkill[];
}

interface MissionSkill {
  skillId: string;
  depth: number; // 0 or 1
  title: string;
  titleAr: string;
  topic: string;
  trainingActivities: TrainingActivity[];
  applicationActivity: ApplicationActivity;
  checkpointQuestions: CheckpointQuestion[];
}

interface TrainingActivity {
  activityType: string;
  prompt: string;
  promptAr: string;
  dataJson: Record<string, unknown>;
  correctAnswerJson: Record<string, unknown>;
  correctionRulesJson?: Record<string, unknown>;
  hintsJson: Array<{ level: number; text: string; sentenceAr: string }>;
  skillId?: string;
  xpReward?: number;
}

interface ApplicationActivity {
  activityType: string;
  prompt: string;
  promptAr: string;
  dataJson: Record<string, unknown>;
  correctAnswerJson: Record<string, unknown>;
  correctionRulesJson?: Record<string, unknown>;
  hintsJson: Array<{ level: number; text: string; sentenceAr: string }>;
  skillId?: string;
  xpReward?: number;
}

interface CheckpointQuestion {
  id: string;
  type: string;
  prompt: string;
  promptAr: string;
  correctAnswer: unknown;
  options?: string[];
  errorPatterns?: Array<{ condition: string; label: string }>;
}

// ════════════════════════════════════════════════════════════════════════════
// MISSION 1: شوارع لا تتصادم — المستقيم المتوازي والقاطع
// ════════════════════════════════════════════════════════════════════════════
const MISSION_1: MissionDef = {
  conceptKey: 'parallel_lines',
  cityMission: 'streets_no_collision',
  titleAr: 'شوارع لا تتصادم',
  nodeStatus: 'available',
  scene: {
    text: 'A new road crosses two parallel streets. We need to set up the traffic signals at the intersections correctly.',
    sentenceAr: 'شارع جديد يعبر طريقين متوازيين، ويجب ضبط التقاطعات لوضع الإشارات بطريقة صحيحة.',
  },
  discovery: {
    instruction: 'Drag the transversal line and change its angle. Observe which angles remain equal and which change.',
    instructionAr: 'اسحب القاطع وغير ميله، ثم اضغط على الزوايا وراقب ما يبقى متساوياً.',
  },
  explanation: {
    sentence: 'When parallel lines are cut by a transversal, corresponding angles are always equal.',
    sentenceAr: 'زاويتان متقابلتان بالرأس تتساويان دائماً عند تقاطع مستقيمين.',
  },
  skills: [
    // ── Depth 0: Introduction ──
    {
      skillId: 'parallel_lines_intro',
      depth: 0,
      title: 'Parallel & Perpendicular Lines: Introduction',
      titleAr: 'المستقيم المتوازي والقاطع: مقدمة',
      topic: 'Identifying parallel, perpendicular, and intersecting lines',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'Two lines that never meet are called:',
          promptAr: 'مستقيمان لا يلتقيان في أي نقطة يُسميان:',
          dataJson: { options: ['Parallel lines', 'Perpendicular lines', 'Intersecting lines', 'Curved lines'] },
          correctAnswerJson: { correctIndex: 0 },
          correctionRulesJson: { errorPatterns: [{ condition: 'chose_perpendicular', label: 'confused_parallel_perpendicular' }] },
          hintsJson: [
            { level: 1, text: 'Think about train tracks — do they ever meet?', sentenceAr: 'فكّر في قضبان القطار — هل تلتقي يوماً؟' },
            { level: 2, text: 'Parallel lines keep the same distance apart.', sentenceAr: 'المستقيمات المتوازية تحافظ على نفس المسافة بينها.' },
            { level: 3, text: 'The answer starts with "Para" — like "parallel".', sentenceAr: 'الإجابة تبدأ بـ "متوازية".' },
          ],
          skillId: 'parallel_lines',
          xpReward: 10,
        },
        {
          activityType: 'drag_drop',
          prompt: 'Sort each pair of lines into the correct category.',
          promptAr: 'اسحب كل زوج من المستقيمات وضعه في التصنيف الصحيح.',
          dataJson: {
            items: [
              { id: 'a', label: '↔ ↔ (equal distance)' },
              { id: 'b', label: '↔ ⊥ ↔ (right angle)' },
              { id: 'c', label: '↔ ╳ ↔ (crossing)' },
            ],
            slots: [
              { id: 's1', label: 'Parallel', correctItemId: 'a' },
              { id: 's2', label: 'Perpendicular', correctItemId: 'b' },
              { id: 's3', label: 'Intersecting', correctItemId: 'c' },
            ],
          },
          correctAnswerJson: { s1: 'a', s2: 'b', s3: 'c' },
          hintsJson: [
            { level: 1, text: 'Parallel = same direction, Perpendicular = right angle, Intersecting = cross.', sentenceAr: 'متوازي = نفس الاتجاه، عمودي = زاوية قائمة، متقاطع = يتقاطعان.' },
            { level: 2, text: 'The ⊥ symbol means perpendicular (90°).', sentenceAr: 'الرمز ⊥ يعني العمودي (90°).' },
            { level: 3, text: 'Equal-distance pair → parallel. Right-angle pair → perpendicular.', sentenceAr: 'الزوج المتساوي المسافة → متوازي. الزاوية القائمة → عمودي.' },
          ],
          skillId: 'parallel_lines',
          xpReward: 15,
        },
        {
          activityType: 'numeric_input',
          prompt: 'A transversal cuts two parallel lines forming an angle of 65°. What is the corresponding angle on the other line?',
          promptAr: 'قاطع يقطع مستقيمين متوازيين تكون زاوية 65°. ما قياس الزاوية المناظرة لها في المستقيم الآخر؟',
          dataJson: {},
          correctAnswerJson: { value: 65 },
          correctionRulesJson: {
            tolerance: 0,
            errorPatterns: [
              { condition: 'supplement_confusion', label: 'confused_corresponding_supplementary' },
            ],
          },
          hintsJson: [
            { level: 1, text: 'Corresponding angles are ALWAYS equal when lines are parallel.', sentenceAr: 'الزوايا المناظرة تساوي دائماً عند توازي المستقيمات.' },
            { level: 2, text: 'The angle has the same measure on both sides.', sentenceAr: 'الزاوية لها نفس القياس في كلا الجانبين.' },
            { level: 3, text: 'The answer is the same as the given angle: 65°.', sentenceAr: 'الإجابة هي نفس الزاوية المعطاة: 65°.' },
          ],
          skillId: 'parallel_lines',
          xpReward: 10,
        },
      ],
      applicationActivity: {
        activityType: 'angle_explorer',
        prompt: 'In the city intersection below, identify all pairs of vertical angles. Move the transversal and verify they stay equal.',
        promptAr: 'في تقاطع المدينة أدناه، حدّد جميع أزواج الزوايا المتقابلة بالرأس. حرّك القاطع وتحقق أنها تبقى متساوية.',
        dataJson: {
          lines: [
            { id: 'l1', start: { x: 0, y: 0 }, end: { x: 200, y: 0 } },
            { id: 'l2', start: { x: 0, y: 100 }, end: { x: 200, y: 100 } },
            { id: 'l3', start: { x: 100, y: -20 }, end: { x: 120, y: 120 } },
          ],
          anglePoints: ['A', 'B', 'C', 'D'],
        },
        correctAnswerJson: {
          angles: { A: 65, B: 115, C: 65, D: 115 },
        },
        correctionRulesJson: {
          tolerance: 2,
          partialCredit: true,
        },
        hintsJson: [
          { level: 1, text: 'Vertical angles are opposite each other at the intersection point.', sentenceAr: 'الزوايا المتقابلة بالرأس تقابل بعضها عند نقطة التقاطع.' },
          { level: 2, text: 'A and C are vertical. B and D are vertical.', sentenceAr: 'A و C متقابلتان. B و D متقابلتان.' },
          { level: 3, text: 'Vertical angles always sum to the same values as their opposites.', sentenceAr: 'الزوايا المتقابلة بالرأس تساوي دائماً نظيراتها.' },
        ],
        skillId: 'parallel_lines',
        xpReward: 20,
      },
      checkpointQuestions: [
        {
          id: 'm1d0_q1',
          type: 'choice',
          prompt: 'Two parallel lines are cut by a transversal. One angle is 110°. What is its vertically opposite angle?',
          promptAr: 'مستقيمان متوازيان يقطعهما قاطع. إحدى الزوايا 110°. ما الزاوية المقابلة لها بالرأس؟',
          correctAnswer: 110,
          options: ['70°', '110°', '90°', '180°'],
          errorPatterns: [{ condition: 'supplement_confusion', label: 'chose_supplement_instead_of_vertical' }],
        },
        {
          id: 'm1d0_q2',
          type: 'choice',
          prompt: 'Which term describes lines that never meet?',
          promptAr: 'أي مصطلح يصف مستقيمين لا يلتقيان أبداً؟',
          correctAnswer: 'parallel',
          options: ['Perpendicular', 'Parallel', 'Intersecting', 'Adjacent'],
        },
        {
          id: 'm1d0_q3',
          type: 'numeric_input',
          prompt: 'Two parallel lines are cut by a transversal. Angle A = 45°. What is the corresponding angle B?',
          promptAr: 'قاطع يقطع مستقيمين متوازيين. الزاوية A = 45°. ما الزاوية المناظرة B؟',
          correctAnswer: 45,
        },
      ],
    },
    // ── Depth 1: Deeper understanding ──
    {
      skillId: 'parallel_lines_deep',
      depth: 1,
      title: 'Parallel Lines: Angle Relationships',
      titleAr: 'المستقيم المتوازي: علاقات الزوايا',
      topic: 'Alternate interior, alternate exterior, and corresponding angles',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'When parallel lines are cut by a transversal, alternate interior angles are:',
          promptAr: 'عند قطع مستقيمين متوازيين بقاطع، الزاويتان المتبادلتان داخلياً تكونان:',
          dataJson: { options: ['Equal', 'Supplementary (180°)', 'Complementary (90°)', 'Always different'] },
          correctAnswerJson: { correctIndex: 0 },
          hintsJson: [
            { level: 1, text: 'Alternate interior angles are between the parallel lines, on opposite sides of the transversal.', sentenceAr: 'الزاويتان المتبادلتان داخلياً تقعان بين المستقيمين المتوازيين.' },
            { level: 2, text: 'A key theorem: alternate interior angles are always equal when lines are parallel.', sentenceAr: 'قاعدة أساسية: الزاويتان المتبادلتان داخلياً تساويان دائماً عند التوازي.' },
            { level: 3, text: 'They are equal — same as corresponding angles.', sentenceAr: 'تساويان — مثل الزوايا المناظرة.' },
          ],
          skillId: 'parallel_lines',
          xpReward: 10,
        },
        {
          activityType: 'numeric_input',
          prompt: 'Two parallel lines are cut by a transversal. An interior angle on one side is 130°. What is the alternate interior angle on the other side?',
          promptAr: 'مستقيمان متوازيان يقطعهما قاطع. زاوية داخلية في جانب واحد 130°. ما الزاوية المتبادلة الداخلية في الجانب الآخر؟',
          dataJson: {},
          correctAnswerJson: { value: 130 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Alternate interior angles are equal when lines are parallel.', sentenceAr: 'الزوايا المتبادلة داخلية متساوية عند التوازي.' },
            { level: 2, text: 'Same measure as the given angle.', sentenceAr: 'نفس قياس الزاوية المعطاة.' },
          ],
          skillId: 'parallel_lines',
          xpReward: 15,
        },
        {
          activityType: 'choice',
          prompt: 'Parallel lines are cut by a transversal. An exterior angle is 120°. What is its alternate exterior angle?',
          promptAr: 'قاطع يقطع مستقيمين متوازيين. زاوية خارجية 120°. ما الزاوية المتبادلة الخارجية لها؟',
          dataJson: { options: ['60°', '120°', '90°', '30°'] },
          correctAnswerJson: { correctIndex: 1 },
          correctionRulesJson: { errorPatterns: [{ condition: 'supplement_confusion', label: 'confused_exterior_supplement' }] },
          hintsJson: [
            { level: 1, text: 'Alternate exterior angles follow the same rule as alternate interior.', sentenceAr: 'الزوايا المتبادلة خارجية تتبع نفس قاعدة المتبادلة داخلية.' },
            { level: 2, text: 'They are equal.', sentenceAr: 'تساويان.' },
          ],
          skillId: 'parallel_lines',
          xpReward: 10,
        },
      ],
      applicationActivity: {
        activityType: 'bridge_builder',
        prompt: 'Design the bridge supports: set the angles so that the support beams are parallel. The transversal angle is 75°.',
        promptAr: 'صمّم دعامات الجسر: اضبط الزوايا لتكون الدعامات متوازية. زاوية القاطع 75°.',
        dataJson: {
          beamAngle: 75,
          constraints: [
            { label: 'Left interior angle', angle: 75 },
            { label: 'Right interior angle', angle: 105 },
          ],
        },
        correctAnswerJson: {
          constraints: [
            { angle: 75 },
            { angle: 105 },
          ],
        },
        correctionRulesJson: {
          tolerance: 2,
          errorPatterns: [{ condition: 'procedural_error', label: 'wrong_beam_angle' }],
        },
        hintsJson: [
          { level: 1, text: 'Parallel beams need equal corresponding angles.', sentenceAr: 'الدعامات المتوازية تحتاج زوايا مناظرة متساوية.' },
          { level: 2, text: 'Interior angles on the same side of the transversal are supplementary.', sentenceAr: 'الزوايا الداخلية في نفس جانب القاطع متكاملة.' },
          { level: 3, text: 'If one angle is 75°, the interior on the same side is 180° - 75° = 105°.', sentenceAr: 'إذا إحدى الزوايا 75°، الداخلية في نفس الجانب = 180° - 75° = 105°.' },
        ],
        skillId: 'parallel_lines',
        xpReward: 25,
      },
      checkpointQuestions: [
        {
          id: 'm1d1_q1',
          type: 'numeric_input',
          prompt: 'Parallel lines cut by a transversal. One alternate interior angle is 85°. What is the other?',
          promptAr: 'قاطع يقطع مستقيمين متوازيين. إحدى الزوايا المتبادلة داخلية 85°. ما الأخرى؟',
          correctAnswer: 85,
        },
        {
          id: 'm1d1_q2',
          type: 'choice',
          prompt: 'If two parallel lines are cut by a transversal, which pair is NOT always equal?',
          promptAr: 'إذا قطع قاطع مستقيمين متوازيين، أي زوج ليس متساوياً دائماً؟',
          correctAnswer: 'same-side interior',
          options: ['Corresponding angles', 'Alternate interior angles', 'Alternate exterior angles', 'Same-side interior angles'],
        },
        {
          id: 'm1d1_q3',
          type: 'numeric_input',
          prompt: 'An exterior angle on one side is 140°. What is the interior angle on the same side?',
          promptAr: 'زاوية خارجية في أحد الجانبين 140°. ما الزاوية الداخلية في نفس الجانب؟',
          correctAnswer: 40,
          errorPatterns: [{ condition: 'supplement_confusion', label: 'gave_exterior_instead_of_supplement' }],
        },
      ],
    },
  ],
};

// ════════════════════════════════════════════════════════════════════════════
// MISSION 2: تقاطع الطرق الذكي — علاقات الزوايا
// ════════════════════════════════════════════════════════════════════════════
const MISSION_2: MissionDef = {
  conceptKey: 'angles',
  cityMission: 'smart_intersection',
  titleAr: 'تقاطع الطرق الذكي',
  nodeStatus: 'soon',
  scene: {
    text: 'The smart intersection uses angle sensors. We need to program the sensors by understanding angle relationships.',
    sentenceAr: 'تقاطع ذكي يستخدم حساسات زوايا. نحتاج برمجتها بفهم علاقات الزوايا.',
  },
  discovery: {
    instruction: 'Change the angles in the intersection and observe which pairs always add up to 180° and which are always equal.',
    instructionAr: 'غيّر الزوايا في التقاطع ولاحظ أي أزواج مجموعها دائماً 180° وأيها متساوية دائماً.',
  },
  explanation: {
    sentence: 'At an intersection, vertical angles are equal, and adjacent angles are supplementary (add to 180°).',
    sentenceAr: 'في التقاطع، الزوايا المتقابلة بالرأس متساوية، والمجاورة متكاملة (مجموعها 180°).',
  },
  skills: [
    {
      skillId: 'angles_intro',
      depth: 0,
      title: 'Angle Types: Acute, Right, Obtuse',
      titleAr: 'أنواع الزوايا: حادة، قائمة، منفرجة',
      topic: 'Classifying angles by their measure',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'An angle that measures 120° is called:',
          promptAr: 'زاوية قياسها 120° تُسمى:',
          dataJson: { options: ['Acute', 'Right', 'Obtuse', 'Straight'] },
          correctAnswerJson: { correctIndex: 2 },
          hintsJson: [
            { level: 1, text: 'Acute < 90°, Right = 90°, Obtuse > 90° and < 180°.', sentenceAr: 'حادة < 90°، قائمة = 90°، منفرجة > 90° و < 180°.' },
            { level: 2, text: '120° is greater than 90°.', sentenceAr: '120° أكبر من 90°.' },
            { level: 3, text: 'The answer is "Obtuse" (منفرجة).', sentenceAr: 'الإجابة "منفرجة".' },
          ],
          skillId: 'angles',
          xpReward: 10,
        },
        {
          activityType: 'numeric_input',
          prompt: 'Two adjacent angles form a straight line. One is 70°. What is the other?',
          promptAr: 'زاويتان متجاورتان تشكلان مستقيماً. إحداهما 70°. ما الأخرى؟',
          dataJson: {},
          correctAnswerJson: { value: 110 },
          correctionRulesJson: { tolerance: 0, errorPatterns: [{ condition: 'supplement_confusion', label: 'supplement_miscalculation' }] },
          hintsJson: [
            { level: 1, text: 'Adjacent angles on a straight line add up to 180°.', sentenceAr: 'الزاويتان المتجاورتان على مستقيم مجموعهما 180°.' },
            { level: 2, text: '180° - 70° = ?', sentenceAr: '180° - 70° = ؟' },
          ],
          skillId: 'angles',
          xpReward: 10,
        },
        {
          activityType: 'choice',
          prompt: 'Two intersecting lines form four angles. One angle is 35°. What is the vertically opposite angle?',
          promptAr: 'مستقيمان يتقاطعان يكونان أربع زوايا. إحداها 35°. ما الزاوية المقابلة لها بالرأس؟',
          dataJson: { options: ['35°', '145°', '55°', '90°'] },
          correctAnswerJson: { correctIndex: 0 },
          hintsJson: [
            { level: 1, text: 'Vertical angles are always equal.', sentenceAr: 'الزوايا المتقابلة بالرأس متساوية دائماً.' },
            { level: 2, text: 'The opposite angle has the same measure.', sentenceAr: 'الزاوية المقابلة لها نفس القياس.' },
          ],
          skillId: 'angles',
          xpReward: 10,
        },
      ],
      applicationActivity: {
        activityType: 'angle_explorer',
        prompt: 'At the smart intersection, measure all four angles. Verify that vertical angles are equal and adjacent ones sum to 180°.',
        promptAr: 'في التقاطع الذكي، قِس جميع الزوايا الأربع. تحقق أن المتقابلة متساوية والمتجاورة مجموعها 180°.',
        dataJson: { lines: [{ id: 'h', start: { x: 0, y: 50 }, end: { x: 200, y: 50 } }, { id: 'v', start: { x: 100, y: 0 }, end: { x: 100, y: 100 } }], anglePoints: ['A', 'B', 'C', 'D'] },
        correctAnswerJson: { angles: { A: 70, B: 110, C: 70, D: 110 } },
        correctionRulesJson: { tolerance: 2, partialCredit: true },
        hintsJson: [
          { level: 1, text: 'The intersection creates two pairs of equal vertical angles.', sentenceAr: 'التقاطع يُنشئ زوجين من الزوايا المتقابلة المتساوية.' },
          { level: 2, text: 'A = C and B = D. A + B = 180°.', sentenceAr: 'A = C و B = D. A + B = 180°.' },
        ],
        skillId: 'angles',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm2d0_q1', type: 'choice', prompt: 'An angle measuring 45° is classified as:', promptAr: 'زاوية قياسها 45° تُصنف:', correctAnswer: 'acute', options: ['Acute', 'Right', 'Obtuse', 'Straight'] },
        { id: 'm2d0_q2', type: 'numeric_input', prompt: 'Adjacent angles on a straight line: one is 130°. What is the other?', promptAr: 'زاويتان متجاورتان على مستقيم: إحداهما 130°. ما الأخرى؟', correctAnswer: 50 },
        { id: 'm2d0_q3', type: 'choice', prompt: 'Vertical angles are always:', promptAr: 'الزوايا المتقابلة بالرأس تكون دائماً:', correctAnswer: 'equal', options: ['Equal', 'Supplementary', 'Complementary', 'Different'] },
      ],
    },
    {
      skillId: 'angles_deep',
      depth: 1,
      title: 'Angle Relationships: Supplementary & Complementary',
      titleAr: 'علاقات الزوايا: المتكاملة والمتتامة',
      topic: 'Supplementary (180°) and Complementary (90°) angle pairs',
      trainingActivities: [
        {
          activityType: 'numeric_input',
          prompt: 'Two angles are complementary. One is 37°. What is the other?',
          promptAr: 'زاويتان متتامتان. إحداهما 37°. ما الأخرى؟',
          dataJson: {},
          correctAnswerJson: { value: 53 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Complementary angles add up to 90°.', sentenceAr: 'الزوايا المتتامان مجموعها 90°.' },
            { level: 2, text: '90° - 37° = ?', sentenceAr: '90° - 37° = ؟' },
          ],
          skillId: 'angles',
          xpReward: 10,
        },
        {
          activityType: 'drag_drop',
          prompt: 'Sort each angle pair into the correct relationship category.',
          promptAr: 'صنّف كل زوج زوايا في الفئة الصحيحة.',
          dataJson: {
            items: [
              { id: 'a', label: '60° + 30°' },
              { id: 'b', label: '110° + 70°' },
              { id: 'c', label: '45° + 45°' },
            ],
            slots: [
              { id: 's1', label: 'Complementary', correctItemId: 'a' },
              { id: 's2', label: 'Supplementary', correctItemId: 'b' },
              { id: 's3', label: 'Both', correctItemId: 'c' },
            ],
          },
          correctAnswerJson: { placements: [{ slotId: 's1', itemId: 'a' }, { slotId: 's2', itemId: 'b' }, { slotId: 's3', itemId: 'c' }] },
          hintsJson: [
            { level: 1, text: 'Complementary = sum 90°. Supplementary = sum 180°.', sentenceAr: 'متتامان = مجموع 90°. متكاملان = مجموع 180°.' },
            { level: 2, text: '60+30=90, 110+70=180, 45+45=90 AND 45+45≠180.', sentenceAr: '60+30=90، 110+70=180، 45+45=90 و 45+45≠180.' },
          ],
          skillId: 'angles',
          xpReward: 15,
        },
      ],
      applicationActivity: {
        activityType: 'angle_explorer',
        prompt: 'The building has an obtuse angle of 135°. Find its supplementary angle to design the matching roof panel.',
        promptAr: 'المبنى يحتوي زاوية منفرجة 135°. أوجد الزاوية المكملة لها لتصميم لوح السقف المطابق.',
        dataJson: { givenAngle: 135 },
        correctAnswerJson: { supplementary: 45 },
        correctionRulesJson: { tolerance: 0 },
        hintsJson: [
          { level: 1, text: 'Supplementary angles add to 180°.', sentenceAr: 'الزوايا المتكاملة مجموعها 180°.' },
          { level: 2, text: '180° - 135° = 45°.', sentenceAr: '180° - 135° = 45°.' },
        ],
        skillId: 'angles',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm2d1_q1', type: 'numeric_input', prompt: 'Two complementary angles: one is 23°. What is the other?', promptAr: 'زاويتان متتامتان: إحداهما 23°. ما الأخرى؟', correctAnswer: 67 },
        { id: 'm2d1_q2', type: 'choice', prompt: 'If angle A = 90°, what is its complement?', promptAr: 'إذا الزاوية A = 90°، ما complement لها؟', correctAnswer: '0°', options: ['0°', '45°', '90°', '180°'] },
        { id: 'm2d1_q3', type: 'choice', prompt: 'Supplementary angles always add up to:', promptAr: 'الزوايا المتكاملة مجموعها دائماً:', correctAnswer: '180°', options: ['90°', '180°', '270°', '360°'] },
      ],
    },
  ],
};

// ════════════════════════════════════════════════════════════════════════════
// MISSION 3: جسر يبقى ثابتا — خصائص متوازي الأضلاع
// ════════════════════════════════════════════════════════════════════════════
const MISSION_3: MissionDef = {
  conceptKey: 'parallelogram',
  cityMission: 'stable_bridge',
  titleAr: 'جسر يبقى ثابتا',
  nodeStatus: 'soon',
  scene: {
    text: 'The old bridge is unstable. We need to verify that its parallelogram-shaped supports have the correct properties to hold.',
    sentenceAr: 'الجسر القديم غير مستقر. نحتاج التحقق من أن دعاماته على شكل متوازي أضلاع تمتلك الخصائص الصحيحة.',
  },
  discovery: {
    instruction: 'Measure the sides and angles of the bridge support. Drag vertices and observe how opposite sides stay equal and parallel.',
    instructionAr: 'قِس أضلاع وزوايا دعامة الجسر. اسحب الرؤوس ولاحظ كيف يبقى الضلعان المتقابلان متساويين ومتوازيين.',
  },
  explanation: {
    sentence: 'In a parallelogram: opposite sides are equal and parallel, opposite angles are equal, and diagonals bisect each other.',
    sentenceAr: 'في متوازي الأضلاع: الأضلاع المتقابلة متساوية ومتوازية، والزوايا المتقابلة متساوية، والأقطار تنصف بعضها.',
  },
  skills: [
    {
      skillId: 'parallelogram_intro',
      depth: 0,
      title: 'Parallelogram: Basic Properties',
      titleAr: 'متوازي الأضلاع: الخصائص الأساسية',
      topic: 'Opposite sides parallel and equal, opposite angles equal',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'In a parallelogram, opposite sides are:',
          promptAr: 'في متوازي الأضلاع، الأضلاع المتقابلة تكون:',
          dataJson: { options: ['Equal and parallel', 'Equal only', 'Parallel only', 'Perpendicular'] },
          correctAnswerJson: { correctIndex: 0 },
          hintsJson: [
            { level: 1, text: 'The name "parallelogram" contains "parallel".', sentenceAr: 'اسم "متوازي الأضلاع" يحتوي "متوازي".' },
            { level: 2, text: 'Both equal AND parallel.', sentenceAr: 'متساوية ومتوازية معاً.' },
          ],
          skillId: 'parallelogram',
          xpReward: 10,
        },
        {
          activityType: 'shape_compare',
          prompt: 'Compare the properties: which shape has ALL opposite sides equal AND parallel?',
          promptAr: 'قارن الخصائص: أي شكل جميع أضلاعه المتقابلة متساوية ومتوازية؟',
          dataJson: {
            shapes: ['Rectangle', 'Parallelogram', 'Trapezoid', 'Kite'],
          },
          correctAnswerJson: { properties: { oppositeSidesEqual: true, oppositeSidesParallel: true, oppositeAnglesEqual: true } },
          hintsJson: [
            { level: 1, text: 'A trapezoid has only one pair of parallel sides.', sentenceAr: 'شبه المنحرف لديه زوج واحد فقط من الأضلاع المتوازية.' },
            { level: 2, text: 'Parallelogram is the answer — both pairs of opposite sides are equal and parallel.', sentenceAr: 'متوازي الأضلاع هو الجواب — كلا الزوجين متساويان ومتوازيان.' },
          ],
          skillId: 'parallelogram',
          xpReward: 15,
        },
        {
          activityType: 'numeric_input',
          prompt: 'In a parallelogram, one side is 8 cm. What is the opposite side?',
          promptAr: 'في متوازي أضلاع، أحد أضلاعه 8 سم. ما الضلع المقابل؟',
          dataJson: {},
          correctAnswerJson: { value: 8 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Opposite sides of a parallelogram are equal.', sentenceAr: 'الأضلاع المتقابلة في متوازي الأضلاع متساوية.' },
          ],
          skillId: 'parallelogram',
          xpReward: 10,
        },
      ],
      applicationActivity: {
        activityType: 'shape_compare',
        prompt: 'Verify the bridge support: check that opposite sides are equal and angles match the parallelogram properties.',
        promptAr: 'تحقق من دعامة الجسر: تأكد أن الأضلاع المتقابلة متساوية والزوايا تطابق خصائص متوازي الأضلاع.',
        dataJson: { sides: [5, 3, 5, 3], angles: [70, 110, 70, 110] },
        correctAnswerJson: { properties: { isParallelogram: true, oppositeSidesEqual: true, oppositeAnglesEqual: true } },
        correctionRulesJson: { partialCredit: true },
        hintsJson: [
          { level: 1, text: 'Check: are opposite sides the same length?', sentenceAr: 'تحقق: هل الأضلاع المتقابلة بنفس الطول؟' },
          { level: 2, text: 'Check: are opposite angles the same measure?', sentenceAr: 'تحقق: هل الزوايا المتقابلة بنفس القياس؟' },
        ],
        skillId: 'parallelogram',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm3d0_q1', type: 'choice', prompt: 'In a parallelogram, if one angle is 80°, the opposite angle is:', promptAr: 'في متوازي أضلاع، إذا إحدى الزوايا 80°، الزاوية المقابلة:', correctAnswer: '80°', options: ['80°', '100°', '90°', '40°'] },
        { id: 'm3d0_q2', type: 'numeric_input', prompt: 'Parallelogram sides: one pair is 12 cm. What is the other pair?', promptAr: 'أضلاع متوازي: زوج واحد 12 سم. ما الزوج الآخر؟', correctAnswer: 12 },
        { id: 'm3d0_q3', type: 'choice', prompt: 'Parallelogram diagonals:', promptAr: 'أقطار متوازي الأضلاع:', correctAnswer: 'bisect each other', options: ['Are equal', 'Bisect each other', 'Are perpendicular', 'Are parallel'] },
      ],
    },
    {
      skillId: 'parallelogram_deep',
      depth: 1,
      title: 'Parallelogram: Diagonals & Angle Sums',
      titleAr: 'متوازي الأضلاع: الأقطار ومجموع الزوايا',
      topic: 'Diagonals bisect each other; consecutive angles are supplementary',
      trainingActivities: [
        {
          activityType: 'numeric_input',
          prompt: 'The diagonals of a parallelogram intersect at point M. If one half of a diagonal is 4 cm, the other half is:',
          promptAr: 'أقطار متوازي أضلاع تتقاطع في M. إذا نصف أحد الأقطار 4 سم، ما النصف الآخر؟',
          dataJson: {},
          correctAnswerJson: { value: 4 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Diagonals of a parallelogram bisect each other.', sentenceAr: 'أقطار متوازي الأضلاع تنصف بعضها.' },
          ],
          skillId: 'parallelogram',
          xpReward: 10,
        },
        {
          activityType: 'numeric_input',
          prompt: 'In a parallelogram, one angle is 70°. What is the adjacent angle?',
          promptAr: 'في متوازي أضلاع، إحدى الزوايا 70°. ما الزاوية المجاورة؟',
          dataJson: {},
          correctAnswerJson: { value: 110 },
          correctionRulesJson: { tolerance: 0, errorPatterns: [{ condition: 'supplement_confusion', label: 'adjacent_not_opposite' }] },
          hintsJson: [
            { level: 1, text: 'Consecutive (adjacent) angles in a parallelogram are supplementary.', sentenceAr: 'الزوايا المتتالية في متوازي الأضلاع متكاملة.' },
            { level: 2, text: '180° - 70° = 110°.', sentenceAr: '180° - 70° = 110°.' },
          ],
          skillId: 'parallelogram',
          xpReward: 15,
        },
      ],
      applicationActivity: {
        activityType: 'bridge_builder',
        prompt: 'Design the bridge diagonal supports. Ensure the diagonals bisect each other at the center point.',
        promptAr: 'صمّم دعامات الجسر القطرية. تأكد أن الأقطار تنصف بعضها في نقطة المركز.',
        dataJson: { constraints: [{ label: 'Diagonal 1 half', angle: 6 }, { label: 'Diagonal 2 half', angle: 6 }] },
        correctAnswerJson: { constraints: [{ angle: 6 }, { angle: 6 }] },
        correctionRulesJson: { tolerance: 0 },
        hintsJson: [
          { level: 1, text: 'Both halves of the diagonals must be equal.', sentenceAr: 'نصفا الأقطار يجب أن يكونا متساويين.' },
        ],
        skillId: 'parallelogram',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm3d1_q1', type: 'numeric_input', prompt: 'Parallelogram: angle A = 70°. Adjacent angle B = ?', promptAr: 'متوازي أضلاع: الزاوية A = 70°. الزاوية المجاورة B = ؟', correctAnswer: 110 },
        { id: 'm3d1_q2', type: 'choice', prompt: 'If half of one diagonal is 7 cm, the full diagonal is:', promptAr: 'إذا نصف أحد الأقطار 7 سم، فالقطر كاملاً:', correctAnswer: '14 cm', options: ['7 cm', '14 cm', '3.5 cm', '21 cm'] },
        { id: 'm3d1_q3', type: 'choice', prompt: 'Sum of all interior angles of a parallelogram:', promptAr: 'مجموع جميع الزوايا الداخلية لمتوازي الأضلاع:', correctAnswer: '360°', options: ['180°', '270°', '360°', '540°'] },
      ],
    },
  ],
};

// ════════════════════════════════════════════════════════════════════════════
// MISSION 4: مبان بأشكال مختلفة — المستطيل والمربع والمعين
// ════════════════════════════════════════════════════════════════════════════
const MISSION_4: MissionDef = {
  conceptKey: 'rectangle_square_rhombus',
  cityMission: 'diverse_buildings',
  titleAr: 'مبان بأشكال مختلفة',
  nodeStatus: 'soon',
  scene: {
    text: 'The city needs buildings of different shapes. We must understand the unique properties of rectangles, squares, and rhombuses to build them correctly.',
    sentenceAr: 'المدينة تحتاج مبانٍ بأشكال مختلفة. يجب فهم خصائص المستطيل والمربع والمعين لبنائها بشكل صحيح.',
  },
  discovery: {
    instruction: 'Compare the shapes: drag vertices and observe which properties change and which stay fixed.',
    instructionAr: 'قارن الأشكال: اسحب الرؤوس ولاحظ أي الخصائص تتغير وأيها تبقى ثابتة.',
  },
  explanation: {
    sentence: 'Rectangle = parallelogram with right angles. Square = rectangle with equal sides. Rhombus = parallelogram with equal sides.',
    sentenceAr: 'المستطيل = متوازي أضلاع بزوايا قائمة. المربع = مستطيل بأضلاع متساوية. المعين = متوازي أضلاع بأضلاع متساوية.',
  },
  skills: [
    {
      skillId: 'rect_sq_rhomb_intro',
      depth: 0,
      title: 'Rectangle, Square & Rhombus: Identification',
      titleAr: 'المستطيل والمربع والمعين: التعرف والتمييز',
      topic: 'Identifying and distinguishing between quadrilateral types',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'A parallelogram with four right angles is a:',
          promptAr: 'متوازي أضلاع بأربع زوايا قائمة هو:',
          dataJson: { options: ['Rhombus', 'Rectangle', 'Trapezoid', 'Kite'] },
          correctAnswerJson: { correctIndex: 1 },
          hintsJson: [
            { level: 1, text: 'A rectangle is a special parallelogram with 90° angles.', sentenceAr: 'المستطيل متوازي أضلاع خاص بزوايا 90°.' },
          ],
          skillId: 'rectangle',
          xpReward: 10,
        },
        {
          activityType: 'choice',
          prompt: 'A square has diagonals that are:',
          promptAr: 'مربع أقطاره:',
          dataJson: { options: ['Equal only', 'Equal and perpendicular', 'Unequal', 'Parallel'] },
          correctAnswerJson: { correctIndex: 1 },
          hintsJson: [
            { level: 1, text: 'A square is both a rectangle and a rhombus — it has properties of both.', sentenceAr: 'المربع مستطيل ومعين معاً — يجمع خصائصهما.' },
            { level: 2, text: 'Equal (from rectangle) AND perpendicular (from rhombus).', sentenceAr: 'متساوية (من المستطيل) ومتعامدة (من المعين).' },
          ],
          skillId: 'rectangle',
          xpReward: 15,
        },
        {
          activityType: 'drag_drop',
          prompt: 'Sort each property to the correct shape.',
          promptAr: 'صنّف كل خاصية للشكل الصحيح.',
          dataJson: {
            items: [
              { id: 'a', label: 'All sides equal + 4 right angles' },
              { id: 'b', label: 'All sides equal + not necessarily right angles' },
              { id: 'c', label: 'Opposite sides equal + 4 right angles' },
            ],
            slots: [
              { id: 's1', label: 'Square', correctItemId: 'a' },
              { id: 's2', label: 'Rhombus', correctItemId: 'b' },
              { id: 's3', label: 'Rectangle', correctItemId: 'c' },
            ],
          },
          correctAnswerJson: { placements: [{ slotId: 's1', itemId: 'a' }, { slotId: 's2', itemId: 'b' }, { slotId: 's3', itemId: 'c' }] },
          hintsJson: [
            { level: 1, text: 'Square = equal sides + right angles. Rhombus = equal sides, no right angle requirement.', sentenceAr: 'المربع = أضلاع متساوية + زوايا قائمة. المعين = أضلاع متساوية بدون شرط القوائم.' },
          ],
          skillId: 'rectangle',
          xpReward: 15,
        },
      ],
      applicationActivity: {
        activityType: 'shape_compare',
        prompt: 'Inspect the building materials: classify each as rectangle, square, or rhombus based on their measurements.',
        promptAr: 'افحص مواد البناء: صنّف كل قطعة كمستطيل أو مربع أو معين بناءً على قياساتها.',
        dataJson: { shapes: [{ sides: [5, 5, 5, 5], angles: [90, 90, 90, 90] }, { sides: [6, 4, 6, 4], angles: [90, 90, 90, 90] }, { sides: [5, 5, 5, 5], angles: [80, 100, 80, 100] }] },
        correctAnswerJson: { classifications: ['square', 'rectangle', 'rhombus'] },
        correctionRulesJson: { partialCredit: true },
        hintsJson: [
          { level: 1, text: 'Equal sides + right angles = square. Opposite equal + right angles = rectangle. Equal sides + not right = rhombus.', sentenceAr: 'أضلاع متساوية + قوائم = مربع. متقابلة متساوية + قوائم = مستطيل. متساوية + غير قوائم = معين.' },
        ],
        skillId: 'rectangle',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm4d0_q1', type: 'choice', prompt: 'A shape with all sides equal and all angles 90° is a:', promptAr: 'شكل جميع أضلاعه متساوية وجميع زواياه 90° هو:', correctAnswer: 'square', options: ['Rectangle', 'Square', 'Rhombus', 'Parallelogram'] },
        { id: 'm4d0_q2', type: 'numeric_input', prompt: 'Rectangle diagonals: one is 13 m. The other is:', promptAr: 'أقطار مستطيل: أحدهما 13 م. الآخر:', correctAnswer: 13 },
        { id: 'm4d0_q3', type: 'choice', prompt: 'Which property does a rhombus NOT necessarily have?', promptAr: 'أي خاصية لا يمتلكها المعين بالضرورة؟', correctAnswer: 'right angles', options: ['Equal sides', 'Perpendicular diagonals', 'Right angles', 'Equal opposite angles'] },
      ],
    },
    {
      skillId: 'rect_sq_rhomb_deep',
      depth: 1,
      title: 'Comparing Quadrilaterals: Area & Perimeter',
      titleAr: 'مقارنة الرباعيات: المساحة والمحيط',
      topic: 'Calculating area and perimeter for rectangles, squares, and rhombuses',
      trainingActivities: [
        {
          activityType: 'numeric_input',
          prompt: 'Rectangle: length 10 m, width 7 m. Calculate the area.',
          promptAr: 'مستطيل: طوله 10 م وعرضه 7 م. احسب المساحة.',
          dataJson: {},
          correctAnswerJson: { value: 70 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Area of rectangle = length × width.', sentenceAr: 'مساحة المستطيل = الطول × العرض.' },
            { level: 2, text: '10 × 7 = ?', sentenceAr: '10 × 7 = ؟' },
          ],
          skillId: 'rectangle',
          xpReward: 10,
        },
        {
          activityType: 'numeric_input',
          prompt: 'Rhombus: side length 5 m. Calculate the perimeter.',
          promptAr: 'معين: طول ضلعه 5 م. احسب المحيط.',
          dataJson: {},
          correctAnswerJson: { value: 20 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Perimeter = 4 × side (all sides equal).', sentenceAr: 'المحيط = 4 × الضلع (جميع الأضلاع متساوية).' },
          ],
          skillId: 'rectangle',
          xpReward: 10,
        },
      ],
      applicationActivity: {
        activityType: 'area_tiles',
        prompt: 'Tile the city hall floor: it is a rectangle 12m × 8m. Calculate the area to order tiles.',
        promptAr: 'بَلّط أرضية قاعة المدينة: مستطيلة 12م × 8م. احسب المساحة لطلب البلاط.',
        dataJson: { length: 12, width: 8, unit: 'm' },
        correctAnswerJson: { area: 96 },
        correctionRulesJson: { tolerance: 0 },
        hintsJson: [
          { level: 1, text: 'Area = length × width.', sentenceAr: 'المساحة = الطول × العرض.' },
          { level: 2, text: '12 × 8 = 96 m².', sentenceAr: '12 × 8 = 96 م².' },
        ],
        skillId: 'rectangle',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm4d1_q1', type: 'numeric_input', prompt: 'Square: side 9 m. Area = ?', promptAr: 'مربع: ضلعه 9 م. المساحة = ؟', correctAnswer: 81 },
        { id: 'm4d1_q2', type: 'numeric_input', prompt: 'Rectangle: 15 m × 4 m. Perimeter = ?', promptAr: 'مستطيل: 15 م × 4 م. المحيط = ؟', correctAnswer: 38 },
        { id: 'm4d1_q3', type: 'choice', prompt: 'Rhombus area using diagonals d1=10, d2=6:', promptAr: 'مساحة معين بالأقطار d1=10, d2=6:', correctAnswer: '30', options: ['30', '60', '16', '80'] },
      ],
    },
  ],
};

// ════════════════════════════════════════════════════════════════════════════
// MISSION 5: ساحة المدينة — مساحة متوازي الأضلاع
// ════════════════════════════════════════════════════════════════════════════
const MISSION_5: MissionDef = {
  conceptKey: 'parallelogram_area',
  cityMission: 'city_square',
  titleAr: 'ساحة المدينة',
  nodeStatus: 'soon',
  scene: {
    text: 'The city square needs paving. We must calculate the area of parallelogram-shaped sections to order the right amount of material.',
    sentenceAr: 'ساحة المدينة تحتاج تبليطاً. يجب حساب مساحة الأقسام على شكل متوازي أضلاع لطلب الكمية الصحيحة من المواد.',
  },
  discovery: {
    instruction: 'Drag the parallelogram to transform it into a rectangle. Observe how the area stays the same.',
    instructionAr: 'اسحب متوازي الأضلاع لتحويله إلى مستطيل. لاحظ كيف تبقى المساحة كما هي.',
  },
  explanation: {
    sentence: 'Area of a parallelogram = base × height. A parallelogram has the same area as a rectangle with the same base and height.',
    sentenceAr: 'مساحة متوازي الأضلاع = القاعدة × الارتفاع. متوازي الأضلاع له نفس مساحة المستطيل بنفس القاعدة والارتفاع.',
  },
  skills: [
    {
      skillId: 'para_area_intro',
      depth: 0,
      title: 'Parallelogram Area: Base × Height',
      titleAr: 'مساحة متوازي الأضلاع: القاعدة × الارتفاع',
      topic: 'Identifying base and height, applying the area formula',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'A parallelogram has the same area as a rectangle when they share:',
          promptAr: 'متوازي أضلاع له نفس مساحة المستطيل عندما يشتركان في:',
          dataJson: { options: ['Same perimeter', 'Same base and height', 'Same side lengths', 'Same angles'] },
          correctAnswerJson: { correctIndex: 1 },
          hintsJson: [
            { level: 1, text: 'The area formula for both is base × height.', sentenceAr: 'قانون المساحة لكليهما: القاعدة × الارتفاع.' },
          ],
          skillId: 'parallelogram_area',
          xpReward: 10,
        },
        {
          activityType: 'drag_drop',
          prompt: 'Label the base and height on the parallelogram diagram.',
          promptAr: 'علّم القاعدة والارتفاع على مخطط متوازي الأضلاع.',
          dataJson: {
            items: [
              { id: 'a', label: 'Base (القاعدة)' },
              { id: 'b', label: 'Height (الارتفاع)' },
            ],
            slots: [
              { id: 's1', label: 'Bottom side', correctItemId: 'a' },
              { id: 's2', label: 'Perpendicular distance', correctItemId: 'b' },
            ],
          },
          correctAnswerJson: { placements: [{ slotId: 's1', itemId: 'a' }, { slotId: 's2', itemId: 'b' }] },
          hintsJson: [
            { level: 1, text: 'Base is the bottom side. Height is the perpendicular distance from base to opposite side.', sentenceAr: 'القاعدة هي الضلع السفلي. الارتفاع هو المسافة العمودية من القاعدة للضلع المقابل.' },
          ],
          skillId: 'parallelogram_area',
          xpReward: 15,
        },
        {
          activityType: 'numeric_input',
          prompt: 'Parallelogram: base = 15 cm, height = 8 cm. Area = ?',
          promptAr: 'متوازي أضلاع: قاعدة = 15 سم، ارتفاع = 8 سم. المساحة = ؟',
          dataJson: {},
          correctAnswerJson: { value: 120 },
          correctionRulesJson: { tolerance: 0, errorPatterns: [{ condition: 'double', label: 'added_instead_of_multiplied' }] },
          hintsJson: [
            { level: 1, text: 'Area = base × height.', sentenceAr: 'المساحة = القاعدة × الارتفاع.' },
            { level: 2, text: '15 × 8 = ?', sentenceAr: '15 × 8 = ؟' },
          ],
          skillId: 'parallelogram_area',
          xpReward: 10,
        },
      ],
      applicationActivity: {
        activityType: 'area_tiles',
        prompt: 'Calculate the glass needed for the parallelogram-shaped window: base 15 cm, height 8 cm.',
        promptAr: 'احسب الزجاج المطلوب لنافذة متوازي الأضلاع: قاعدة 15 سم، ارتفاع 8 سم.',
        dataJson: { base: 15, height: 8, unit: 'cm' },
        correctAnswerJson: { area: 120 },
        correctionRulesJson: { tolerance: 0 },
        hintsJson: [
          { level: 1, text: 'Area = base × height = 15 × 8.', sentenceAr: 'المساحة = القاعدة × الارتفاع = 15 × 8.' },
        ],
        skillId: 'parallelogram_area',
        xpReward: 20,
      },
      checkpointQuestions: [
        { id: 'm5d0_q1', type: 'choice', prompt: 'Area of parallelogram = rectangle with same:', promptAr: 'مساحة متوازي الأضلاع = مستطيل بنفس:', correctAnswer: 'base and height', options: ['Perimeter', 'Base and height', 'Side lengths', 'Diagonals'] },
        { id: 'm5d0_q2', type: 'numeric_input', prompt: 'Base = 200 dm² area, base = 40 dm. Height = ?', promptAr: 'مساحة 200 دم²، قاعدة 40 دم. الارتفاع = ؟', correctAnswer: 5 },
        { id: 'm5d0_q3', type: 'numeric_input', prompt: 'Parallelogram: base 12 m, height 9 m. Area = ?', promptAr: 'متوازي أضلاع: قاعدة 12 م، ارتفاع 9 م. المساحة = ؟', correctAnswer: 108 },
      ],
    },
    {
      skillId: 'para_area_deep',
      depth: 1,
      title: 'Parallelogram Area: Complex Problems',
      titleAr: 'مساحة متوازي الأضلاع: مسائل مركبة',
      topic: 'Finding missing dimensions and real-world applications',
      trainingActivities: [
        {
          activityType: 'numeric_input',
          prompt: 'Parking lot area = 200 m², base = 40 m. Find the height.',
          promptAr: 'مساحة موقف سيارات = 200 م²، القاعدة = 40 م. أوجد الارتفاع.',
          dataJson: {},
          correctAnswerJson: { value: 5 },
          correctionRulesJson: { tolerance: 0, errorPatterns: [{ condition: 'half', label: 'divided_wrong' }] },
          hintsJson: [
            { level: 1, text: 'Height = Area ÷ Base.', sentenceAr: 'الارتفاع = المساحة ÷ القاعدة.' },
            { level: 2, text: '200 ÷ 40 = ?', sentenceAr: '200 ÷ 40 = ؟' },
          ],
          skillId: 'parallelogram_area',
          xpReward: 15,
        },
        {
          activityType: 'numeric_input',
          prompt: 'Rhombus diagonals: d1 = 10 cm, d2 = 6 cm. Area = ?',
          promptAr: 'أقطار معين: d1 = 10 سم، d2 = 6 سم. المساحة = ؟',
          dataJson: {},
          correctAnswerJson: { value: 30 },
          correctionRulesJson: { tolerance: 0, errorPatterns: [{ condition: 'double', label: 'used_wrong_formula' }] },
          hintsJson: [
            { level: 1, text: 'Rhombus area = (d1 × d2) ÷ 2.', sentenceAr: 'مساحة المعين = (d1 × d2) ÷ 2.' },
            { level: 2, text: '(10 × 6) ÷ 2 = 30.', sentenceAr: '(10 × 6) ÷ 2 = 30.' },
          ],
          skillId: 'parallelogram_area',
          xpReward: 15,
        },
      ],
      applicationActivity: {
        activityType: 'area_tiles',
        prompt: 'Tile the city square: a parallelogram area of 96 m² with base 12 m. Verify the height is 8 m, then calculate tile count (each tile = 0.5 m²).',
        promptAr: 'بَلّط ساحة المدينة: مساحة متوازي أضلاع 96 م² وقاعدة 12 م. تحقق أن الارتفاع 8 م، ثم احسب عدد البلاطات (كل بلاطة 0.5 م²).',
        dataJson: { area: 96, tileSize: 0.5 },
        correctAnswerJson: { height: 8, tileCount: 192 },
        correctionRulesJson: { tolerance: 1 },
        hintsJson: [
          { level: 1, text: 'Height = 96 ÷ 12 = 8. Tiles = 96 ÷ 0.5 = 192.', sentenceAr: 'الارتفاع = 96 ÷ 12 = 8. البلاط = 96 ÷ 0.5 = 192.' },
        ],
        skillId: 'parallelogram_area',
        xpReward: 25,
      },
      checkpointQuestions: [
        { id: 'm5d1_q1', type: 'numeric_input', prompt: 'Area = 180 m², height = 12 m. Base = ?', promptAr: 'المساحة = 180 م²، الارتفاع = 12 م. القاعدة = ؟', correctAnswer: 15 },
        { id: 'm5d1_q2', type: 'numeric_input', prompt: 'Rhombus: d1=8, d2=5. Area = ?', promptAr: 'معين: d1=8, d2=5. المساحة = ؟', correctAnswer: 20 },
        { id: 'm5d1_q3', type: 'choice', prompt: 'A common mistake when finding parallelogram area:', promptAr: 'خطأ شائع في حساب مساحة متوازي الأضلاع:', correctAnswer: 'using side length instead of height', options: ['Using base × side', 'Using base × height', 'Adding all sides', 'Using diagonal'] },
      ],
    },
  ],
};

// ════════════════════════════════════════════════════════════════════════════
// MISSION 6: تحدي إنقاذ المدينة — تطبيق يجمع المهارات السابقة
// ════════════════════════════════════════════════════════════════════════════
const MISSION_6: MissionDef = {
  conceptKey: 'combined_challenge',
  cityMission: 'city_rescue',
  titleAr: 'تحدي إنقاذ المدينة',
  nodeStatus: 'soon',
  scene: {
    text: 'The city faces a major crisis! Multiple structures need fixing at once. Apply everything you have learned about lines, angles, parallelograms, and areas to save the city.',
    sentenceAr: 'المدينة تواجه أزمة كبرى! عدة هياكل تحتاج إصلاحاً في وقت واحد. طبّق كل ما تعلمته عن الخطوط والزوايا ومتوازي الأضلاع والمساحات لإنقاذ المدينة.',
  },
  discovery: {
    instruction: 'Explore the city crisis map. Each damaged structure requires knowledge from a different mission.',
    instructionAr: 'استكشف خريطة أزمة المدينة. كل هيكل متضرر يحتاج معرفة من مهمة مختلفة.',
  },
  explanation: {
    sentence: 'Every engineering problem in the city can be solved using the properties of lines, angles, and quadrilaterals you have mastered.',
    sentenceAr: 'كل مشكلة هندسية في المدينة يمكن حلها باستخدام خصائص الخطوط والزوايا والأشكال الرباعية التي أتقنتها.',
  },
  skills: [
    {
      skillId: 'city_rescue',
      depth: 0,
      title: 'City Rescue: Combined Challenge',
      titleAr: 'تحدي إنقاذ المدينة: تطبيق شامل',
      topic: 'Applying all learned skills: parallel lines, angles, parallelograms, area',
      trainingActivities: [
        {
          activityType: 'choice',
          prompt: 'A bridge support is a parallelogram. One angle is 75°. Its opposite angle is:',
          promptAr: 'دعامة جسر على شكل متوازي أضلاع. إحدى زواياه 75°. الزاوية المقابلة:',
          dataJson: { options: ['75°', '105°', '90°', '180°'] },
          correctAnswerJson: { correctIndex: 0 },
          hintsJson: [
            { level: 1, text: 'Opposite angles in a parallelogram are equal.', sentenceAr: 'الزوايا المتقابلة في متوازي الأضلاع متساوية.' },
          ],
          skillId: 'combined',
          xpReward: 10,
        },
        {
          activityType: 'numeric_input',
          prompt: 'Road marking: two parallel roads cut by a transversal at 55°. The corresponding angle on the other road is:',
          promptAr: 'رسم طريق: طريقان متوازيان يقطعهما قاطع بزاوية 55°. الزاوية المناظرة في الطريق الآخر:',
          dataJson: {},
          correctAnswerJson: { value: 55 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Corresponding angles are equal.', sentenceAr: 'الزوايا المناظرة متساوية.' },
          ],
          skillId: 'combined',
          xpReward: 10,
        },
        {
          activityType: 'numeric_input',
          prompt: 'City square tile order: parallelogram base 18 m, height 11 m. Total tiles needed (each 1 m²):',
          promptAr: 'طلب بلاط ساحة المدينة: متوازي أضلاع قاعدته 18 م وارتفاعه 11 م. عدد البلاط المطلوب (كل منها 1 م²):',
          dataJson: {},
          correctAnswerJson: { value: 198 },
          correctionRulesJson: { tolerance: 0 },
          hintsJson: [
            { level: 1, text: 'Area = base × height = 18 × 11.', sentenceAr: 'المساحة = القاعدة × الارتفاع = 18 × 11.' },
            { level: 2, text: '18 × 11 = 198 m² = 198 tiles.', sentenceAr: '18 × 11 = 198 م² = 198 بلاطة.' },
          ],
          skillId: 'combined',
          xpReward: 15,
        },
      ],
      applicationActivity: {
        activityType: 'bridge_builder',
        prompt: 'Final challenge: build the emergency bridge. Set all angles and verify all properties simultaneously. The bridge uses parallel beams (75° cut), parallelogram supports, and square foundations.',
        promptAr: 'التحدي النهائي: ابنِ الجسر الطوارئ. اضبط جميع الزوايا وتحقق من جميع الخصائص في وقت واحد. الجسر يستخدم دعامات متوازية (قطع 75°)، دعامات متوازي أضلاع، وأساسات مربعة.',
        dataJson: {
          constraints: [
            { label: 'Beam cut angle', angle: 75 },
            { label: 'Support adjacent angle', angle: 105 },
            { label: 'Foundation diagonal half', angle: 7 },
          ],
        },
        correctAnswerJson: {
          constraints: [
            { angle: 75 },
            { angle: 105 },
            { angle: 7 },
          ],
        },
        correctionRulesJson: { tolerance: 2, partialCredit: true },
        hintsJson: [
          { level: 1, text: 'Beam angle + adjacent = 180°. Support opposite = same. Foundation = square properties.', sentenceAr: 'زاوية الدعامة + المجاورة = 180°. المقابلة = نفسها. الأساس = خصائص المربع.' },
        ],
        skillId: 'combined',
        xpReward: 30,
      },
      checkpointQuestions: [
        {
          id: 'm6d0_q1',
          type: 'choice',
          prompt: 'A building wall is a rectangle 8m × 5m. Its area is:',
          promptAr: 'جدار مبنى مستطيل 8م × 5م. مساحته:',
          correctAnswer: '40 m²',
          options: ['40 m²', '26 m²', '13 m²', '80 m²'],
        },
        {
          id: 'm6d0_q2',
          type: 'numeric_input',
          prompt: 'Parallel lines cut by transversal: angle = 40°. Alternate interior angle = ?',
          promptAr: 'خطوط متوازية يقطعها قاطع: زاوية = 40°. الزاوية المتبادلة داخلية = ؟',
          correctAnswer: 40,
        },
        {
          id: 'm6d0_q3',
          type: 'choice',
          prompt: 'Square side = 6 m. Diagonal = ? (rounded)',
          promptAr: 'ضلع مربع = 6 م. القطر = ؟ (تقريباً)',
          correctAnswer: '8.5',
          options: ['6', '7.2', '8.5', '12'],
        },
      ],
    },
  ],
};

// ════════════════════════════════════════════════════════════════════════════
// Seed execution
// ════════════════════════════════════════════════════════════════════════════

const ALL_MISSIONS = [MISSION_1, MISSION_2, MISSION_3, MISSION_4, MISSION_5, MISSION_6];

const STAGE_DEFS = [
  { type: 'scene', title: 'Scenario', titleAr: 'الموقف' },
  { type: 'discovery', title: 'Discovery', titleAr: 'الاكتشاف' },
  { type: 'explanation', title: 'Explanation', titleAr: 'الشرح' },
  { type: 'training', title: 'Training', titleAr: 'التدريب' },
  { type: 'application', title: 'City Application', titleAr: 'تطبيق المدينة' },
  { type: 'verification', title: 'Verification', titleAr: 'التحقق' },
] as const;

async function main() {
  const log = { warn: console.warn, info: console.info };
  const store: Store = await createStore(log);

  // Find the learning path
  const allGrades = await store.listGrades();
  let mathSubject: Awaited<ReturnType<typeof store.listSubjects>>[0] | undefined;
  for (const grade of allGrades) {
    if (grade.index === 7) {
      const subjects = await store.listSubjects(grade.id);
      mathSubject = subjects.find((s) => s.title === 'Mathematics');
      break;
    }
  }
  if (!mathSubject) {
    console.error('ERROR: Could not find Grade 7 Mathematics subject');
    process.exit(1);
  }

  const paths = await store.listLearningPaths(mathSubject.id);
  const cityPath = paths.find((p) => p.name === 'مدينة لا تنهار');
  if (!cityPath) {
    console.error('ERROR: Learning path "مدينة لا تنهار" not found. Run the main seed first.');
    process.exit(1);
  }

  console.log(`Found path: ${cityPath.name} (${cityPath.id})`);
  console.log(`Total missions to seed: ${ALL_MISSIONS.length}`);
  console.log('');

  const existingNodes = await store.listPathNodes(cityPath.id);

  for (let mi = 0; mi < ALL_MISSIONS.length; mi++) {
    const mission = ALL_MISSIONS[mi]!;
    console.log(`\n═══ Mission ${mi + 1}: ${mission.titleAr} (${mission.conceptKey}) ═══`);

    for (const skill of mission.skills) {
      // Find or create the node for this skill
      let node = existingNodes.find(
        (n) =>
          n.depth === skill.depth &&
          (n.title === skill.title || n.titleAr === skill.titleAr),
      );

      if (!node) {
        // Create new node
        node = await store.createPathNode({
          title: skill.title,
          titleAr: skill.titleAr,
          subject: 'Mathematics',
          topic: skill.topic,
          orderIndex: existingNodes.length,
          xpReward: skill.depth === 0 ? 20 : 30,
          depth: skill.depth,
          learningPathId: cityPath.id,
          conceptKey: mission.conceptKey,
          cityMission: mission.cityMission,
          nodeStatus: mission.nodeStatus,
          sceneJson: { text: mission.scene.text, sentenceAr: mission.scene.sentenceAr },
          discoveryJson: { instruction: mission.discovery.instruction, instructionAr: mission.discovery.instructionAr },
          explanationJson: { sentence: mission.explanation.sentence, sentenceAr: mission.explanation.sentenceAr },
        });
        existingNodes.push(node);
        console.log(`  Created new node: ${skill.titleAr}`);
      } else {
        // Update existing node with city fields
        await store.updatePathNode(node.id, {
          conceptKey: mission.conceptKey,
          cityMission: mission.cityMission,
          titleAr: skill.titleAr,
          nodeStatus: mission.nodeStatus,
          sceneJson: { text: mission.scene.text, sentenceAr: mission.scene.sentenceAr },
          discoveryJson: { instruction: mission.discovery.instruction, instructionAr: mission.discovery.instructionAr },
          explanationJson: { sentence: mission.explanation.sentence, sentenceAr: mission.explanation.sentenceAr },
        });
        console.log(`  Updated existing node: ${skill.titleAr}`);
      }

      // Check if stages already exist
      const existingStages = await store.listPathNodeStages(node.id);
      if (existingStages.length >= 6) {
        console.log(`    Stages already exist (${existingStages.length}) — skipping`);
      } else {
        // Create 6 stages
        for (let si = 0; si < STAGE_DEFS.length; si++) {
          const sd = STAGE_DEFS[si]!;
          await store.createPathNodeStage({
            pathNodeId: node.id,
            stageType: sd.type,
            orderIndex: si,
            title: sd.title,
            titleAr: sd.titleAr,
            contentJson: buildStageContent(sd.type, mission, skill, si),
          });
        }
        console.log(`    Created 6 stages`);
      }

      // Check if activities already exist
      const existingActivities = await store.listPathNodeActivities(node.id);
      if (existingActivities.length > 0) {
        console.log(`    Activities already exist (${existingActivities.length}) — skipping`);
      } else {
        // Create training activities (stages 3 = training)
        const trainingStage = (await store.listPathNodeStages(node.id)).find((s) => s.stageType === 'training');
        for (let ai = 0; ai < skill.trainingActivities.length; ai++) {
          const act = skill.trainingActivities[ai]!;
          await store.createPathNodeActivity({
            pathNodeId: node.id,
            stageId: trainingStage?.id ?? null,
            orderIndex: ai,
            activityType: act.activityType,
            prompt: act.prompt,
            promptAr: act.promptAr,
            dataJson: act.dataJson,
            correctAnswerJson: act.correctAnswerJson,
            correctionRulesJson: act.correctionRulesJson ?? null,
            hintsJson: act.hintsJson,
            skillId: act.skillId ?? null,
            xpReward: act.xpReward ?? 10,
          });
        }

        // Create application activity (stage 4 = application)
        const appStage = (await store.listPathNodeStages(node.id)).find((s) => s.stageType === 'application');
        const appAct = skill.applicationActivity;
        await store.createPathNodeActivity({
          pathNodeId: node.id,
          stageId: appStage?.id ?? null,
          orderIndex: 0,
          activityType: appAct.activityType,
          prompt: appAct.prompt,
          promptAr: appAct.promptAr,
          dataJson: appAct.dataJson,
          correctAnswerJson: appAct.correctAnswerJson,
          correctionRulesJson: appAct.correctionRulesJson ?? null,
          hintsJson: appAct.hintsJson,
          skillId: appAct.skillId ?? null,
          xpReward: appAct.xpReward ?? 20,
        });

        console.log(`    Created ${skill.trainingActivities.length + 1} activities`);
      }

      // Check if checkpoint already exists
      const existingCheckpoints = await store.listPathNodeCheckpoints(node.id);
      if (existingCheckpoints.length > 0) {
        console.log(`    Checkpoint already exists — skipping`);
      } else {
        // Create checkpoint with verification questions
        const questions = skill.checkpointQuestions.map((q) => ({
          id: q.id,
          type: q.type,
          prompt: q.prompt,
          promptAr: q.promptAr,
          correctAnswer: q.correctAnswer,
          options: q.options,
          errorPatterns: q.errorPatterns,
        }));

        await store.createPathNodeCheckpoint({
          pathNodeId: node.id,
          orderIndex: 0,
          title: `Mission ${mi + 1} Checkpoint`,
          titleAr: `تحقق المهمة ${mi + 1}`,
          questionsJson: questions as unknown as Array<Record<string, unknown>>,
          passThreshold: 0.7,
          xpReward: 50,
        });
        console.log(`    Created checkpoint with ${questions.length} questions`);
      }
    }
  }

  console.log('\n--- seed_city_content complete ---');
  console.log(`Seeded ${ALL_MISSIONS.length} missions with full learning content`);
  console.log('Each mission has: 6 stages, training + application activities, and a checkpoint');
  process.exit(0);
}

function buildStageContent(
  stageType: string,
  mission: MissionDef,
  skill: MissionSkill,
  stageIndex: number,
): Record<string, unknown> {
  switch (stageType) {
    case 'scene':
      return {
        text: mission.scene.text,
        sentenceAr: mission.scene.sentenceAr,
        image: null,
      };
    case 'discovery':
      return {
        instruction: mission.discovery.instruction,
        instructionAr: mission.discovery.instructionAr,
        interactive: true,
      };
    case 'explanation':
      return {
        sentence: mission.explanation.sentence,
        sentenceAr: mission.explanation.sentenceAr,
        diagramRef: null,
      };
    case 'training':
      return {
        activityCount: skill.trainingActivities.length,
        skillId: skill.skillId,
      };
    case 'application':
      return {
        activityCount: 1,
        context: mission.cityMission,
      };
    case 'verification':
      return {
        questionCount: skill.checkpointQuestions.length,
        noHelpOnFirstAttempt: true,
        passThreshold: 0.7,
      };
    default:
      return {};
  }
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});