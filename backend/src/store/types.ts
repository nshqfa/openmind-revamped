/**
 * Storage abstraction: PrismaStore (Postgres 16) when DATABASE_URL is set,
 * MemoryStore otherwise so `npm run dev` always works with zero setup.
 * Same interface, same semantics; memory data dies with the process (logged loudly).
 */
import type { GameSpec } from '@edumind/shared';

export interface StudentRow {
  id: string;
  name: string;
  gender: string | null;
  grade: number;
  language: string;
  color: string;
  /** Elementary game-engine archetype (primary stage). */
  interest: string | null;
  /** Middle-school context lens (middle stage) — legacy; fallback only when interests is empty. */
  learningContext: string | null;
  /** Personal interests chosen at onboarding (1-2, both stages) — the primary AI-flavor signal. */
  interests: string[];
  dailyGoal: number;
  xp: number;
  streakCount: number;
  streakLastPlayedAt: Date | null;
  tokenHash: string;
  /** Client-generated per-install idempotency key for POST /students — see routes/students.ts. */
  installationId: string | null;
  createdAt: Date;
}

export type GameStatus = 'generating' | 'ready' | 'failed';

export interface GameRow {
  id: string;
  studentId: string;
  gameType: string;
  theme: string;
  subject: string;
  topic: string;
  language: string;
  status: GameStatus;
  error: string | null;
  spec: GameSpec | null;
  shellVersion: string;
  thumbnailUrl: string | null;
  bestScore: number;
  playCount: number;
  lastPlayedAt: Date | null;
  createdAt: Date;
  deletedAt: Date | null;
}

export interface PlaySessionRow {
  id: string;
  gameId: string | null; // null for Review-mode sessions
  studentId: string;
  summary: Record<string, unknown>;
  xp: number;
  accuracy: number;
  createdAt: Date;
}

export interface XpEventRow {
  id: string;
  studentId: string;
  amount: number;
  reason: string;
  createdAt: Date;
}

export interface GradeRow {
  id: string;
  name: string;
  index: number;
  createdAt: Date;
}

export interface SubjectRow {
  id: string;
  title: string;
  content: string;
  orderIndex: number;
  gradeId: string;
  createdAt: Date;
}

export interface LearningPathRow {
  id: string;
  name: string;
  description: string;
  subjectId: string;
  createdAt: Date;
}

export interface PathNodeRow {
  id: string;
  title: string;
  subject: string;
  topic: string;
  orderIndex: number;
  xpReward: number;
  depth: number; // spiral depth: 0=basic, 1=deepen, 2=mastery
  learningPathId: string;
  conceptKey?: string | null;
  cityMission?: string | null;
  nodeStatus?: string;  // "available" | "in_progress" | "completed" | "soon"
  sceneJson?: Record<string, unknown> | null;
  discoveryJson?: Record<string, unknown> | null;
  explanationJson?: Record<string, unknown> | null;
  titleAr?: string | null;
  createdAt: Date;
}

// Subject with its nested learning paths (used by read-through endpoints).
export interface SubjectWithPaths extends SubjectRow {
  learningPaths: LearningPathRow[];
}

// Learning path with its nested path nodes (used by read-through endpoints).
export interface LearningPathWithNodes extends LearningPathRow {
  pathNodes: PathNodeRow[];
}


// ─── Placement-test rows ─────────────────────────────────────────────────────

export type QuestionType = 'choice' | 'drag_drop' | 'spin' | 'connect' | 'numeric_input' | 'tap_image' | 'open_response';
export type QuestionDifficulty = 'intro' | 'basic' | 'intermediate' | 'advanced' | 'mastery';
export type PlacementTheme = 'bridge' | 'road' | 'map';
export type PlacementTestStatus = 'in_progress' | 'completed' | 'abandoned';

export interface QuestionRow {
  id: string;
  learningPathId: string;
  type: QuestionType;
  difficulty: QuestionDifficulty;
  content: Record<string, unknown>; // type-specific payload
  linkedNodeId: string | null;
  createdAt: Date;
}

export interface PlacementAnswer {
  questionId: string;
  type: QuestionType;
  difficulty: QuestionDifficulty;
  correct: boolean;
  response: Record<string, unknown>;
  answeredAt: string; // ISO
}

export interface PlacementTestSessionRow {
  id: string;
  studentId: string;
  learningPathId: string;
  theme: PlacementTheme;
  status: PlacementTestStatus;
  answers: PlacementAnswer[];
  currentDifficulty: QuestionDifficulty;
  questionCount: number;
  placedNodeId: string | null;
  startedAt: Date;
  completedAt: Date | null;
}

