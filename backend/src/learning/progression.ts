/**
 * Progression state machine for the Unshakable City learning path.
 * Enforces: locked → available → in_progress → completed.
 * Only the checkpoint submission endpoint can transition to "completed".
 * Only the server can unlock the next node.
 */

export type NodeStatus = 'locked' | 'available' | 'in_progress' | 'completed';

export const STAGE_TYPES = [
  'scene',
  'discovery',
  'explanation',
  'training',
  'application',
  'verification',
] as const;

export type StageType = (typeof STAGE_TYPES)[number];

export const STAGE_COUNT = 6;

/**
 * Validate a stage transition. Returns the new stage index (never regresses).
 */
export function advanceStage(currentIndex: number, requestedIndex: number): number {
  if (requestedIndex < 0 || requestedIndex >= STAGE_COUNT) return currentIndex;
  return Math.max(currentIndex, requestedIndex);
}

/**
 * Determine the next status when a student interacts with a node.
 */
export function nextStatusOnInteraction(current: NodeStatus): NodeStatus {
  if (current === 'available') return 'in_progress';
  return current; // in_progress stays in_progress; completed stays completed (replay)
}

/**
 * XP multiplier based on attempt number.
 * 1st attempt correct: 100%, 2nd: 70%, 3rd+: 50%.
 */
export function xpMultiplier(attemptNumber: number): number {
  if (attemptNumber <= 1) return 1.0;
  if (attemptNumber === 2) return 0.7;
  return 0.5;
}

/**
 * Hint level based on failed attempt count.
 * 1st wrong → hint 1, 2nd wrong → hint 2, 3rd+ wrong → hint 3.
 */
export function hintLevel(failedAttempts: number): number {
  return Math.min(failedAttempts, 3);
}

/**
 * Check if a checkpoint score passes the threshold.
 */
export function checkpointPasses(score: number, threshold: number): boolean {
  return score >= threshold;
}