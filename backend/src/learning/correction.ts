/**
 * Server-side correction engine for the Unshakable City learning path.
 * Pure functions — no I/O, no side effects. The server is the SINGLE source
 * of truth for grading. The client and Hudhud NEVER determine correctness.
 */

export interface CorrectionResult {
  outcome: 'correct' | 'partially_correct' | 'incorrect';
  errorPattern: string | null;
  score: number; // 0.0 - 1.0
}

export interface CorrectionRules {
  tolerance?: number;
  partialCredit?: boolean;
  errorPatterns?: Array<{
    condition: string; // description of the error condition
    label: string;     // e.g. "confused_supplementary_complementary"
  }>;
}

export interface CheckpointQuestion {
  id: string;
  type: string;
  prompt: string;
  promptAr?: string;
  correctAnswer: unknown;
  errorPatterns?: Array<{ condition: string; label: string }>;
}

/**
 * Grade a single activity attempt.
 * Dispatches by activityType to the appropriate comparison logic.
 */
export function gradeActivity(
  studentAnswer: Record<string, unknown>,
  correctAnswer: Record<string, unknown>,
  rules: CorrectionRules | null,
  activityType: string,
): CorrectionResult {
  const tolerance = rules?.tolerance ?? 0;

  switch (activityType) {
    case 'numeric_input':
      return gradeNumeric(studentAnswer, correctAnswer, tolerance, rules);
    case 'choice':
      return gradeChoice(studentAnswer, correctAnswer, rules);
    case 'angle_explorer':
      return gradeAngleExplorer(studentAnswer, correctAnswer, tolerance, rules);
    case 'shape_compare':
      return gradeShapeCompare(studentAnswer, correctAnswer, rules);
    case 'bridge_builder':
      return gradeBridgeBuilder(studentAnswer, correctAnswer, tolerance, rules);
    case 'area_tiles':
      return gradeNumeric(studentAnswer, correctAnswer, tolerance, rules);
    case 'drag_drop':
      return gradeDragDrop(studentAnswer, correctAnswer, rules);
    default:
      return gradeExact(studentAnswer, correctAnswer, rules);
  }
}

/**
 * Grade a single checkpoint question.
 */
export function gradeCheckpointQuestion(
  studentAnswer: Record<string, unknown>,
  question: CheckpointQuestion,
): { correct: boolean; errorPattern: string | null } {
  const result = gradeActivity(
    studentAnswer,
    question.correctAnswer as Record<string, unknown>,
    null,
    question.type,
  );
  return {
    correct: result.outcome === 'correct',
    errorPattern: result.errorPattern,
  };
}

// ─── Internal graders ─────────────────────────────────────────────────────────

function gradeNumeric(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  tolerance: number,
  rules: CorrectionRules | null,
): CorrectionResult {
  const studentVal = Number(student.value ?? student.answer ?? 0);
  const correctVal = Number(correct.value ?? correct.answer ?? 0);
  const diff = Math.abs(studentVal - correctVal);

  if (diff <= tolerance) {
    return { outcome: 'correct', errorPattern: null, score: 1.0 };
  }

  const errorPattern = diagnoseNumericError(studentVal, correctVal, rules);
  return { outcome: 'incorrect', errorPattern, score: 0 };
}

function gradeChoice(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  rules: CorrectionRules | null,
): CorrectionResult {
  const studentIdx = Number(student.selectedIndex ?? student.index ?? -1);
  const correctIdx = Number(correct.correctIndex ?? correct.selectedIndex ?? -1);

  if (studentIdx === correctIdx) {
    return { outcome: 'correct', errorPattern: null, score: 1.0 };
  }

  const errorPattern = rules?.errorPatterns?.[0]?.label ?? 'concept_misunderstanding';
  return { outcome: 'incorrect', errorPattern, score: 0 };
}

function gradeAngleExplorer(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  tolerance: number,
  rules: CorrectionRules | null,
): CorrectionResult {
  // Compare each angle value the student identified
  const studentAngles = (student.angles ?? {}) as Record<string, number>;
  const correctAngles = (correct.angles ?? {}) as Record<string, number>;
  const keys = Object.keys(correctAngles);

  if (keys.length === 0) {
    return { outcome: 'correct', errorPattern: null, score: 1.0 };
  }

  let correctCount = 0;
  for (const key of keys) {
    const s = Number(studentAngles[key] ?? NaN);
    const c = Number(correctAngles[key]);
    if (Math.abs(s - c) <= tolerance) correctCount++;
  }

  const ratio = correctCount / keys.length;
  if (ratio === 1) return { outcome: 'correct', errorPattern: null, score: 1.0 };
  if (ratio >= 0.5 && rules?.partialCredit) {
    return { outcome: 'partially_correct', errorPattern: 'calculation_slip', score: ratio };
  }

  const errorPattern = diagnoseAngleError(studentAngles, correctAngles, rules);
  return { outcome: 'incorrect', errorPattern, score: ratio };
}

