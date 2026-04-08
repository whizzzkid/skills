---
name: wk:retro
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
  - "Bash(cat ~/.claude:*)"
  - "Bash(find ~/.claude:*)"
  - "Bash(ls ~/.claude:*)"
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - AskUserQuestion
model: sonnet
effort: low
disable-model-invocation: false
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Session Retro

Structured retrospective that captures session learnings and promotes them to
the right files so future sessions benefit. Run at the end of a work session or
after completing a significant task.

## Step 1: Review Session Context

Gather what happened this session.

```bash
git log --oneline -15
git diff HEAD~5..HEAD --stat 2>/dev/null || git diff --stat
```

Locate and read the project's MEMORY.md to understand prior context:

```bash
MEMORY_DIR=$(echo "$PWD" | sed 's|^/||' | sed 's|/|-|g')
MEMORY_PATH="$HOME/.claude/projects/-${MEMORY_DIR}/memory/MEMORY.md"
cat "$MEMORY_PATH" 2>/dev/null || echo "No MEMORY.md found at $MEMORY_PATH"
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

**HARD RULE: Write and Edit tools may ONLY target files under `~/.claude/`
(memory files, retro logs, MEMORY.md). Never write or edit files in the
project working directory or anywhere else on the filesystem.**

Read, Glob, and Grep may access any path (read-only).

## Step 3: Write Retro Notes

Derive the project memory path and append a dated entry to `retro-log.md`.

```bash
MEMORY_DIR=$(echo "$PWD" | sed 's|^/||' | sed 's|/|-|g')
RETRO_PATH="$HOME/.claude/projects/-${MEMORY_DIR}/memory/retro-log.md"
```

Use this format — omit sections with no meaningful findings:

```markdown
## Retro -- {YYYY-MM-DD}

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

## Step 4: Promote -- Route Lessons to Where They'll Be Used

This is the step that actually improves future sessions. Every finding from the
retro must be classified and promoted to the file where it will be used.

### Discover promotion targets

```bash
find . -maxdepth 3 \( -name 'CLAUDE.md' -o -name 'MEMORY.md' -o -name 'AGENTS.md' \) 2>/dev/null
MEMORY_DIR=$(echo "$PWD" | sed 's|^/||' | sed 's|/|-|g')
ls "$HOME/.claude/projects/-${MEMORY_DIR}/memory/MEMORY.md" 2>/dev/null
```

### Routing table

| Lesson type | Target |
|-------------|--------|
| Workflow rules, process conventions | `MEMORY.md` (project memory) |
| Code conventions, repo-specific rules | `CLAUDE.md` (project root) |
| Agent behavior rules | `AGENTS.md` |
| Skill gaps or missing steps | The specific skill's `SKILL.md` |
| Standing decisions (what was rejected) | `MEMORY.md` |

### For each lesson

1. **Check** if it's already captured in the target file
2. **If not captured:** add it — write it as a rule, not a narrative
3. **If already captured:** verify accuracy; update if stale
4. **For skill file edits:** propose the specific edit and ask the user to
   approve before making changes (use AskUserQuestion)

**Key rule:** The retro-log holds the story. Target files need only the
actionable rule. Do not add narrative to CLAUDE.md, MEMORY.md, or AGENTS.md.

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
| `/wk:retro` | Full 4-step retro with promotion |
| `/wk:retro "auth refactor"` | Retro focused on a specific topic |

## Requirements

- Git repository (for reviewing session changes)
- Shell access (for running git commands and discovering targets)
