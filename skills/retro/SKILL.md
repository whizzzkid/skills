---
name: wk-retro
description: >-
  Run a session retrospective to capture learnings and improve future sessions.
  Use when ending a work session, after completing a major task, when asked to
  retro or reflect, or when the session produced corrections or lessons worth
  preserving.
argument-hint: '[optional: topic or session focus]'
allowed-tools:
  - "Bash(git log:*)"
  - "Bash(git diff:*)"
  - "Bash(git status:*)"
  - "Bash(cat ~/.claude*:*)"
  - "Bash(find ~/.claude*:*)"
  - "Bash(ls ~/.claude*:*)"
  - "Bash(mkdir -p ~/.claude*:*)"
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Skill
  - AskUserQuestion
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.08-181958'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Session Retro

Structured retrospective that captures session learnings and promotes them
globally so ALL future sessions benefit — regardless of which project they run
in. Run at the end of a work session or after completing a significant task.

## Global Paths

All retro artifacts are written to the **user-level** memory directory, never to
a project-specific path. This ensures learnings travel across projects.

```
GLOBAL_MEMORY="$HOME/.claude/memory"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
```

## Step 1: Review Session Context

Gather what happened this session.

```bash
git log --oneline -15
git diff HEAD~5..HEAD --stat 2>/dev/null || git diff --stat
```

Read the global MEMORY.md to understand prior context:

```bash
cat "$HOME/.claude/memory/MEMORY.md" 2>/dev/null || echo "No global MEMORY.md found"
```

Also check the conversation history for corrections, redirects, and decisions.

## Step 2: Reflect Across 5 Lenses

Work through each lens. Be specific and concrete — vague observations are not
useful. If a lens has no meaningful findings, skip it entirely.

### Lens 1: Where Claude got it wrong

- Misread a file or made a wrong assumption?
- Produced output the user had to correct?
- Followed a convention that turned out to be wrong?
- Missed something obvious already in the codebase?

### Lens 2: Where the user corrected the approach

- Redirected the plan mid-execution?
- Design was wrong and only became clear during implementation?
- A test or experiment revealed a gap in the approach?

### Lens 3: Gaps in tools, skills, or docs

- A step missing from a skill's instructions?
- A case not covered by existing patterns?
- A real scenario that exposed something a skill didn't account for?
- Documentation that was outdated or incomplete?

### Lens 4: Decisions made (and why)

- Non-obvious choices made this session?
- What was explicitly rejected, and why?
- Tradeoffs that were accepted?

### Lens 5: What worked well

- What did the agent get right without correction?
- Which parts of the process felt smooth?
- Good patterns worth reinforcing?

## File Access Rules

**HARD RULE:** Write and Edit tools may ONLY target files under `~/.claude/`
(memory files, retro logs, MEMORY.md). Never write or edit files in the
project working directory or anywhere else on the filesystem.

Read, Glob, and Grep may access any path (read-only).

## Step 3: Write Retro Notes

Write a dated entry to the **global** retro log:

```
~/.claude/memory/retro-log.md
```

Use this format — omit sections with no meaningful findings:

```markdown
## Retro -- {YYYY-MM-DD} — {project name or topic}

### Corrections (Claude <- User)
- [specific thing Claude got wrong and how it was corrected]

### Approach Redirects
- [specific change in plan or design discovered during work]

### Tool/Skill Gaps
- [gap found, which file is affected, what's missing]

### Decisions
- [decision]: [rationale]

### What Worked
- [thing that worked well]
```

## Step 4: Promote — Distill and Route Globally

This is the step that actually improves future sessions. Every finding must be
**distilled** into a concise, actionable rule and promoted **globally** so it
applies across all projects and sessions.

### Distillation rules

Before writing anything, distill each finding:

1. **Strip the narrative.** "During the auth refactor Claude assumed the middleware
   used Express but it was Koa" becomes: "Verify the framework before assuming
   middleware patterns."
2. **Generalize.** Remove project-specific details unless the lesson only applies
   to one project. Prefer universal principles.
3. **Make it actionable.** Each promoted item must be a rule someone can follow,
   not a story about what happened.
4. **One sentence per rule.** If it needs more, it's two rules.

### Promotion targets

All targets are **global** (user-level), not project-scoped:

| Lesson type | Target |
|-------------|--------|
| Workflow rules, process preferences | `~/.claude/memory/MEMORY.md` (global memory index) + individual memory file |
| Agent behavior, approach corrections | `~/.claude/memory/` (as a `feedback` type memory file) |
| Standing decisions (what was rejected) | `~/.claude/memory/` (as a `feedback` type memory file) |
| User preferences, collaboration style | `~/.claude/memory/` (as a `user` type memory file) |
| Skill gaps or missing steps | Invoke `wk-learn <skill-name>` to write a learning file — `wk-sharpen` batch mode will distill it on the next run |

### Memory file format

When creating memory files under `~/.claude/memory/`, use the standard
frontmatter format:

```markdown
---
name: {descriptive name}
description: {one-line description for relevance matching}
type: {user | feedback | project | reference}
---

{distilled rule}

**Why:** {one-line reason}
**How to apply:** {when/where this kicks in}
```

Then add a one-line pointer to `~/.claude/memory/MEMORY.md`.

### For each lesson

1. **Distill** the finding into an actionable rule (see distillation rules above)
2. **Check** if it's already captured in a global memory file or MEMORY.md
3. **If not captured:** create a memory file and add to MEMORY.md index
4. **If already captured:** verify accuracy; update if stale
5. **For skill file edits:** propose the specific edit and ask the user to
   approve before making changes (use AskUserQuestion)

**Key rule:** The retro-log holds the story. Global memory files hold only the
distilled, actionable rule. Never write narrative to memory files.

After promoting, note in the retro entry which lessons were promoted and where.

## Optional: Stop Hook

A Stop hook can remind you to run a retro at the end of every session. This is
optional — the skill works fine as a manual invocation.

### Install

Add the following to your `~/.claude/settings.json` (or project
`.claude/settings.local.json`), replacing `{SKILL_DIR}` with the absolute path
to this skill's directory:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "{SKILL_DIR}/scripts/suggest-retro.sh"
          }
        ]
      }
    ]
  }
}
```

The script prints a reminder message at session end. It does not auto-run the
retro — control stays with the user.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-retro` | Full 4-step retro with promotion |
| `/wk-retro "auth refactor"` | Retro focused on a specific topic |

## Requirements

- Git repository (for reviewing session changes)
- Shell access (for running git commands and discovering targets)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn retro`).