/**
 * One completed middle-school learning experience. A separate progress domain
 * from games/PlaySession on purpose: primary game history and middle-school
 * learning journeys never overwrite each other.
 */
export interface LearnProgressRow {
  id: string;
  studentId: string;
  pathId: string;
  experienceId: string;
  completedAt: Date;
}

/**
 * One learner submission — the generalized LearningSignal, one small
 * append-only row per attempt. Readiness is DERIVED from these (per skill ×
 * representation × context), never stored. `id` is client-generated so the
 * log is idempotent across the local cap, the batch upsert, and two-way sync.
 * A separate domain from completion: evidence never overwrites LearnProgress.
 */
export interface LearnEvidenceRow {
  id: string;
  studentId: string;
  skillId: string;
  representation: string;
  /** Lens id (market, water_energy…) or null. */
  context: string | null;
  source: string; // learn_step | checkpoint | tutor_block | tool_verify
  kind: string; // exploration | prediction | construction | transfer | recall | explanation
  outcome: string; // correct | partially_correct | incorrect | explored
  verification: string; // server_verified | client_reported
  attempt: number;
  hints: number;
  recovered: boolean;
  errorPattern: string | null;
  toolId: string | null;
  pathId: string | null;
  experienceId: string | null;
  stepIndex: number | null;
  /** Time-on-task; never interpreted alone (see readiness derivation). */
  ms: number | null;
  createdAt: Date;
}

/** Client-authored evidence, id + createdAt included (both come from the client). */
export type LearnEvidenceInput = Omit<LearnEvidenceRow, 'studentId'>;

/** One turn of a tutor conversation (Ask OpenMind / in-experience help). */
export interface TutorMessageRow {
  id: string;
  studentId: string;
  conversationId: string;
  role: 'student' | 'tutor';
  content: string;
  /** Tutor turns: responseType of the structured reply. */
  responseType: string | null;
  /** Learning context attached to the turn (subject, experience, step…). */
  context: Record<string, unknown> | null;
  createdAt: Date;
}

// ─── Unshakable City: PathNode engine rows ───────────────────────────────────

export interface PathNodeStageRow {
  id: string;
  pathNodeId: string;
  stageType: string;
  orderIndex: number;
  title: string;
  titleAr: string | null;
  contentJson: Record<string, unknown> | null;
  createdAt: Date;
}

export interface PathNodeActivityRow {
  id: string;
  pathNodeId: string;
  stageId: string | null;
  orderIndex: number;
  activityType: string;
  prompt: string;
  promptAr: string | null;
  dataJson: Record<string, unknown>;
  correctAnswerJson: Record<string, unknown>;
  correctionRulesJson: Record<string, unknown> | null;
  hintsJson: Array<{ level: number; text: string; textAr?: string }> | null;
  skillId: string | null;
  xpReward: number;
  createdAt: Date;
}

export interface PathNodeCheckpointRow {
  id: string;
  pathNodeId: string;
  orderIndex: number;
  title: string;
  titleAr: string | null;
  questionsJson: Array<Record<string, unknown>>;
  passThreshold: number;
  xpReward: number;
  createdAt: Date;
}

export interface LearnNodeProgressRow {
  id: string;
  studentId: string;
  pathNodeId: string;
  learningPathId: string;
  currentStageIndex: number;
  status: string; // locked | available | in_progress | completed
  checkpointScore: number | null;
  checkpointPassed: boolean;
  completedAt: Date | null;
  attemptsCount: number;
  hintsUsed: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface LearnAttemptRow {
  id: string;
  studentId: string;
  activityId: string;
  pathNodeId: string;
  attemptNumber: number;
  answerJson: Record<string, unknown>;
  outcome: string;
  errorPattern: string | null;
  hintsUsedBefore: number;
  timeMs: number | null;
  recovered: boolean;
  createdAt: Date;
}

export interface LearnCheckpointSubmissionRow {
  id: string;
  studentId: string;
  checkpointId: string;
  pathNodeId: string;
  answersJson: Array<Record<string, unknown>>;
  score: number;
  passed: boolean;
  attemptNumber: number;
  createdAt: Date;
}

export interface Store {
  kind: 'memory' | 'prisma';
  ping(): Promise<boolean>;

