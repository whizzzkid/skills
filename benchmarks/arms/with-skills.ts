/**
 * With-skills arm: loads the relevant skill as system prompt + AGENTS.md preamble.
 * Probe var determines which skill to load (maps probe → skill SKILL.md path).
 */

import { readFileSync } from 'fs';
import { join } from 'path';
import type { PromptVars, PromptMessage } from '../types.ts';

const SKILLS_DIR = join(import.meta.dirname, '..', '..', 'skills');
const AGENTS_MD = join(import.meta.dirname, '..', '..', 'AGENTS.md');

/** Map probe → skill whose principles it tests. */
const PROBE_SKILL: Record<string, string> = {
  imperative: 'concise',
  ladder: 'workflow',
  minimal: 'plan',
  nevercut: 'adversarial-review',
  boundary: 'pr-review',
  concise: 'concise',
  reuse: 'workstyle',
};

function loadSkill(name: string): string {
  const skillPath = join(SKILLS_DIR, name, 'SKILL.md');
  try { return readFileSync(skillPath, 'utf8'); } catch { return ''; }
}

function loadAgents(): string {
  try { return readFileSync(AGENTS_MD, 'utf8'); } catch { return ''; }
}

export default function withSkills({ vars }: PromptVars): PromptMessage[] {
  const skillName = PROBE_SKILL[vars.probe] || 'workflow';
  const system = [loadAgents(), loadSkill(skillName)].filter(Boolean).join('\n\n---\n\n');
  return [
    { role: 'system', content: system },
    { role: 'user', content: vars.task },
  ];
}
