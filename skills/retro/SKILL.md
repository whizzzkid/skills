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
  - "Bash(cat $HOME/.claude*:*)"
  - "Bash(find $HOME/.claude*:*)"
  - "Bash(ls $HOME/.claude*:*)"
  - "Bash(mkdir -p $HOME/.claude*:*)"
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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Session Retro

Capture session learnings and promote them globally. `/wk-retro "<topic>"` → focus the retro on that topic.

## HARD RULE: audit live capture before reconstruction

Real-time capture is a [`wk-workflow`](../workflow/README.md) activation rule: verify each correction and self-caught
error had a same-response [`wk-learn`](../learn/README.md) invocation. Retro refines and promotes; it must not be the
first capture. Missing live capture → invoke `wk-learn` now, then record the control failure.

## Paths

```
RETRO_LOG_DIR="$WK_SKILLS_HOME/learnings/retrospect"
GLOBAL_MEMORY="$HOME/.claude/memory"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
```

Retro entries → `$RETRO_LOG_DIR`, never `$HOME/.claude/memory/`; Step 4 memory writes (cross-session rules,
preferences) still target `$GLOBAL_MEMORY`.

**HARD RULE:** Write and Edit may ONLY target files under `$WK_SKILLS_HOME/learnings/retrospect/` or `$HOME/.claude/`
(memory files, MEMORY.md). Never write/edit files in the project working directory or anywhere else. Read, Glob, Grep
may access any path (read-only).

## Step 1: Review session context

```bash
git log --oneline -15
git diff HEAD~5..HEAD --stat 2>/dev/null || git diff --stat
cat "$HOME/.claude/memory/MEMORY.md" 2>/dev/null || echo "No global MEMORY.md found"
```

Also check conversation history for corrections, redirects, decisions.

## Step 1.5: Auto-mine interruptions via `wk-learn scan`

**HARD RULE:** Invoke `wk-learn scan` before reflecting: `Skill(wk-learn, args="scan")`. It extracts every user
interruption/redirect from the transcript(s), classifies each by skill, and writes learning files under
`$WK_SKILLS_HOME/learnings/skills/`. Run it before Step 2; auto mode is **not** an exemption — the scan runs every
retro.
Treat its files as Step 2 inputs: acknowledge each and, where appropriate, promote it in Step 4. Zero interruptions →
continue; reflection still covers the other lenses.

## Step 1.6: Audit capture timing

Classify every finding: **live** (the same response as the correction, redirect, or self-caught error invoked
`wk-learn`) or **reconstructed** (retro or scan made the first actionable capture). Report `live: N, reconstructed: M`.
All-reconstructed is an explicit real-time capture-control failure. Invoke every missing per-skill call now.

## Step 2: Reflect across lenses

Be specific and concrete; skip any lens with no meaningful findings: 1) where Claude got it wrong (misread, wrong
assumption, corrected output, wrong convention, missed existing code) 2) where the user corrected the approach (plan
redirected, design wrong, test revealed a gap) 3) gaps in tools, skills, or docs (missing step, uncovered case, outdated
docs) 4) decisions made and why (rejected options, tradeoffs) 5) what worked well (patterns worth reinforcing).

## Step 3: Write distilled retro entry (only if actionable)

**HARD RULE — log only when there is an actionable finding.** Write an entry only when the session surfaced at least
one skill-gap or improvement ("what could've been better"); otherwise write nothing — real-time `wk-learn` captures
already hold anything notable. Never add an entry just to record that a session ran; a sparse log is success.

**HARD RULE — one write-once file per session at
`$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>_session-<N>.md`, never
`$HOME/.claude/memory/retro-log.md`.** Write a **new** file per session, never append to an existing session file:
`wk-sharpen` distills a file once and renames it `.learned.md`, so appended content is orphaned. Create the directory if
missing: `mkdir -p "$WK_SKILLS_HOME/learnings/retrospect"`.

**HARD RULE — no timestamps, no work narrative.** In-file header is `## Session-N` and nothing else — never a time of
day, never the task/topic, never what was built. Derive N from today's existing session-file count (processed or not)
and never reuse a filename:

```bash
DIR="$WK_SKILLS_HOME/learnings/retrospect"; DAY=$(date -u +%F)
N=$(( $(ls "$DIR/${DAY}_session-"*.md 2>/dev/null | wc -l | tr -d ' ') + 1 ))
FILE="$DIR/${DAY}_session-${N}.md"
```

**HARD RULE — distilled findings only, two buckets.** Each bullet is a one-sentence actionable rule, not a story. Use
only these sections; omit either if empty (both empty → write nothing):

```markdown
## Session-N

### What worked
- [pattern worth reinforcing as a rule]

### What could've been better
- [skill-name]: [one-sentence actionable gap — folded by Step 4 wk-learn]
```

**HARD RULE — no internal references.** This is a **public** repo. Before writing, strip: resolved `$EMPLOYER` and
`$GITHUB_ORG` values; internal or code-named repos, services, bots, projects; reviewer logins, ticket IDs, commit SHAs,
PR numbers; hard-coded user-land paths (home dirs, worktree paths, machine-local absolute paths); secrets, tokens,
credentials, sensitive information. Replace with `{owner}/{repo}`, `{repo}`, `{bot}`, `{service}`, "the file", "the
reviewer", "the PR"; anonymize a user-land path to repo-relative or `/tmp/agent/…` — never commit an absolute
home/worktree path.

Run [references/validation-gate.md](references/validation-gate.md) on the draft (fixed path
`/tmp/retro-draft-wkretro.md`)
after composing it, before Write. Validation fails → stop and rewrite the offending bullet. Passes → write the new
per-session file:
`cp "$DRAFT" "$FILE"`. Never append to an existing session file.

## Step 4: Promote — distill and route globally

Distillation rules, promotion targets, per-lesson process, and the `wk-learn` contract:
[references/memory-promotion.md](references/memory-promotion.md).

**HARD RULE:** For every "What could've been better" bullet naming a skill, invoke `wk-learn` in this same retro
response — do not defer. Both the log entry and the `wk-learn` call are required; skipping either orphans the lesson.

Optional: a `Stop` hook in `$HOME/.claude/settings.json` pointing to `{SKILL_DIR}/scripts/suggest-retro.sh` prints a
retro reminder at session end (it does not auto-run the retro).

---

## Post-Completion

Invoke `wk-learn retro`.
