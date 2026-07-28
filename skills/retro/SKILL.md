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
  version: "2026.07.28-171101"
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Session Retro

Structured retrospective → captures session learnings + promotes them globally
so ALL future sessions benefit, regardless of project. Run at end of a work
session or after a significant task.

## HARD RULE: capture in real time, not only at retro

Invoke `wk-learn <affected-skill>` in the same response that acknowledges a user
correction or self-caught error — do not defer to retro.

- Retro refines and promotes; it must not be the first capture.
- Reconstructing corrections at retro time drops precision → loses any correction
  the agent forgets between events.
- Multiple corrections in one session → multiple `wk-learn` calls, one per affected
  skill, at the moment each correction lands.
- **Self-caught errors count, not only user corrections.** Discovering a bug,
  finding a missing check, or correcting your own code mid-task triggers an
  immediate `wk-learn` in that same response — before, alongside, or after the
  fix commit. Deferring a self-caught discovery to retro collapses a multi-step
  diagnosis into one vague sentence and loses the exact error mode. (This is a
  recurring miss: the generic "self-caught error" mention above did not steer, so
  it is called out explicitly here.)
- Rule applies to the agent during the session; the retro flow below still runs as
  the consolidation pass.

## Global Paths

```
RETRO_LOG_DIR="$WK_SKILLS_HOME/learnings/retrospect"
GLOBAL_MEMORY="$HOME/.claude/memory"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
```

- Retro entries → `$RETRO_LOG_DIR/<YYYY-MM-DD>_session-<N>.md` — one **write-once
  file per session**, never `$HOME/.claude/memory/`.
- Step 4 memory writes still target `$GLOBAL_MEMORY` for cross-session agent context
  (rules, preferences). The retrospect log carries only distilled session principles.

## Step 1: Review Session Context

Gather what happened this session:

```bash
git log --oneline -15
git diff HEAD~5..HEAD --stat 2>/dev/null || git diff --stat
```

Read global MEMORY.md for prior context:

```bash
cat "$HOME/.claude/memory/MEMORY.md" 2>/dev/null || echo "No global MEMORY.md found"
```

Also check conversation history for corrections, redirects, decisions.

## Step 1.5: Auto-mine interruptions via `wk-learn scan`

**HARD RULE:** Invoke `wk-learn scan` before reflecting. The scan walks session
transcript(s), extracts every moment the user interrupted or redirected the agent,
classifies each by affected skill, and writes per-skill learning files →
evidence-based capture instead of memory-based recall.

- Invoke via `Skill` tool: `Skill(wk-learn, args="scan")`.
- Run before Step 2 — scan findings feed the reflection.
- Auto mode is **not** an exemption. The scan runs every retro.
- Zero interruptions → continue to Step 2; reflection still covers the other four
  lenses.

Scan emits learning files under `$WK_SKILLS_HOME/learnings/skills/`. Treat those as
inputs to Step 2 — each is a candidate finding the retro should acknowledge and,
where appropriate, promote globally in Step 4.

## Step 2: Reflect Across Lenses

Work each lens. Retro uses 5 lenses — superset of wk-learn's 4, adding "What Worked"
to reinforce good patterns. Be specific and concrete; vague observations are useless.
Skip any lens with no meaningful findings.

- **Lens 1 — Where Claude got it wrong:** misread a file / wrong assumption?
  Produced output the user corrected? Followed a convention that was wrong? Missed
  something obvious already in the codebase?
- **Lens 2 — Where the user corrected the approach:** redirected the plan mid-execution?
  Design wrong, only clear during implementation? Test/experiment revealed a gap?
- **Lens 3 — Gaps in tools, skills, or docs:** step missing from a skill's instructions?
  Case not covered by existing patterns? Real scenario exposed something a skill didn't
  account for? Docs outdated or incomplete?
- **Lens 4 — Decisions made (and why):** non-obvious choices this session? What was
  explicitly rejected, and why? Tradeoffs accepted?
- **Lens 5 — What worked well:** what did the agent get right without correction? Which
  parts felt smooth? Good patterns worth reinforcing?

## File Access Rules

**HARD RULE:** Write and Edit may ONLY target files under
`$WK_SKILLS_HOME/learnings/retrospect/` or `$HOME/.claude/` (memory files, MEMORY.md).
Never write/edit files in the project working directory or anywhere else.

Read, Glob, Grep may access any path (read-only).

## Step 3: Write Distilled Retro Entry (only if actionable)

