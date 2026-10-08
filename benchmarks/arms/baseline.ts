/** Baseline arm: no skill, just the task. Control group. */

import type { PromptVars, PromptMessage } from '../types.ts';

export default function baseline({ vars }: PromptVars): PromptMessage[] {
  return [{ role: 'user', content: vars.task }];
}
