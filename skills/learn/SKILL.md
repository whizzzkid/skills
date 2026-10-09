---
name: wk-learn
description: >-
  Post-completion learning capture for any wk-* skill. Call at the end of a
  skill run to reflect on what happened and write a structured learning file
  for later distillation via wk-sharpen. Pass the calling skill's short name
  as the argument (e.g., `wk-learn pr-review`). Also invoke immediately when
  the user says "make a learning", "capture a learning", "add a learning", or
  "learn X for Y" — never route these phrases to the memory system.
argument-hint: '<skill-name> | scan  (e.g., pr-review, commit, workflow, scan)'
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - "Bash(mkdir -p:*)"
  - "Bash(test -n:*)"
  - "Bash(find $HOME/.claude/projects:*)"
  - "Bash(ls $HOME/.claude/projects:*)"
  - "Bash(jq:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
env-vars:
  - WK_SKILLS_HOME
  - GITHUB_ORG
  - EMPLOYER
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Learn

Capture what happened during a skill run as a structured learning file for later distillation. Called at the end of
any `wk-*` skill run. Argument = **calling skill's short name** (e.g., `pr-review`, `commit`, `workflow`); omitted →
`unknown`.

## User-triggered invocation

Invoke immediately (before writing any file) on "make a learning" / "capture a learning" / "add a learning" / "learn X
for skill Y". Route to this skill, not to `$HOME/.claude/memory/`; output goes to `$WK_SKILLS_HOME/learnings/skills/`,
per Step 3's HARD RULE.

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is unset, tell the user:

> "`$WK_SKILLS_HOME` is not set. Add `export WK_SKILLS_HOME=/path/to/skills`
> to your shell profile and restart your terminal."

**Stop here if the variable is missing.**

## Step 2: Reflect through 4 lenses

1. **What went wrong?** — errors, wrong assumptions, user corrections, API failures, unexpected behavior.
2. **What was missing?** — steps the skill should have included, uncovered edge cases, unavailable tools.
3. **What worked well?** — succeeding approaches, patterns worth reinforcing.
4. **What surprised you?** — non-obvious discoveries future runs should know.

All four empty (routine run) → skip writing.

## Step 3: Write the learning file

**HARD RULE — destination is `$WK_SKILLS_HOME/learnings/skills/`, never `$HOME/.claude/memory/`.** Skill learnings are
skill-improvement artifacts consumed by `wk-sharpen`, not agent memory. This overrides any global "all memories live in
`$HOME/.claude/memory/`" rule in CLAUDE.md or user instructions — that rule applies to agent memory, not skill
learnings. If `$WK_SKILLS_HOME` is unset → stop and ask the user; never reroute to memory as a fallback.

Set `SKILL_NAME` to the argument passed (e.g., `pr-review`).

**HARD RULE — strip a leading `wk-` before building the path.** The directory under `learnings/skills/` never carries
the `wk-` prefix, so a caller passing `wk-workflow` still lands in `learnings/skills/workflow/`. Do not reuse the
stripped token as a `skills/` path — dir naming there is not invariant, so resolve that one by listing.

```bash
SKILL_NAME="${SKILL_NAME#wk-}"   # canonical learnings dir: never prefixed
mkdir -p "$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME"
```

**HARD RULE — route tool-specific findings to a `wk-<tool>` skill, not the calling skill.** When a learning is specific
to a named CLI tool, command, or external app (`curl`, `jq`, `gh`, `bk`, `docker`, `git`, `aws`, …) rather than a
workflow step → set `SKILL_NAME` to that tool (e.g., `curl`), not the skill that surfaced it.

- Pick the tool over the workflow whenever the fix is "use flag X / avoid pattern Y with tool Z".
- Create a new `wk-<tool>` skill once it would hold ≥2 distinct non-obvious findings for that tool; it must declare
  `model-invocable: true` so the agent auto-loads it whenever about to invoke that tool.

Write to `$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME/<YYYY-MM-DD>_<slug>.md` with a 2–4 word kebab-case slug
(e.g., `missing-null-check`, `wrong-api-endpoint`, `good-parallel-pattern`):

```markdown
---
skill: wk-<SKILL_NAME>
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
verified-against-source: <yes | no | n/a>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case; mark
`(unverified — inferred from symptom)` if not confirmed against the artifact>

**Suggested fix:** <What should change in the skill to prevent this>
```

**HARD RULE — mark root-cause provenance whenever the learning names a deterministic artifact** (hook, script, CI
check, linter, generator). Set `verified-against-source: no` and prefix the root cause with `(unverified — inferred
from symptom)` unless you read or drove that artifact and confirmed the mechanism. Use `n/a` only when no such artifact
is implicated.

- A workaround that works is **not** evidence for the mechanism it avoided — it can succeed for an unrelated reason.
  "I could not reproduce it another way" is a symptom, not a cause.
- Never state an inferred mechanism in the declarative voice the template models; an unmarked guess ships with the
  authority of a finding.

**HARD RULE — leave a new learning untracked; never `git add` it.**

- Confirm the path matches `<YYYY-MM-DD>_<slug>.md` (ISO date, kebab slug, single `.md`) before writing.
- Never end it `.learned.md` — that suffix marks an already-distilled file and makes `wk-sharpen` skip it.
- `.githooks/check-learning-filenames.sh` accepts only `<YYYY-MM-DD>_<kebab>.learned.md` → staging a plain `.md`
  blocks the commit; the repo deliberately keeps undistilled learnings out of history.
- Already added → unstage and leave untracked; the distillation pass renames to `.learned.md` and commits it.

**HARD RULE — scrub all internal references before writing.** A learning file is committed to a **public** repo.
Capture the principle and root cause, never the identity of the system it happened on. Forbidden in any learning file:

- Internal or code-named projects, services, bots, or repos.
- Hard-coded user-land file paths (home dirs, worktree paths, machine-local absolute paths).
- Secrets, tokens, credentials, or sensitive information.
- Employer / org names as literals → blocks the commit at `.githooks/scrub-staged.sh`.
- **PR / issue / run numbers** (`#<n>`, `pulls/<n>`, `repo#<n>`) — blocked by `.githooks/check-pr-numbers.sh`.
- **Human usernames / reviewer logins** (`@handle`) — blocked by `.githooks/check-usernames.sh`.

Anonymize unavoidable tokens per [anonymization-placeholders](references/anonymization-placeholders.md). A learning
that only makes sense with the internal name in it is not yet distilled — rewrite it as the org-agnostic mechanism.

## Step 4: Signal for distillation

After writing, output:

> "📝 Learning captured: `<SKILL_NAME>/<date>_<slug>.md` — distill with
> `wk-sharpen` when ready."

The file stays **untracked** until the `wk-sharpen` batch pass — a "clean tree" check must treat it as expected state,
not leftover debris.

## Scan Mode

Invoke as `wk-learn scan` — mines session transcripts for user interruptions/corrections, classifies by affected skill,
writes one learning per finding. See [scan-mode](references/scan-mode.md) for the full scan workflow (Steps S1–S6).
