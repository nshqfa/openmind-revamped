

/**
 * Middle-school learning-progress routes — the backend half of the client's
 * LearnProgressStore. Local storage stays the instant offline source; these
 * endpoints make completion survive reinstalls and travel across devices.
 * Progress lives in its own domain (LearnProgress), never mixed with games.
 *
 * UNSHAKABLE CITY ADDITION: PathNode-level progression with server-verified
 * attempts, checkpoint gating, and hint delivery. The server is the SINGLE
 * source of truth for completion — the client CANNOT mark a node complete.
 */
import type { FastifyInstance } from 'fastify';
import { makeAuthHook } from '../auth.js';
import {
  PostLearnEvidenceBody,
  PutLearnProgressBody,
  PutStageProgressBody,
  PostActivityAttemptBody,
  PostCheckpointSubmitBody,
} from '../schemas.js';
import type { LearnEvidenceInput, Store } from '../store/types.js';
import { gradeActivity, gradeCheckpointQuestion } from '../learning/correction.js';
import type { CorrectionRules, CheckpointQuestion } from '../learning/correction.js';
import {
  advanceStage,
  nextStatusOnInteraction,
  xpMultiplier,
  hintLevel,
  checkpointPasses,
} from '../learning/progression.js';

export async function learnRoutes(app: FastifyInstance, opts: { store: Store }) {
  const { store } = opts;
  const auth = makeAuthHook(store);

  // ─── EXISTING: experience-level progress (kept for backward compat) ────────

  app.get('/api/v1/learn/progress', { preHandler: auth }, async (req) => {
    const rows = await store.listLearnProgress(req.student!.id);
    return {
      items: rows.map((r) => ({
        pathId: r.pathId,
        experienceId: r.experienceId,
        completedAt: r.completedAt.toISOString(),
      })),
      total: rows.length,
    };
  });

  app.put('/api/v1/learn/progress', { preHandler: auth }, async (req, reply) => {
    const parsed = PutLearnProgressBody.safeParse(req.body);
    if (!parsed.success) {
      return reply.code(400).send({
        error: { code: 'BAD_REQUEST', message: parsed.error.issues[0]?.message ?? 'invalid body', requestId: req.id },
      });
    }
    const { pathId, experienceId } = parsed.data;

    // SECURITY: If this path uses the checkpoint system, reject direct completion claims.
    const pathNodes = await store.listPathNodes(pathId);
    const hasCheckpoints = pathNodes.length > 0; // If path has nodes, it uses the new system
    if (hasCheckpoints) {
      return reply.code(403).send({
        error: {
          code: 'CHECKPOINT_REQUIRED',
          message: 'This path requires checkpoint verification. Use POST /api/v1/learn/checkpoints/:id/submit.',
          requestId: req.id,
        },
      });
    }

    const { row, created } = await store.upsertLearnProgress(req.student!.id, pathId, experienceId);
    const total = (await store.listLearnProgress(req.student!.id)).length;
    return reply.code(created ? 201 : 200).send({
      saved: true,
      alreadyCompleted: !created,
      completedAt: row.completedAt.toISOString(),
      total,
    });
  });

  // ─── EXISTING: evidence log ─────────────────────────────────────────────────

  app.get('/api/v1/learn/evidence', { preHandler: auth }, async (req) => {
    const since = typeof (req.query as { since?: string })?.since === 'string'
      ? new Date((req.query as { since: string }).since)
      : undefined;
    const validSince = since && !Number.isNaN(since.getTime()) ? since : undefined;
    const rows = await store.listLearnEvidence(req.student!.id, validSince);
    return {
      items: rows.map((r) => ({ ...r, studentId: undefined, createdAt: r.createdAt.toISOString() })),
      total: rows.length,
    };
  });

  app.post('/api/v1/learn/evidence', { preHandler: auth }, async (req, reply) => {
    const parsed = PostLearnEvidenceBody.safeParse(req.body);
    if (!parsed.success) {
      return reply.code(400).send({
        error: { code: 'BAD_REQUEST', message: parsed.error.issues[0]?.message ?? 'invalid body', requestId: req.id },
      });
    }
    const events: LearnEvidenceInput[] = parsed.data.events.map((e) => ({
      id: e.id,
      skillId: e.skillId,
      representation: e.representation,
      context: e.context ?? null,
      source: e.source,
      kind: e.kind,
      outcome: e.outcome,
      verification: e.verification,
      attempt: e.attempt ?? 1,
      hints: e.hints ?? 0,
      recovered: e.recovered ?? false,
      errorPattern: e.errorPattern ?? null,
      toolId: e.toolId ?? null,
      pathId: e.pathId ?? null,
      experienceId: e.experienceId ?? null,
      stepIndex: e.stepIndex ?? null,
      ms: e.ms ?? null,
      createdAt: new Date(e.createdAt),
    }));
    const { accepted } = await store.upsertLearnEvidence(req.student!.id, events);
    const total = (await store.listLearnEvidence(req.student!.id)).length;
    return reply.code(201).send({ accepted, total });
  });

  // ─── NEW: Path-level progress (Unshakable City) ─────────────────────────────

  /**
   * GET /api/v1/learn/path/:pathId/progress
   * Returns the student's full progression state for a learning path.
   */
  app.get('/api/v1/learn/path/:pathId/progress', { preHandler: auth }, async (req, reply) => {
    const { pathId } = req.params as { pathId: string };
    const studentId = req.student!.id;

    const path = await store.getLearningPath(pathId);
    if (!path) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'Learning path not found', requestId: req.id },
      });
    }

    const pathNodes = await store.listPathNodes(pathId);
    if (pathNodes.length === 0) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'Path has no nodes', requestId: req.id },
      });
    }

    // Initialize progress rows if they don't exist yet
    await store.initializePathProgress(studentId, pathId, pathNodes.map((n) => n.id));

    const progressRows = await store.listNodeProgress(studentId, pathId);

    const nodes = pathNodes
      .sort((a, b) => a.orderIndex - b.orderIndex)
      .map((node) => {
        const prog = progressRows.find((p) => p.pathNodeId === node.id);
        return {
          pathNodeId: node.id,
          title: node.title,
          titleAr: (node as any).titleAr ?? null,
          orderIndex: node.orderIndex,
          status: prog?.status ?? 'locked',
          currentStageIndex: prog?.currentStageIndex ?? 0,
          checkpointScore: prog?.checkpointScore ?? null,
          checkpointPassed: prog?.checkpointPassed ?? false,
          completedAt: prog?.completedAt?.toISOString() ?? null,
          attemptsCount: prog?.attemptsCount ?? 0,
          hintsUsed: prog?.hintsUsed ?? 0,
        };
      });

    const completedCount = nodes.filter((n) => n.status === 'completed').length;
    const completionPercent = Math.round((completedCount / nodes.length) * 100);
    const currentNode = nodes.find((n) => n.status === 'in_progress') ?? nodes.find((n) => n.status === 'available');

    return {
      pathId,
      pathName: path.name,
      nodes,
      completionPercent,
      currentNodeId: currentNode?.pathNodeId ?? null,
      totalXpEarned: (await store.listXpEvents(studentId, 100_000))
        .filter((e) => e.reason.startsWith('city_'))
        .reduce((sum, e) => sum + e.amount, 0),
    };
  });

  /**
   * PUT /api/v1/learn/stage-progress
   * Save the student's current stage within a node WITHOUT claiming completion.
   */
  app.put('/api/v1/learn/stage-progress', { preHandler: auth }, async (req, reply) => {
    const parsed = PutStageProgressBody.safeParse(req.body);
    if (!parsed.success) {
      return reply.code(400).send({
        error: { code: 'BAD_REQUEST', message: parsed.error.issues[0]?.message ?? 'invalid body', requestId: req.id },
      });
    }

    const { pathNodeId, stageIndex } = parsed.data;
    const studentId = req.student!.id;

    const node = await store.getPathNode(pathNodeId);
    if (!node) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'PathNode not found', requestId: req.id },
      });
    }

    const progress = await store.getOrCreateNodeProgress(studentId, pathNodeId, node.learningPathId);

    // SECURITY: Cannot access locked nodes
    if (progress.status === 'locked') {
      return reply.code(403).send({
        error: { code: 'NODE_LOCKED', message: 'This node is locked. Complete the previous checkpoint first.', requestId: req.id },
      });
    }

    // Never regress stage index
    const newStageIndex = advanceStage(progress.currentStageIndex, stageIndex);
    const newStatus = nextStatusOnInteraction(progress.status as any);

    const updated = await store.updateNodeProgress(progress.id, {
      currentStageIndex: newStageIndex,
      status: newStatus,
    });

    return {
      saved: true as const,
      pathNodeId,
      currentStageIndex: updated.currentStageIndex,
      status: updated.status,
    };
  });

  /**
   * POST /api/v1/learn/activities/:activityId/attempt
   * Student submits an answer. Server grades with fixed rules. NEVER reveals correct answer.
   */
  app.post('/api/v1/learn/activities/:activityId/attempt', { preHandler: auth }, async (req, reply) => {
    const { activityId } = req.params as { activityId: string };
    const studentId = req.student!.id;

    const parsed = PostActivityAttemptBody.safeParse(req.body);
    if (!parsed.success) {
      return reply.code(400).send({
        error: { code: 'BAD_REQUEST', message: parsed.error.issues[0]?.message ?? 'invalid body', requestId: req.id },
      });
    }

    const activity = await store.getPathNodeActivity(activityId);
    if (!activity) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'Activity not found', requestId: req.id },
      });
    }

    // SECURITY: Check node is not locked
    const progress = await store.getOrCreateNodeProgress(studentId, activity.pathNodeId, '');
    if (progress.status === 'locked') {
      return reply.code(403).send({
        error: { code: 'NODE_LOCKED', message: 'This node is locked.', requestId: req.id },
      });
    }

    // Count existing attempts
    const existingCount = await store.countLearnAttempts(studentId, activityId);
    const attemptNumber = existingCount + 1;

    // Grade with fixed correction rules
    const rules = (activity.correctionRulesJson ?? null) as CorrectionRules | null;
    const result = gradeActivity(
      parsed.data.answer,
      activity.correctAnswerJson,
      rules,
      activity.activityType,
    );

    // Determine hint (only if incorrect)
    let hint: { level: number; text: string; textAr?: string } | null = null;
    if (result.outcome !== 'correct' && activity.hintsJson && activity.hintsJson.length > 0) {
      const level = hintLevel(attemptNumber);
      const hintEntry = activity.hintsJson.find((h) => h.level === level) ?? activity.hintsJson[activity.hintsJson.length - 1];
      if (hintEntry) {
        hint = { level: hintEntry.level, text: hintEntry.text, textAr: hintEntry.textAr };
      }
    }

    // XP: only if correct and node not already completed
    const isReplay = progress.status === 'completed';
    let xpAwarded = 0;
    if (result.outcome === 'correct' && !isReplay) {
      xpAwarded = Math.round(activity.xpReward * xpMultiplier(attemptNumber));
      await store.addXpEvent(studentId, xpAwarded, `city_activity_${activity.activityType}`);
    }

    // Check if this is a recovery (was wrong before, now correct)
    const previousAttempts = await store.listLearnAttempts(studentId, activity.pathNodeId);
    const wasWrongBefore = previousAttempts.some(
      (a) => a.activityId === activityId && a.outcome !== 'correct',
    );
    const recovered = result.outcome === 'correct' && wasWrongBefore;

    // Record the attempt
    const attempt = await store.createLearnAttempt({
      studentId,
      activityId,
      pathNodeId: activity.pathNodeId,
      attemptNumber,
      answerJson: parsed.data.answer,
      outcome: result.outcome,
      errorPattern: result.errorPattern,
      hintsUsedBefore: hint ? hint.level - 1 : 0,
      timeMs: parsed.data.timeMs ?? null,
      recovered,
    });

    // Update node progress counters
    await store.updateNodeProgress(progress.id, {
      attemptsCount: progress.attemptsCount + 1,
      hintsUsed: progress.hintsUsed + (hint ? 1 : 0),
    });

    // Write evidence row (server_verified)
    if (activity.skillId) {
      await store.upsertLearnEvidence(studentId, [{
        id: `srv_${attempt.id}`,
        skillId: activity.skillId,
        representation: activity.activityType,
        context: null,
        source: 'learn_step',
        kind: 'construction',
        outcome: result.outcome,
        verification: 'server_verified',
        attempt: attemptNumber,
        hints: hint ? hint.level : 0,
        recovered,
        errorPattern: result.errorPattern,
        toolId: null,
        pathId: progress.learningPathId || null,
        experienceId: null,
        stepIndex: null,
        ms: parsed.data.timeMs ?? null,
        createdAt: new Date(),
      }]);
    }

    return reply.code(201).send({
      attemptId: attempt.id,
      attemptNumber,
      outcome: result.outcome,
      errorPattern: result.errorPattern,
      hint,
      correct: result.outcome === 'correct',
      xpAwarded,
    });
  });

  /**
   * POST /api/v1/learn/checkpoints/:checkpointId/submit
   * Server grades checkpoint, unlocks next node if passed. ONLY way to complete a node.
   */
  app.post('/api/v1/learn/checkpoints/:checkpointId/submit', { preHandler: auth }, async (req, reply) => {
    const { checkpointId } = req.params as { checkpointId: string };
    const studentId = req.student!.id;

    const parsed = PostCheckpointSubmitBody.safeParse(req.body);
    if (!parsed.success) {
      return reply.code(400).send({
        error: { code: 'BAD_REQUEST', message: parsed.error.issues[0]?.message ?? 'invalid body', requestId: req.id },
      });
    }

    const checkpoint = await store.getPathNodeCheckpoint(checkpointId);
    if (!checkpoint) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'Checkpoint not found', requestId: req.id },
      });
    }

    // SECURITY: Check node is not locked
    const node = await store.getPathNode(checkpoint.pathNodeId);
    if (!node) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'PathNode not found', requestId: req.id },
      });
    }

    const progress = await store.getOrCreateNodeProgress(studentId, checkpoint.pathNodeId, node.learningPathId);
    if (progress.status === 'locked') {
      return reply.code(403).send({
        error: { code: 'NODE_LOCKED', message: 'This node is locked.', requestId: req.id },
      });
    }

    // SECURITY: If already passed, return existing result (idempotent)
    if (progress.checkpointPassed) {
      return reply.code(200).send({
        submissionId: 'already_passed',
        score: progress.checkpointScore ?? 1.0,
        passed: true,
        correctCount: 0,
        totalCount: 0,
        xpAwarded: 0,
        nextNodeId: null,
        nextNodeTitle: null,
      });
    }

    // Grade each question
    const questions = checkpoint.questionsJson as unknown as CheckpointQuestion[];
    const answers = parsed.data.answers;
    let correctCount = 0;
    const gradedAnswers: Array<{ questionId: string; answer: unknown; correct: boolean }> = [];

    for (const submitted of answers) {
      const question = questions.find((q) => q.id === submitted.questionId);
      if (!question) {
        gradedAnswers.push({ questionId: submitted.questionId, answer: submitted.answer, correct: false });
        continue;
      }
      const { correct } = gradeCheckpointQuestion(submitted.answer, question);
      if (correct) correctCount++;
      gradedAnswers.push({ questionId: submitted.questionId, answer: submitted.answer, correct });
    }

    const totalCount = questions.length;
    const score = totalCount > 0 ? correctCount / totalCount : 0;
    const passed = checkpointPasses(score, checkpoint.passThreshold);

    // Count previous submissions for XP multiplier
    const prevSubmissions = await store.countCheckpointSubmissions(studentId, checkpointId);
    const attemptNumber = prevSubmissions + 1;

    // Record submission
    const submission = await store.createCheckpointSubmission({
      studentId,
      checkpointId,
      pathNodeId: checkpoint.pathNodeId,
      answersJson: gradedAnswers,
      score,
      passed,
      attemptNumber,
    });

    let xpAwarded = 0;
    let nextNodeId: string | null = null;
    let nextNodeTitle: string | null = null;

    if (passed) {
      // Mark node as completed — THIS IS THE ONLY PLACE THIS HAPPENS
      await store.updateNodeProgress(progress.id, {
        status: 'completed',
        checkpointScore: score,
        checkpointPassed: true,
        completedAt: new Date(),
      });

      // Award XP
      xpAwarded = Math.round(checkpoint.xpReward * xpMultiplier(attemptNumber));
      await store.addXpEvent(studentId, xpAwarded, `city_checkpoint_${checkpoint.pathNodeId}`);

      // Unlock next node
      // Unlock next node
      const allNodes = await store.listPathNodes(node.learningPathId);
      const sorted = allNodes.sort((a, b) => a.orderIndex - b.orderIndex);
      const currentIdx = sorted.findIndex((n) => n.id === checkpoint.pathNodeId);
      if (currentIdx >= 0 && currentIdx < sorted.length - 1) {
        const nextNode = sorted[currentIdx + 1];
        if (nextNode) {
          const nextProgress = await store.getOrCreateNodeProgress(
            studentId,
            nextNode.id,
            node.learningPathId,
          );
          if (nextProgress.status === 'locked') {
            await store.updateNodeProgress(nextProgress.id, { status: 'available' });
          }
          nextNodeId = nextNode.id;
          nextNodeTitle = nextNode.title;
        }
      }
    }

    return reply.code(201).send({
      submissionId: submission.id,
      score,
      passed,
      correctCount,
      totalCount,
      xpAwarded,
      nextNodeId,
      nextNodeTitle,
    });
  });

  /**
   * GET /api/v1/learn/nodes/:nodeId/stages
   * Returns the 6 stages of a node with content.
   */
  app.get('/api/v1/learn/nodes/:nodeId/stages', { preHandler: auth }, async (req, reply) => {
    const { nodeId } = req.params as { nodeId: string };
    const studentId = req.student!.id;

    const node = await store.getPathNode(nodeId);
    if (!node) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'PathNode not found', requestId: req.id },
      });
    }

    // SECURITY: Check not locked
    const progress = await store.getOrCreateNodeProgress(studentId, nodeId, node.learningPathId);
    if (progress.status === 'locked') {
      return reply.code(403).send({
        error: { code: 'NODE_LOCKED', message: 'This node is locked.', requestId: req.id },
      });
    }

    const stages = await store.listPathNodeStages(nodeId);

    return {
      pathNodeId: nodeId,
      title: node.title,
      titleAr: (node as any).titleAr ?? null,
      currentStageIndex: progress.currentStageIndex,
      stages: stages
        .sort((a, b) => a.orderIndex - b.orderIndex)
        .map((s) => ({
          id: s.id,
          stageType: s.stageType,
          orderIndex: s.orderIndex,
          title: s.title,
          titleAr: s.titleAr,
          contentJson: s.contentJson,
        })),
    };
  });

  /**
   * GET /api/v1/learn/nodes/:nodeId/activities
   * Returns activities for a node. CORRECT ANSWERS ARE STRIPPED.
   */
  app.get('/api/v1/learn/nodes/:nodeId/activities', { preHandler: auth }, async (req, reply) => {
    const { nodeId } = req.params as { nodeId: string };
    const studentId = req.student!.id;

    const node = await store.getPathNode(nodeId);
    if (!node) {
      return reply.code(404).send({
        error: { code: 'NOT_FOUND', message: 'PathNode not found', requestId: req.id },
      });
    }

    // SECURITY: Check not locked
    const progress = await store.getOrCreateNodeProgress(studentId, nodeId, node.learningPathId);
    if (progress.status === 'locked') {
      return reply.code(403).send({
        error: { code: 'NODE_LOCKED', message: 'This node is locked.', requestId: req.id },
      });
    }

    const activities = await store.listPathNodeActivities(nodeId);

    // Get attempt counts per activity
    const activitiesWithCounts = await Promise.all(
      activities
        .sort((a, b) => a.orderIndex - b.orderIndex)
        .map(async (a) => {
          const count = await store.countLearnAttempts(studentId, a.id);
          return {
            id: a.id,
            activityType: a.activityType,
            prompt: a.prompt,
            promptAr: a.promptAr,
            dataJson: a.dataJson,
            orderIndex: a.orderIndex,
            xpReward: a.xpReward,
            attemptCount: count,
            // SECURITY: correctAnswerJson and correctionRulesJson are NEVER included
          };
        }),
    );

    return {
      pathNodeId: nodeId,
      activities: activitiesWithCounts,
    };
  });
}

