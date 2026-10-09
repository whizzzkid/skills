/**
 * With-skills arm: loads the relevant skill as system prompt + AGENTS.md preamble.
 * Probe var determines which skill to load (maps probe → skill SKILL.md path).
 */

import { readFileSync } from 'fs';
import { join } from 'path';
import type { PromptVars, PromptMessage } from '../types.ts';

// SKILLS_ROOT points at another checkout (e.g. a `git archive` of an older commit)
// to compare skill versions with the same graders.
const ROOT = process.env.SKILLS_ROOT || join(import.meta.dirname, '..', '..');
const SKILLS_DIR = join(ROOT, 'skills');
const AGENTS_MD = join(ROOT, 'AGENTS.md');

/** Map probe → skill whose principles it tests. */
const PROBE_SKILL: Record<string, string> = {
  // Cross-cutting principles (promptfooconfig.yaml)
  imperative: 'concise',
  ladder: 'workflow',
  minimal: 'plan',
  nevercut: 'adversarial-review',
  boundary: 'pr-review',
  concise: 'concise',
  reuse: 'workstyle',
  // PR family (promptfooconfig-skills.yaml)
  pr_draft: 'pr',
  pr_review_verdict: 'pr-review',
  pr_review_severity: 'pr-review',
  pr_merge_retarget: 'pr-merge',
  pr_resolve_no_pleasantries: 'pr-resolve',
  // Commit family
  commit_format: 'commit',
  commit_heredoc: 'commit',
  gh_org_check: 'gh',
  // Workflow family
  workflow_phases: 'workflow',
  workflow_version_pins: 'workflow',
  plan_numbered_steps: 'plan',
  // Code quality family
  adversarial_severity: 'adversarial-review',
  testing_happy_sad: 'testing-skeleton',
  design_review_ranked: 'design-review',
  // DevOps family
  docker_daemon_check: 'docker',
  buildkite_bk_cli: 'buildkite',
  datadog_pup_cli: 'datadog',
  // Communication family
  slack_mrkdwn: 'slack',
  mermaid_linebreaks: 'mermaid',
  markdown_wrap: 'markdown',
  // Utility family
  calver_format: 'calver',
  curl_flags: 'curl',
  learn_routing: 'learn',
  retro_structured: 'retro',
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