  createStudent(data: Omit<StudentRow, 'id' | 'createdAt' | 'xp' | 'streakCount' | 'streakLastPlayedAt'>): Promise<StudentRow>;
  getStudentByToken(tokenHash: string): Promise<StudentRow | null>;
  getStudent(id: string): Promise<StudentRow | null>;
  /** Idempotent-retry lookup for POST /students — see routes/students.ts. */
  getStudentByInstallationId(installationId: string): Promise<StudentRow | null>;
  updateStudent(id: string, patch: Partial<Pick<StudentRow, 'name' | 'color' | 'interest' | 'learningContext' | 'interests' | 'language' | 'dailyGoal' | 'grade' | 'gender' | 'xp' | 'streakCount' | 'streakLastPlayedAt' | 'tokenHash'>>): Promise<StudentRow>;

  createGame(data: Omit<GameRow, 'createdAt' | 'deletedAt' | 'bestScore' | 'playCount' | 'lastPlayedAt'>): Promise<GameRow>;
  getGame(id: string): Promise<GameRow | null>;
  updateGame(id: string, patch: Partial<Omit<GameRow, 'id' | 'studentId' | 'createdAt'>>): Promise<GameRow>;
  listGames(studentId: string, opts: { limit: number; offset: number }): Promise<{ items: GameRow[]; total: number }>;

  createPlaySession(data: Omit<PlaySessionRow, 'id' | 'createdAt'>): Promise<PlaySessionRow>;
  recentPlaySessions(studentId: string, limit: number): Promise<PlaySessionRow[]>;
  playSessionsSince(studentId: string, since: Date): Promise<PlaySessionRow[]>;

  /** Idempotent completion upsert; `created` is false when it was already recorded. */
  upsertLearnProgress(studentId: string, pathId: string, experienceId: string): Promise<{ row: LearnProgressRow; created: boolean }>;
  listLearnProgress(studentId: string): Promise<LearnProgressRow[]>;

  /** Idempotent batch append of evidence, deduped by client-generated id. */
  upsertLearnEvidence(studentId: string, events: LearnEvidenceInput[]): Promise<{ accepted: number }>;
  listLearnEvidence(studentId: string, since?: Date): Promise<LearnEvidenceRow[]>;

  createTutorMessage(data: Omit<TutorMessageRow, 'id' | 'createdAt'>): Promise<TutorMessageRow>;
  /** Messages of one conversation, oldest first (capped at limit, newest kept). */
  listTutorMessages(studentId: string, conversationId: string, limit: number): Promise<TutorMessageRow[]>;

  addXpEvent(studentId: string, amount: number, reason: string): Promise<XpEventRow>;
  listXpEvents(studentId: string, limit: number): Promise<XpEventRow[]>;
  addStreakDay(studentId: string, day: Date): Promise<boolean>; // false if already recorded

  cacheGet(key: string): Promise<Record<string, unknown> | null>;
  cacheSet(key: string, content: Record<string, unknown>, ttlMs: number): Promise<void>;

  //grade
  createGrade(data: Omit<GradeRow, 'id' | 'createdAt'>): Promise<GradeRow>;
  getGrade(id: string): Promise<GradeRow | null>;
  getGradeByIndex(index: number): Promise<GradeRow | null>;
  listGrades(): Promise<GradeRow[]>;
  updateGrade(id: string, patch: Partial<Pick<GradeRow, 'name' | 'index'>>): Promise<GradeRow>;
  deleteGrade(id: string): Promise<void>;

  // Subjects
  createSubject(data: Omit<SubjectRow, 'id' | 'createdAt'>): Promise<SubjectRow>;
  getSubject(id: string): Promise<SubjectRow | null>;
  getSubjectWithPaths(id: string): Promise<SubjectWithPaths | null>;
  listSubjects(gradeId: string): Promise<SubjectRow[]>;
  listSubjectsWithPaths(gradeId: string): Promise<SubjectWithPaths[]>;
  updateSubject(id: string, patch: Partial<Omit<SubjectRow, 'id' | 'gradeId' | 'createdAt'>>): Promise<SubjectRow>;
  deleteSubject(id: string): Promise<void>;

  // Learning paths
  createLearningPath(data: Omit<LearningPathRow, 'id' | 'createdAt'>): Promise<LearningPathRow>;
  getLearningPath(id: string): Promise<LearningPathRow | null>;
  getLearningPathWithNodes(id: string): Promise<LearningPathWithNodes | null>;
  listLearningPaths(subjectId: string): Promise<LearningPathRow[]>;
  updateLearningPath(id: string, patch: Partial<Omit<LearningPathRow, 'id' | 'subjectId' | 'createdAt'>>): Promise<LearningPathRow>;
  deleteLearningPath(id: string): Promise<void>;