function gradeShapeCompare(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  rules: CorrectionRules | null,
): CorrectionResult {
  const studentProps = (student.properties ?? {}) as Record<string, unknown>;
  const correctProps = (correct.properties ?? {}) as Record<string, unknown>;
  const keys = Object.keys(correctProps);

  if (keys.length === 0) return { outcome: 'correct', errorPattern: null, score: 1.0 };

  let matchCount = 0;
  for (const key of keys) {
    if (JSON.stringify(studentProps[key]) === JSON.stringify(correctProps[key])) matchCount++;
  }

  const ratio = matchCount / keys.length;
  if (ratio === 1) return { outcome: 'correct', errorPattern: null, score: 1.0 };
  if (ratio >= 0.5 && rules?.partialCredit) {
    return { outcome: 'partially_correct', errorPattern: 'representation_confusion', score: ratio };
  }
  return { outcome: 'incorrect', errorPattern: 'concept_misunderstanding', score: ratio };
}

function gradeBridgeBuilder(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  tolerance: number,
  rules: CorrectionRules | null,
): CorrectionResult {
  // Check that parallel constraints are satisfied
  const studentConstraints = (student.constraints ?? []) as Array<{ angle: number }>;
  const correctConstraints = (correct.constraints ?? []) as Array<{ angle: number }>;

  if (correctConstraints.length === 0) return { outcome: 'correct', errorPattern: null, score: 1.0 };

  let satisfied = 0;
  for (let i = 0; i < correctConstraints.length; i++) {
    const s = Number(studentConstraints[i]?.angle ?? NaN);
    const c = Number(correctConstraints[i]?.angle);
    if (Math.abs(s - c) <= tolerance) satisfied++;
  }

  const ratio = satisfied / correctConstraints.length;
  if (ratio === 1) return { outcome: 'correct', errorPattern: null, score: 1.0 };
  return { outcome: 'incorrect', errorPattern: 'procedural_error', score: ratio };
}

function gradeDragDrop(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  rules: CorrectionRules | null,
): CorrectionResult {
  const studentPlacements = (student.placements ?? []) as Array<{ slotId: string; itemId: string }>;
  const correctPlacements = (correct.placements ?? correct.slots ?? []) as Array<{ slotId?: string; id?: string; correctItemId: string }>;

  if (correctPlacements.length === 0) return { outcome: 'correct', errorPattern: null, score: 1.0 };

  let correctCount = 0;
  for (const cp of correctPlacements) {
    const slotId = cp.slotId ?? cp.id ?? '';
    const match = studentPlacements.find((sp) => sp.slotId === slotId);
    if (match && match.itemId === cp.correctItemId) correctCount++;
  }

  const ratio = correctCount / correctPlacements.length;
  if (ratio === 1) return { outcome: 'correct', errorPattern: null, score: 1.0 };
  if (ratio >= 0.5 && rules?.partialCredit) {
    return { outcome: 'partially_correct', errorPattern: 'representation_confusion', score: ratio };
  }
  return { outcome: 'incorrect', errorPattern: 'concept_misunderstanding', score: ratio };
}

function gradeExact(
  student: Record<string, unknown>,
  correct: Record<string, unknown>,
  rules: CorrectionRules | null,
): CorrectionResult {
  const match = JSON.stringify(student) === JSON.stringify(correct);
  if (match) return { outcome: 'correct', errorPattern: null, score: 1.0 };
  return { outcome: 'incorrect', errorPattern: 'concept_misunderstanding', score: 0 };
}

// ─── Error diagnosis helpers ──────────────────────────────────────────────────

function diagnoseNumericError(
  studentVal: number,
  correctVal: number,
  rules: CorrectionRules | null,
): string {
  // Check if it's a common error pattern
  if (rules?.errorPatterns) {
    for (const ep of rules.errorPatterns) {
      // e.g. condition: "student_answer === correct_answer * 2" → forgot to divide
      if (ep.condition === 'double' && Math.abs(studentVal - correctVal * 2) < 0.01) return ep.label;
      if (ep.condition === 'half' && Math.abs(studentVal - correctVal / 2) < 0.01) return ep.label;
      if (ep.condition === 'supplement_confusion' && Math.abs(studentVal - (180 - correctVal)) < 0.01) return ep.label;
      if (ep.condition === 'complement_confusion' && Math.abs(studentVal - (90 - correctVal)) < 0.01) return ep.label;
    }
  }
  // Default: arithmetic slip if close, concept error if far
  const relDiff = Math.abs(studentVal - correctVal) / (Math.abs(correctVal) || 1);
  return relDiff < 0.15 ? 'calculation_slip' : 'concept_misunderstanding';
}

function diagnoseAngleError(
  studentAngles: Record<string, number>,
  correctAngles: Record<string, number>,
  rules: CorrectionRules | null,
): string {
  // Check for supplementary/complementary confusion
  const keys = Object.keys(correctAngles);
  let supplementConfusions = 0;
  for (const key of keys) {
    const s = Number(studentAngles[key] ?? NaN);
    const c = Number(correctAngles[key]);
    if (Math.abs(s - (180 - c)) < 1) supplementConfusions++;
  }
  if (supplementConfusions > 0 && supplementConfusions >= keys.length / 2) {
    return 'confused_supplementary_complementary';
  }
  return 'concept_misunderstanding';
}