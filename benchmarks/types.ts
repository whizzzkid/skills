/** Promptfoo grader result. */
export interface GraderResult {
  pass: boolean;
  score: number;
  reason: string;
}

/** Promptfoo test context passed to grader functions. */
export interface GraderContext {
  vars: Record<string, string>;
}

/** A single probe checker function. */
export type ProbeChecker = (output: string) => Omit<GraderResult, 'score'>;

/** Map of probe names to their checker functions. */
export type ProbeCheckers = Record<string, ProbeChecker>;

/** Promptfoo prompt function input. */
export interface PromptVars {
  vars: Record<string, string>;
}

/** Promptfoo message format. */
export interface PromptMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}