  // Path nodes
  createPathNode(data: Omit<PathNodeRow, 'id' | 'createdAt'>): Promise<PathNodeRow>;
  getPathNode(id: string): Promise<PathNodeRow | null>;
  listPathNodes(learningPathId: string): Promise<PathNodeRow[]>;
  updatePathNode(id: string, patch: Partial<Omit<PathNodeRow, 'id' | 'learningPathId' | 'createdAt'>>): Promise<PathNodeRow>;
  deletePathNode(id: string): Promise<void>;

  // ─── Question bank (per learning path) ──────────────────────────────────
  createQuestion(data: Omit<QuestionRow, 'id' | 'createdAt'>): Promise<QuestionRow>;
  getQuestion(id: string): Promise<QuestionRow | null>;
  listQuestions(learningPathId: string, difficulty?: QuestionDifficulty): Promise<QuestionRow[]>;
  updateQuestion(id: string, patch: Partial<Omit<QuestionRow, 'id' | 'learningPathId' | 'createdAt'>>): Promise<QuestionRow>;
  deleteQuestion(id: string): Promise<void>;

  // ─── Placement test sessions ────────────────────────────────────────────
  createPlacementTest(data: Omit<PlacementTestSessionRow, 'id' | 'startedAt' | 'completedAt' | 'answers' | 'currentDifficulty' | 'questionCount' | 'placedNodeId' | 'status'>): Promise<PlacementTestSessionRow>;
  getPlacementTest(id: string): Promise<PlacementTestSessionRow | null>;
  getActivePlacementTest(studentId: string, learningPathId: string): Promise<PlacementTestSessionRow | null>;
  listPlacementTestsByStudent(studentId: string): Promise<PlacementTestSessionRow[]>;
  updatePlacementTest(id: string, patch: Partial<Omit<PlacementTestSessionRow, 'id' | 'studentId' | 'learningPathId' | 'startedAt'>>): Promise<PlacementTestSessionRow>;

    // ─── Unshakable City: PathNode learning engine ──────────────────────────

  // Node progress
  getOrCreateNodeProgress(studentId: string, pathNodeId: string, learningPathId: string): Promise<LearnNodeProgressRow>;
  listNodeProgress(studentId: string, learningPathId: string): Promise<LearnNodeProgressRow[]>;
  updateNodeProgress(id: string, patch: Partial<Pick<LearnNodeProgressRow, 'currentStageIndex' | 'status' | 'checkpointScore' | 'checkpointPassed' | 'completedAt' | 'attemptsCount' | 'hintsUsed'>>): Promise<LearnNodeProgressRow>;
  initializePathProgress(studentId: string, learningPathId: string, pathNodeIds: string[]): Promise<void>;

  // Stages
  listPathNodeStages(pathNodeId: string): Promise<PathNodeStageRow[]>;

  // Activities
  listPathNodeActivities(pathNodeId: string): Promise<PathNodeActivityRow[]>;
  getPathNodeActivity(activityId: string): Promise<PathNodeActivityRow | null>;

  // Checkpoints
  listPathNodeCheckpoints(pathNodeId: string): Promise<PathNodeCheckpointRow[]>;
  getPathNodeCheckpoint(checkpointId: string): Promise<PathNodeCheckpointRow | null>;

  // Stages (create)
  createPathNodeStage(data: Omit<PathNodeStageRow, 'id' | 'createdAt'>): Promise<PathNodeStageRow>;

  // Activities (create)
  createPathNodeActivity(data: Omit<PathNodeActivityRow, 'id' | 'createdAt'>): Promise<PathNodeActivityRow>;

  // Checkpoints (create)
  createPathNodeCheckpoint(data: Omit<PathNodeCheckpointRow, 'id' | 'createdAt'>): Promise<PathNodeCheckpointRow>;

  // Attempts
  createLearnAttempt(data: Omit<LearnAttemptRow, 'id' | 'createdAt'>): Promise<LearnAttemptRow>;
  countLearnAttempts(studentId: string, activityId: string): Promise<number>;
  listLearnAttempts(studentId: string, pathNodeId: string): Promise<LearnAttemptRow[]>;

  // Checkpoint submissions
  createCheckpointSubmission(data: Omit<LearnCheckpointSubmissionRow, 'id' | 'createdAt'>): Promise<LearnCheckpointSubmissionRow>;
  countCheckpointSubmissions(studentId: string, checkpointId: string): Promise<number>;

}