**HARD RULE — log only when there is an actionable finding.** Write a retro entry
only when the session surfaced at least one skill-gap or improvement ("what could've
been better"). No skill-gap → write nothing; real-time `wk-learn` captures already
hold anything notable. Never add an entry just to record that a session ran. Retro-log
volume should trend **down** as the system matures — a sparse log is success, not a gap.

**HARD RULE — one write-once file per session at
`$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>_session-<N>.md`, never
`$HOME/.claude/memory/retro-log.md`.** The retrospect log is a skill-improvement
artifact; the memory store is for cross-session agent context.

- Write a **new** file per session — never append to an existing session file. A
  write-once file is distilled exactly once and renamed `.learned.md` by `wk-sharpen`;
  appending later sessions to a shared daily file orphans their content (file is already
  distilled and never re-read).
- Create the directory if missing: `mkdir -p "$WK_SKILLS_HOME/learnings/retrospect"`.

**HARD RULE — no timestamps, no work narrative.** In-file header is `## Session-N` and
nothing else — never a time of day, never the task/topic, never what was built. The retro
records *findings*, not *activity*. Derive N from today's existing session-file count
(processed or not) and never reuse a filename:

```bash
DIR="$WK_SKILLS_HOME/learnings/retrospect"; DAY=$(date -u +%F)
N=$(( $(ls "$DIR/${DAY}_session-"*.md 2>/dev/null | wc -l | tr -d ' ') + 1 ))
FILE="$DIR/${DAY}_session-${N}.md"
```

**HARD RULE — distilled findings only, two buckets.** Each bullet is a one-sentence
actionable rule, not a story. Use only these two sections; omit either if empty (and if
both are empty, write nothing per the rule above):

```markdown
## Session-N

### What worked
- [pattern worth reinforcing as a rule]

### What could've been better
- [skill-name]: [one-sentence actionable gap — folded by Step 4 wk-learn]
```

**HARD RULE — no internal references.** This is a **public** repo; the retro captures
principles, not the identity of the system. Before writing, strip:

- Resolved value of `$EMPLOYER` and `$GITHUB_ORG` (env vars).
- Any internal or code-named repo, service, bot, or project.
- Reviewer logins, ticket IDs, commit SHAs, PR numbers.
- Hard-coded user-land file paths (home dirs, worktree paths, machine-local absolute paths).
- Secrets, tokens, credentials, or sensitive information.

Replace with generic placeholders: `{owner}/{repo}`, `{repo}`, `{bot}`, `{service}`,
"the file", "the reviewer", "the PR". Anonymize a user-land path to repo-relative or
`/tmp/agent/…` — never commit an absolute home/worktree path.

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
- Write the new per-session file (`$FILE`) only after validation passes —
  `cp "$DRAFT" "$FILE"`. Never append to an existing session file.

## Step 4: Promote — Distill and Route Globally

The step that actually improves future sessions. Every finding must be **distilled**
into a concise, actionable rule and promoted **globally** so it applies across all
projects and sessions.

### Distillation rules

Before writing anything, distill each finding:

1. **Strip the narrative.** "During the auth refactor Claude assumed the middleware
   used Express but it was Koa" → "Verify the framework before assuming middleware patterns."
2. **Generalize.** Remove project-specific details unless the lesson only applies to one
   project. Prefer universal principles.
3. **Make it actionable.** Each promoted item is a rule someone can follow, not a story.
4. **One sentence per rule.** If it needs more, it's two rules.

### Promotion targets

All targets are **global** (user-level), not project-scoped:

| Lesson type | Target |
|-------------|--------|
| Workflow rules, process preferences | `$HOME/.claude/memory/MEMORY.md` (global memory index) + individual memory file |
| Agent behavior, approach corrections | `$HOME/.claude/memory/` (as a `feedback` type memory file) |
| Standing decisions (what was rejected) | `$HOME/.claude/memory/` (as a `feedback` type memory file) |
| User preferences, collaboration style | `$HOME/.claude/memory/` (as a `user` type memory file) |
| Skill gaps or missing steps | Invoke `wk-learn <skill-name>` to write a learning file — `wk-sharpen` batch mode will distill it on the next run |

For the memory file frontmatter schema and format, see the "Step 3: Write the learning
file" section of the `wk-learn` skill — retro uses the same format.

### For each lesson

1. **Distill** into an actionable rule (see distillation rules above).
2. **Check** if already captured in a global memory file or MEMORY.md.
3. **If not captured:** create a memory file and add to MEMORY.md index.
4. **If already captured:** verify accuracy; update if stale.
5. **For skill file edits:** propose the specific edit and ask the user to approve before
   making changes (use AskUserQuestion).

### HARD RULE — invoke `wk-learn` per skill gap (do not stop at the log entry)

For every bullet under **What could've been better** that names a skill, invoke `wk-learn`
in this same retro response — do not defer:

```
Skill(wk-learn, args="<skill-name>")
```

- The distilled bullet in the retrospect log is the narrative record.
- The `wk-learn` invocation is the actionable record routed to the per-skill learning queue
  for `wk-sharpen` to fold into the target SKILL.md.
- Both are required. Skipping the `wk-learn` call orphans the lesson — the retrospect log is
  read by humans, not by the sharpen pipeline.
- One `wk-learn` call per affected skill, not one per session.
- **Compaction recovery:** if the session resumes from a compaction summary that
  mentions an in-progress retro, first verify each "What could've been better"
  bullet already got its `wk-learn` call; if not, make them before any other work.
  The summary reliably carries the retro entry — use it as the source of truth for
  which skills still need a call. The "same response" contract breaks when
  compaction truncates the retro response, silently dropping the calls.

After invoking, note in the retro entry which skills were routed to `wk-learn`.

## Optional: Stop Hook

A Stop hook can remind you to run a retro at session end. Optional — the skill works
fine as a manual invocation.

### Install

Add the following to `$HOME/.claude/settings.json` (or project
`.claude/settings.local.json`), replacing `{SKILL_DIR}` with the absolute path to this
skill's directory:

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

The script prints a reminder at session end. It does not auto-run the retro — control
stays with the user.

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
