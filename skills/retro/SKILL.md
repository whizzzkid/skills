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
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: '2026.06.12-024027'
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

## HARD RULE: capture in real time, not only at retro

Invoke `wk-learn <affected-skill>` in the same response that
acknowledges a user correction or self-caught error — do not defer
to retro.

- Retro refines and promotes. It must not be the first capture.
- Reconstructing corrections at retro time drops precision and
  loses any correction the agent forgets between events.
- Multiple corrections in one session → multiple `wk-learn` calls,
  one per affected skill, at the moment each correction lands.
- This rule applies to the agent during the session; the retro
  flow below still runs as the consolidation pass.

## Global Paths

```
RETRO_LOG_DIR="$WK_SKILLS_HOME/learnings/retrospect"
GLOBAL_MEMORY="$HOME/.claude/memory"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
```

- Retro entries go to `$RETRO_LOG_DIR/<YYYY-MM-DD>.md` — never to `~/.claude/memory/`.
- Memory writes in Step 4 still target `$GLOBAL_MEMORY` for cross-session agent context (rules, preferences). The retrospect log carries only distilled session principles.

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

## Step 1.5: Auto-mine interruptions via `wk-learn scan`

**HARD RULE:** Invoke `wk-learn scan` before reflecting. The scan
walks the session transcript(s), extracts every moment the user
interrupted the agent or redirected it, classifies each by affected
skill, and writes per-skill learning files. This converts the retro
from memory-based recall to evidence-based capture.

- Invoke via the `Skill` tool: `Skill(wk-learn, args="scan")`.
- Run before Step 2 — the scan's findings feed the reflection.
- Auto mode is **not** an exemption. The scan runs every retro.
- If the scan finds zero interruptions, continue to Step 2; the
  reflection still has the other four lenses to cover.

The scan emits its own learning files under
`$WK_SKILLS_HOME/learnings/skills/`. Treat those files as inputs to
Step 2 — each one is a candidate finding the retro should
acknowledge and, where appropriate, promote globally in Step 4.

## Step 2: Reflect Across Lenses

Work through each lens. Retro uses 5 lenses — a superset of wk-learn's 4 —
adding a "What Worked" lens to reinforce good patterns. Be specific and
concrete; vague observations are not useful. If a lens has no meaningful
findings, skip it entirely.

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

**HARD RULE:** Write and Edit tools may ONLY target files under
`$WK_SKILLS_HOME/learnings/retrospect/` or `~/.claude/` (memory files, MEMORY.md).
Never write or edit files in the project working directory or anywhere else on
the filesystem.

Read, Glob, and Grep may access any path (read-only).

## Step 3: Write Distilled Retro Entry (only if actionable)

**HARD RULE — log only when there is an actionable finding.** Write a retro
entry only when the session surfaced at least one skill-gap or improvement
("what could've been better"). No skill-gap → write nothing; the real-time
`wk-learn` captures already hold anything notable. Never add an entry just to
record that a session ran. Retro-log volume should trend **down** as the system
matures — a sparse log is success, not a gap to fill.

**HARD RULE — destination is `$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>.md`,
never `~/.claude/memory/retro-log.md`.** The retrospect log is a skill-improvement
artifact; the memory store is for cross-session agent context.

- Create the directory if missing: `mkdir -p "$WK_SKILLS_HOME/learnings/retrospect"`.
- Append to today's file if it exists; otherwise create.

**HARD RULE — no timestamps, no work narrative.** The section header is
`## Session-N` and nothing else — never a time of day, never the task/topic,
never what was built. The retro records *findings*, not *activity*. Derive N:

```bash
FILE="$WK_SKILLS_HOME/learnings/retrospect/$(date -u +%F).md"
N=$(( $(grep -c '^## Session-' "$FILE" 2>/dev/null || echo 0) + 1 ))
```

**HARD RULE — distilled findings only, two buckets.** Each bullet is a one-
sentence actionable rule, not a story. Use only these two sections; omit either
if empty (and if both are empty, write nothing per the rule above):

