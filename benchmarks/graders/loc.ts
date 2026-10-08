/**
 * Deterministic code-size metric: non-blank, non-comment lines of code.
 * Counts fenced blocks, or whole response when model emits bare unfenced code.
 * Recorded as `code_loc` metric per arm (always passes — measurement, not gate).
 */

import type { GraderResult } from '../types.ts';

export default function locGrader(output: string): GraderResult {
  const text = String(output || '');
  const blocks = [...text.matchAll(/```[a-zA-Z0-9_+-]*\r?\n([\s\S]*?)```/g)].map(m => m[1]);
  const code = (blocks.length ? blocks.join('\n') : text).replace(/\/\*[\s\S]*?\*\//g, '');
  const loc = code
    .split('\n')
    .map(l => l.trim())
    .filter(l => l && !l.startsWith('//') && !l.startsWith('#') && l !== '*/' && !l.startsWith('/*') && !l.startsWith('*'))
    .length;
  return { pass: true, score: loc, reason: `${loc} code LOC` };
}
