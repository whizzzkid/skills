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
  version: "2026.07.31-020045"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Learn

Capture what happened during a skill run → write a structured learning file for
later distillation. Called at the end of any `wk-*` skill run.

- Argument = **calling skill's short name** (e.g., `pr-review`, `commit`,
  `workflow`). If omitted → use `unknown`.

## User-triggered invocation

Invoke immediately (before writing any file) when the user says:

- "make a learning" / "capture a learning" / "add a learning" / "learn X for skill Y"

Route to this skill, not to `$HOME/.claude/memory/`. Output → `$WK_SKILLS_HOME/learnings/skills/`,
per Step 3's HARD RULE.

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` unset, tell the user:

> "`$WK_SKILLS_HOME` is not set. Add `export WK_SKILLS_HOME=/path/to/skills`
> to your shell profile and restart your terminal."

**Stop here if the variable is missing.**

## Step 2: Reflect through 4 lenses

Review the calling skill's execution:

1. **What went wrong?** — errors, wrong assumptions, user corrections, API
   failures, unexpected behavior
2. **What was missing?** — steps the skill should have included, uncovered edge
   cases, unavailable tools
3. **What worked well?** — succeeding approaches, patterns worth reinforcing
4. **What surprised you?** — non-obvious discoveries future runs should know

If **all four lenses empty** (routine, nothing notable) → skip writing. Not every
run produces a learning.

## Step 3: Write the learning file

**HARD RULE — destination is `$WK_SKILLS_HOME/learnings/skills/`, never
`$HOME/.claude/memory/`.** Skill learnings are skill-improvement artifacts consumed
by `wk-sharpen`; not agent memory. This overrides any global "all memories live
in `$HOME/.claude/memory/`" rule in CLAUDE.md or user instructions — that global rule
applies to agent memory, not skill learnings. If `$WK_SKILLS_HOME` unset → stop
and ask the user; never reroute to memory as a fallback.

Set `SKILL_NAME` to the argument passed (e.g., `pr-review`).

**HARD RULE — strip a leading `wk-` before building the path.** Canonicalize the
directory under `learnings/skills/`, which never carries the `wk-` prefix, so a
caller passing the full name (`wk-workflow`) still lands in
`learnings/skills/workflow/`. Do not reuse the stripped token as a `skills/`
path — dir naming there is not invariant, so resolve that one by listing.

```bash
SKILL_NAME="${SKILL_NAME#wk-}"   # canonical learnings dir: never prefixed
mkdir -p "$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME"
```

**HARD RULE — route tool-specific findings to a `wk-<tool>` skill, not the
calling skill.** When a learning is specific to a named CLI tool, command, or
external app (`curl`, `jq`, `gh`, `bk`, `docker`, `git`, `aws`, …) rather than a
workflow step → set `SKILL_NAME` to that tool (e.g., `curl`), not the skill that
surfaced it. Tool quirks recur across skills and must be self-contained and
auto-loadable.

- Pick the tool over the workflow whenever the fix is "use flag X / avoid pattern
  Y with tool Z" — it generalizes beyond the run that found it.
- Create a new `wk-<tool>` skill once it would hold ≥2 distinct non-obvious
  findings for that tool; it must declare `model-invocable: true` so the agent
  auto-loads it whenever about to invoke that tool.
- Routing a `curl` quirk under the review skill that caught it (or under
  `wk-workflow`) buries it from every future `curl` user — the failure this rule
  prevents.

Write to `$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME/<YYYY-MM-DD>_<slug>.md`:

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

Use a 2–4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

**HARD RULE — mark root-cause provenance whenever the learning names a
deterministic artifact** (hook, script, CI check, linter, generator). Set
`verified-against-source: no` and prefix the root cause with `(unverified —
inferred from symptom)` unless you read or drove that artifact and confirmed the
mechanism. Use `n/a` only when no such artifact is implicated.

- A workaround that works is **not** evidence for the mechanism it avoided — it can
  succeed for an unrelated reason. "I could not reproduce it another way" is a
  symptom, not a cause.
- Never state an inferred mechanism in the declarative voice the template models;
  the field has one slot, so an unmarked guess ships with the authority of a
  finding.
- An unverified claim that slips through makes the distiller route the skill around
  a block that was never there — the failure this rule prevents.

**HARD RULE — leave a new learning untracked; never `git add` it.**

- Confirm the path matches `<YYYY-MM-DD>_<slug>.md` (ISO date, kebab slug, single
  `.md`) before writing.
- Never end it `.learned.md` — that suffix marks an already-distilled file and makes
  `wk-sharpen` skip it.
- `.githooks/check-learning-filenames.sh` accepts only
  `<YYYY-MM-DD>_<kebab>.learned.md` → staging a plain `.md` blocks the commit; the
  repo deliberately keeps undistilled learnings out of history.
- Unstage and leave untracked if already added; the distillation pass is what renames
  to `.learned.md` and commits it.

**HARD RULE — scrub all internal references before writing.** A learning file is
committed to a **public** repo. Capture the principle and root cause, never the
identity of the system it happened on. Forbidden in any learning file:

- Internal or code-named projects, services, bots, or repos.
- Hard-coded user-land file paths (home dirs, worktree paths, machine-local
  absolute paths).
- Secrets, tokens, credentials, or sensitive information.
- Employer / org names as literals → blocks the commit at
  `.githooks/scrub-staged.sh`.
- **PR / issue / run numbers** (`#<n>`, `pulls/<n>`, `repo#<n>`) — internal
  identifiers pinning a learning to a specific work item; blocked by
  `.githooks/check-pr-numbers.sh`.
- **Human usernames / reviewer logins** (`@handle`) — identify a real person;
  blocked by `.githooks/check-usernames.sh`.

Anonymize when a token is unavoidable for legibility:

- Bot / reviewer → `{bot}` / `{reviewer}`; human user → `{user}` / `{author}`;
  internal repo / project → `{repo}` / `{project}`; service → `{service}`.
- PR / issue number → `#NNN` (or `repo#NNN`); GitHub path → `pulls/{n}`,
  `issues/{n}`, `runs/{n}`. Capture the lesson, never the work-item ID.
- Employer/org token → `$EMPLOYER` / `$GITHUB_ORG`. Parameterize the **segment of
  a path**, keeping the rest: `$HOME/gitc/<employer>/` → `$HOME/gitc/$EMPLOYER` (agent
  resolves it at run time — do not drop the path).
- User-land path → repo-relative, or a generic placeholder (`/tmp/agent/…`).

A learning that only makes sense with the internal name in it is not yet
distilled — rewrite it as the org-agnostic mechanism.

## Step 4: Signal for distillation

After writing, output:

> "📝 Learning captured: `<SKILL_NAME>/<date>_<slug>.md` — distill with
> `wk-sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` → batch-distilled
into skill improvements via `wk-sharpen`. The file stays **untracked** until that
pass — a "clean tree" check must treat it as expected state, not leftover debris.

## Scan Mode

Invoke as `wk-learn scan` — mines session transcripts for user
interruptions/corrections, classifies by affected skill, writes one learning per
finding. See [scan-mode](references/scan-mode.md) for the full scan workflow
(Steps S1–S6).
