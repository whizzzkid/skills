# Memory Promotion Rules

The step that actually improves future sessions. Every finding must be **distilled** into a concise, actionable rule and promoted **globally** so it applies across all projects and sessions.

## Distillation Rules

Before writing anything, distill each finding:

1. **Strip the narrative.** "During the auth refactor Claude assumed the middleware used Express but it was Koa" → "Verify the framework before assuming middleware patterns."
2. **Generalize.** Remove project-specific details unless the lesson only applies to one project. Prefer universal principles.
3. **Make it actionable.** Each promoted item is a rule someone can follow, not a story.
4. **One sentence per rule.** If it needs more, it's two rules.

## Promotion Targets

All targets are **global** (user-level), not project-scoped:

| Lesson type | Target |
|-------------|--------|
| Workflow rules, process preferences | `$HOME/.claude/memory/MEMORY.md` (global memory index) + individual memory file |
| Agent behavior, approach corrections | `$HOME/.claude/memory/` (as a `feedback` type memory file) |
| Standing decisions (what was rejected) | `$HOME/.claude/memory/` (as a `feedback` type memory file) |
| User preferences, collaboration style | `$HOME/.claude/memory/` (as a `user` type memory file) |
| Skill gaps or missing steps | Invoke `wk-learn <skill-name>` to write a learning file — `wk-sharpen` batch mode will distill it on the next run |

For the memory file frontmatter schema and format, see the "Step 3: Write the learning file" section of the `wk-learn` skill — retro uses the same format.

## Per-Lesson Process

1. **Distill** into an actionable rule (see distillation rules above).
2. **Check** if already captured in a global memory file or MEMORY.md.
3. **If not captured:** create a memory file and add to MEMORY.md index.
4. **If already captured:** verify accuracy; update if stale.
5. **For skill file edits:** propose the specific edit and ask the user to approve before making changes (use AskUserQuestion).

## HARD RULE — Invoke `wk-learn` Per Skill Gap

For every bullet under **What could've been better** that names a skill, invoke `wk-learn` in this same retro response — do not defer:

```
Skill(wk-learn, args="<skill-name>")
```

- The distilled bullet in the retrospect log is the narrative record.
- The `wk-learn` invocation is the actionable record routed to the per-skill learning queue for `wk-sharpen` to fold into the target SKILL.md.
- Both are required. Skipping the `wk-learn` call orphans the lesson — the retrospect log is read by humans, not by the sharpen pipeline.
- One `wk-learn` call per affected skill, not one per session.
- **Compaction recovery:** if the session resumes from a compaction summary that mentions an in-progress retro, first verify each "What could've been better" bullet already got its `wk-learn` call; if not, make them before any other work. The summary reliably carries the retro entry — use it as the source of truth for which skills still need a call.