```markdown
## Session-N

### What worked
- [pattern worth reinforcing as a rule]

### What could've been better
- [skill-name]: [one-sentence actionable gap — folded by Step 4 wk-learn]
```

**HARD RULE — no internal references.** This is a **public** repo; the retro
captures principles, not the identity of the system. Before writing, strip:

- The resolved value of `$EMPLOYER` and `$GITHUB_ORG` (env vars).
- Any internal or code-named repo, service, bot, or project.
- Reviewer logins, ticket IDs, commit SHAs, PR numbers.
- Hard-coded user-land file paths (home dirs, worktree paths, machine-local
  absolute paths).
- Secrets, tokens, credentials, or sensitive information.

Replace with generic placeholders: `{owner}/{repo}`, `{repo}`, `{bot}`,
`{service}`, "the file", "the reviewer", "the PR". Anonymize a user-land path to
repo-relative or `/tmp/agent/…` — never commit an absolute home/worktree path.

### Validation gate (run after composing the draft, before Write)

```bash
# Use a FIXED temp path, not $$ — each Bash tool call is a new subprocess,
# so $$ differs between the write call and a later read/sed call and the
# file is not found. A fixed slug survives across tool invocations.
DRAFT=/tmp/retro-draft-wkretro.md
# write the proposed entry to $DRAFT first
# Guard: an empty/unset $DRAFT appends nothing and passes every grep below
# silently — fail loudly instead of writing a blank entry.
[[ -s "$DRAFT" ]] || { echo "FAIL: draft is empty — refusing to append a blank retro entry"; exit 1; }
DENY="$(printenv EMPLOYER):$(printenv GITHUB_ORG)"
echo "$DENY" | tr ':' '\n' | grep -v '^$' > /tmp/retro-deny-wkretro.txt
if grep -iF -f /tmp/retro-deny-wkretro.txt "$DRAFT" 2>/dev/null; then
  echo "FAIL: forbidden employer/org token in draft"; exit 1
fi
# user-land absolute paths (home dir / worktree) must be anonymized
if grep -nE '(/Users/|/home/)[a-z._-]+/|'"$HOME"'/' "$DRAFT" 2>/dev/null; then
  echo "FAIL: user-land absolute path in draft — anonymize to repo-relative or /tmp/agent/…"; exit 1
fi
# no time-of-day stamps — the header is Session-N, not a clock time
if grep -nE '\b[0-9]{1,2}:[0-9]{2}\b|UTC' "$DRAFT" 2>/dev/null; then
  echo "FAIL: timestamp in retro entry — use 'Session-N', not a time of day"; exit 1
fi
```

- Stop and rewrite the offending bullet if validation fails.
- Append to the dated file only after validation passes.

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

For the memory file frontmatter schema and format, see the "Step 3: Write the
learning file" section of the `wk-learn` skill — retro uses the same format.

### For each lesson

1. **Distill** the finding into an actionable rule (see distillation rules above).
2. **Check** if it's already captured in a global memory file or MEMORY.md.
3. **If not captured:** create a memory file and add to MEMORY.md index.
4. **If already captured:** verify accuracy; update if stale.
5. **For skill file edits:** propose the specific edit and ask the user to
   approve before making changes (use AskUserQuestion).

### HARD RULE — invoke `wk-learn` per skill gap (do not stop at the log entry)

For every bullet under **What could've been better** that names a skill,
invoke `wk-learn` in this same retro response — do not defer:

```
Skill(wk-learn, args="<skill-name>")
```

- Writing the distilled bullet to the retrospect log is the narrative record.
- Invoking `wk-learn` is the actionable record routed to the per-skill learning
  queue for `wk-sharpen` to fold into the target SKILL.md.
- Both are required. Skipping the `wk-learn` call orphans the lesson — the
  retrospect log is read by humans, not by the sharpen pipeline.
- One `wk-learn` call per affected skill, not one per session.

After invoking, note in the retro entry which skills were routed to `wk-learn`.

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
