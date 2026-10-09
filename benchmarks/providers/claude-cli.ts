/**
 * promptfoo exec provider: runs each prompt through the local `claude` binary
 * using the existing Claude Code login — no ANTHROPIC_API_KEY needed.
 *
 * Isolation: empty cwd, no setting sources, no tools, no skills, no MCP, so the
 * user's CLAUDE.md / hooks / skills never contaminate either arm. Org-level
 * instructions still apply, identically to both arms.
 *
 * promptfoo invokes: <cmd> <prompt> <options-json> <context-json>
 * Model: EVAL_MODEL (default claude-sonnet-4-6).
 */

import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PromptMessage } from '../types.ts';

const DEFAULT_MODEL = 'claude-sonnet-4-6';
const TIMEOUT_MS = 180_000;
const MAX_OUTPUT_BYTES = 10 * 1024 * 1024;

/** promptfoo passes a prompt function's messages as a JSON string; plain text otherwise. */
function parsePrompt(raw: string): { system?: string; user: string } {
  try {
    const messages = JSON.parse(raw) as PromptMessage[];
    if (!Array.isArray(messages)) return { user: raw };
    const system = messages.filter(m => m.role === 'system').map(m => m.content).join('\n\n');
    const user = messages.filter(m => m.role === 'user').map(m => m.content).join('\n\n');
    return { system: system || undefined, user };
  } catch {
    return { user: raw };
  }
}

function runClaude(prompt: string): string {
  const { system, user } = parsePrompt(prompt);
  const args = [
    '-p',
    '--model', process.env.EVAL_MODEL || DEFAULT_MODEL,
    '--setting-sources', '',
    '--tools', '',
    '--disable-slash-commands',
    '--strict-mcp-config',
    '--no-session-persistence',
    '--output-format', 'text',
    // Replace Claude Code's agent system prompt so the baseline arm is a bare model.
    '--system-prompt', system ?? 'You are a helpful assistant.',
  ];
  const cwd = mkdtempSync(join(tmpdir(), 'wk-eval-'));
  try {
    return execFileSync('claude', args, {
      cwd,
      input: user,
      encoding: 'utf8',
      timeout: TIMEOUT_MS,
      maxBuffer: MAX_OUTPUT_BYTES,
    });
  } finally {
    rmSync(cwd, { recursive: true, force: true });
  }
}

const prompt = process.argv[2];
if (!prompt) {
  console.error('claude-cli provider: missing prompt argument');
  process.exit(2);
}
process.stdout.write(runClaude(prompt));
