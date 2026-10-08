/**
 * Principle gate: does the skill ruleset produce its refined behaviors?
 *
 * One check per probe (vars.probe), each targeting a principle from the
 * ponytail-informed skill standards. Heuristic graders proven by
 * tests/principles.test.ts (RED/GREEN, no API key needed).
 *
 * Metric: `principle` (1 = behavior present, 0 = absent).
 */

import type { GraderResult, GraderContext, ProbeChecker, ProbeCheckers } from '../types.ts';

function proseOf(text: string): string {
  return text.replace(/```[\s\S]*?```/g, ' ').replace(/\s+/g, ' ').trim();
}

function codeOf(text: string): string {
  const blocks = [...text.matchAll(/```[a-zA-Z0-9_+-]*\r?\n([\s\S]*?)```/g)].map(m => m[1]);
  return blocks.length ? blocks.join('\n') : '';
}

const CHECKS: ProbeCheckers = {
  /** Imperative voice: output uses commands, not hedging/pleasantries. */
  imperative(output: string) {
    const p = proseOf(output).toLowerCase();
    const hedges = (p.match(/\b(you might want to|you could consider|it might be worth|perhaps you should|i think you should|it would be good to|you may want to)\b/g) || []).length;
    const pleasantries = (p.match(/\b(sure!|happy to help|certainly!|of course!|great question|i'd be glad to)\b/gi) || []).length;
    const total = hedges + pleasantries;
    return total === 0
      ? { pass: true, reason: 'No hedging or pleasantries found.' }
      : { pass: false, reason: `Found ${total} hedge/pleasantry instance(s): output should use imperative voice.` };
  },

  /** Decision ladder: output presents options in priority order, not equal-weight. */
  ladder(output: string) {
    const t = output;
    const hasLadder = /\b(first|1[.)]\s|prefer\b.*\bover\b|before\b.*\btry\b|start with|fall back to|if that fails|otherwise)\b/i.test(t);
    const hasEqualWeight = /\b(you could (either|also)|another option|alternatively,? you)\b/i.test(t);
    if (hasLadder && !hasEqualWeight) return { pass: true, reason: 'Presents prioritized decision ladder.' };
    if (hasEqualWeight) return { pass: false, reason: 'Presents equal-weight alternatives instead of a decision ladder.' };
    return { pass: true, reason: 'No alternatives presented (single solution).' };
  },

  /** Smallest change: output avoids unrequested abstraction/generality. */
  minimal(output: string) {
    const code = codeOf(output);
    const overEngineering: RegExp[] = [
      /factory/i,
      /\babstract\s+class\b/i,
      /\binterface\s+\w+\s*\{/,
      /\bgeneric\b.*\bwrapper\b/i,
      /\bfor\s+future\b/i,
      /\bextensib/i,
      /\bplugg?able\b/i,
      /\bconfigur(able|ation)\s+(system|layer|framework)\b/i,
    ];
    const hits = overEngineering.filter(r => r.test(code)).length;
    return hits === 0
      ? { pass: true, reason: 'No unrequested abstraction detected.' }
      : { pass: false, reason: `Found ${hits} unrequested abstraction pattern(s) in code.` };
  },

  /** Never-cut bright line: security/validation tasks must include guards. */
  nevercut(output: string) {
    const t = output.toLowerCase();
    const hasValidation = /\b(valid|sanitiz|escap|check|guard|boundar|assert|raise|throw|error|except|rescue|catch)\b/.test(t);
    const hasSecurityNote = /\b(security|injection|xss|csrf|sql\s*inject|path\s*travers|ssrf)\b/.test(t);
    if (hasValidation || hasSecurityNote) {
      return { pass: true, reason: 'Includes validation/security handling.' };
    }
    return { pass: false, reason: 'Missing validation or security handling for a trust-boundary task.' };
  },

  /** Boundary awareness: output states what it does NOT do or what's out of scope. */
  boundary(output: string) {
    const p = proseOf(output);
    const hasBoundary = /\b(does not|doesn't|won't|will not|not included|out of scope|skipped|left out|did not|omitted|excluded)\b/i.test(p);
    const hasRisk = /\b(risk|caveat|limitation|assumption|shortcut|tradeoff|trade-off)\b/i.test(p);
    return (hasBoundary || hasRisk)
      ? { pass: true, reason: 'States boundaries, limitations, or omissions.' }
      : { pass: false, reason: 'No boundary statement — should declare what was skipped or what risks remain.' };
  },

  /** Concise output: response not bloated with filler. */
  concise(output: string) {
    const p = proseOf(output);
    const words = p.split(/\s+/).filter(Boolean).length;
    const code = codeOf(output);
    const codeLines = code.split('\n').filter(l => l.trim()).length;
    if (codeLines > 0 && words > codeLines * 15) {
      return { pass: false, reason: `Prose (${words} words) dwarfs code (${codeLines} lines). Ratio ${(words / codeLines).toFixed(1)}:1 exceeds 15:1 ceiling.` };
    }
    if (codeLines > 0 && words > 300) {
      return { pass: false, reason: `${words} words of prose for a code task. Cap is 300.` };
    }
    return { pass: true, reason: `Concise: ${words} words prose, ${codeLines} code lines.` };
  },

  /** Reuse existing: prefers stdlib/builtins over new dependencies. */
  reuse(output: string) {
    const t = output;
    const addsNewDep = /\b(npm install|pip install|gem install|go get|cargo add)\b/i.test(t);
    const mentionsStdlib = /\b(stdlib|standard library|built-?in|native|platform)\b/i.test(t);
    if (addsNewDep && !mentionsStdlib) {
      return { pass: false, reason: 'Reaches for a new dependency without considering stdlib.' };
    }
    return { pass: true, reason: 'Uses existing/stdlib or justifies new dependency.' };
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
