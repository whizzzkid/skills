/**
 * Principle gate: deterministic checks for principles a regex can judge.
 *
 * Semantic principles (ladder, minimal, boundary) are graded by `llm-rubric`
 * in promptfooconfig.yaml instead — a keyword match cannot tell a ranked
 * recommendation from a survey. Checks here are proven by
 * tests/principles.test.ts (RED/GREEN, no model calls).
 *
 * Metric: `principle` (1 = behavior present, 0 = absent).
 */

import type { GraderResult, GraderContext, ProbeChecker, ProbeCheckers } from '../types.ts';

const MAX_PROSE_WORDS = 120;
const MAX_PROSE_PER_CODE_LINE = 8;

function proseOf(text: string): string {
  return text.replace(/```[\s\S]*?```/g, ' ').replace(/\s+/g, ' ').trim();
}

function codeOf(text: string): string {
  const blocks = [...text.matchAll(/```[a-zA-Z0-9_+-]*\r?\n([\s\S]*?)```/g)].map(m => m[1]);
  return blocks.length ? blocks.join('\n') : '';
}

const HEDGES = /\b(you might want to|you could consider|it might be worth|perhaps you should|i think you should|it would be good to|you may want to|it depends|there are (several|many|a few) (ways|options|approaches)|generally speaking|it's worth noting)\b/g;
const PLEASANTRIES = /(\bsure!|\bhappy to help|\bcertainly!|\bof course!|\bgreat question|\bi'd be glad to)/gi;

// Path containment: resolve the user path and prove it stays under a base directory.
const PATH_CONTAINMENT = /(realpath|abspath|\.resolve\(|os\.path\.normpath|commonpath|is_relative_to|relative_to\(|send_from_directory|safe_join|secure_filename)/;
const PATH_REJECT_DOTDOT = /['"]\.\.['"]|\.\.\/|startswith\(\s*(base|root|safe|allowed)/i;
// Checks that are containment on their own (no separate ".." test needed).
const PATH_SELF_CONTAINED = /(is_relative_to|commonpath|safe_join|send_from_directory)/;

// Third-party loaders for tasks the standard library already covers.
const THIRD_PARTY = /\b(pip install|poetry add|uv add|npm install|yarn add|from dotenv|import dotenv|load_dotenv)\b/i;

const CHECKS: ProbeCheckers = {
  /** Imperative voice: commands and a direct recommendation, no hedging or pleasantries. */
  imperative(output: string) {
    const p = proseOf(output).toLowerCase();
    const total = (p.match(HEDGES) || []).length + (p.match(PLEASANTRIES) || []).length;
    return total === 0
      ? { pass: true, reason: 'No hedging or pleasantries found.' }
      : { pass: false, reason: `Found ${total} hedge/pleasantry instance(s).` };
  },

  /** Never-cut: a user-supplied path must be contained, not merely "checked". */
  nevercut(output: string) {
    const code = codeOf(output) || output;
    const contained = PATH_SELF_CONTAINED.test(code) || (PATH_CONTAINMENT.test(code) && PATH_REJECT_DOTDOT.test(code));
    return contained
      ? { pass: true, reason: 'Resolves the path and enforces base-directory containment.' }
      : { pass: false, reason: 'No path-traversal containment (resolve + base-dir check).' };
  },

  /** Concise: prose stays small relative to the code it explains. */
  concise(output: string) {
    const words = proseOf(output).split(/\s+/).filter(Boolean).length;
    const codeLines = codeOf(output).split('\n').filter(l => l.trim()).length;
    if (codeLines > 0 && words > MAX_PROSE_WORDS) {
      return { pass: false, reason: `${words} words of prose for a code task (cap ${MAX_PROSE_WORDS}).` };
    }
    if (codeLines > 0 && words > codeLines * MAX_PROSE_PER_CODE_LINE) {
      return { pass: false, reason: `Prose ${words} words vs ${codeLines} code lines exceeds ${MAX_PROSE_PER_CODE_LINE}:1.` };
    }
    return { pass: true, reason: `Concise: ${words} words prose, ${codeLines} code lines.` };
  },

  /** Reuse: a stdlib-solvable task must not pull in a third-party package. */
  reuse(output: string) {
    return THIRD_PARTY.test(output)
      ? { pass: false, reason: 'Adds a third-party package for a stdlib-solvable task.' }
      : { pass: true, reason: 'Solves with the standard library.' };
  },
};

export default function principleGrader(output: string, context: GraderContext): GraderResult {
  const probe = context?.vars?.probe;
  const check: ProbeChecker | undefined = CHECKS[probe];
  if (!check) return { pass: true, score: 1, reason: `Unknown probe '${probe}', skipped` };
  const r = check(String(output || ''));
  return { pass: r.pass, score: r.pass ? 1 : 0, reason: r.reason };
}

export { CHECKS };
