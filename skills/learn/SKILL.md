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
  - "Bash(find ~/.claude/projects:*)"
  - "Bash(ls ~/.claude/projects:*)"
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
  version: '2026.06.10-194634'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Learn

Capture what happened during a skill run and write a structured learning file
for later distillation. Called at the end of any `wk-*` skill run.

The argument is the **calling skill's short name** (e.g., `pr-review`,
`commit`, `workflow`). If omitted, use `unknown`.

## User-triggered invocation

Invoke immediately (before writing any file) when the user says:

- "make a learning"
- "capture a learning"
- "add a learning"
- "learn X for skill Y"

Route these phrases to this skill, not to `~/.claude/memory/`.
Output goes to `$WK_SKILLS_HOME/learnings/skills/`, per Step 3's HARD RULE.

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, tell the user:

> "`$WK_SKILLS_HOME` is not set. Add `export WK_SKILLS_HOME=/path/to/skills`
> to your shell profile and restart your terminal."

**Stop here if the variable is missing.**

## Step 2: Reflect through 4 lenses

Review what happened during the calling skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections, API
   failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge cases
   not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs should
   know about

If **all four lenses are empty** (routine execution, nothing notable), skip
writing — not every run produces a learning.

## Step 3: Write the learning file

**HARD RULE — destination is `$WK_SKILLS_HOME/learnings/skills/`, never
`~/.claude/memory/`.** Skill learnings are skill-improvement artifacts
consumed by `wk-sharpen`; they are not agent memory. This destination
overrides any global "all memories live in `~/.claude/memory/`" rule
in CLAUDE.md or user instructions — the global rule applies to agent
memory, not to skill learnings. If `$WK_SKILLS_HOME` is unset, stop
and ask the user; never reroute to memory as a fallback.

Set `SKILL_NAME` to the argument passed (e.g., `pr-review`).

**HARD RULE — strip a leading `wk-` before building the path.** The
directory under `learnings/skills/` must match the skill's directory
name in `skills/`, which never carries the `wk-` prefix (the prefix
lives only in the `name:` frontmatter field). A caller that passes the
full skill name (`wk-workflow`) must still land in `learnings/skills/workflow/`.

```bash
SKILL_NAME="${SKILL_NAME#wk-}"   # normalize: directory never carries the prefix
mkdir -p "$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME"
```

**HARD RULE — route tool-specific findings to a `wk-<tool>` skill, not the
calling skill.** When a learning is specific to a named CLI tool, command, or
external app (`curl`, `jq`, `gh`, `bk`, `docker`, `git`, `aws`, …) rather than
to a workflow step, set `SKILL_NAME` to that tool (e.g., `curl`), not the skill
that happened to surface it. Tool quirks recur across many skills and must be
self-contained and auto-loadable.

- Pick the tool over the workflow whenever the fix is "use flag X / avoid
  pattern Y with tool Z" — it generalizes beyond the run that found it.
- A new `wk-<tool>` skill is worth creating once it would hold ≥2 distinct
  non-obvious findings for that tool; it must declare `model-invocable: true`
  so the agent auto-loads it whenever it is about to invoke that tool.
- Routing a `curl` quirk under the review skill that caught it (or under
  `wk-workflow`) buries it from every future `curl` user — that is the
  failure this rule prevents.

Write to `$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME/<YYYY-MM-DD>_<slug>.md`:

```markdown
---
skill: wk-<SKILL_NAME>
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2–4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

**HARD RULE — scrub all internal references before writing.** A learning file
is committed to a **public** repo. Capture the principle and root cause, never
the identity of the system it happened on. Forbidden in any learning file:

- Internal or code-named projects, services, bots, or repos.
- Hard-coded user-land file paths (home dirs, worktree paths, machine-local
  absolute paths).
- Secrets, tokens, credentials, or sensitive information.
- Employer / org names as literals (blocks the commit at
  `.githooks/scrub-staged.sh`).
- **PR / issue / run numbers** (`#<n>`, `pulls/<n>`, `repo#<n>`) — internal
  identifiers that pin a learning to a specific work item; blocked by
  `.githooks/check-pr-numbers.sh`.
- **Human usernames / reviewer logins** (`@handle`) — identify a real
  person; blocked by `.githooks/check-usernames.sh`.

Anonymize when a token is unavoidable for legibility:

- Bot / reviewer → `{bot}` / `{reviewer}`; human user → `{user}` / `{author}`;
  internal repo / project → `{repo}` / `{project}`; service → `{service}`.
- PR / issue number → `#NNN` (or `repo#NNN`); GitHub path → `pulls/{n}`,
  `issues/{n}`, `runs/{n}`. Capture the lesson, never the work-item ID.
- Employer/org token → `$EMPLOYER` / `$GITHUB_ORG`. Parameterize the **segment
  of a path**, keeping the rest: `~/gitc/<employer>/` → `~/gitc/$EMPLOYER` (the
  agent resolves it at run time — do not drop the path).
- User-land path → repo-relative, or a generic placeholder (`/tmp/agent/…`).

A learning that only makes sense with the internal name in it is not yet
distilled — rewrite it as the org-agnostic mechanism.

## Step 4: Signal for distillation

After writing, output:

> "📝 Learning captured: `<SKILL_NAME>/<date>_<slug>.md` — distill with
> `wk-sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk-sharpen`.

## Scan Mode: mine session transcripts for interruptions

Invoke as `wk-learn scan` (or auto-invoked by `wk-retro`). Scans
recent session transcripts for moments where the user interrupted
the agent or told it to stop, classifies each by the affected skill,
and writes one learning file per finding.

### Step S1: Locate transcripts

Claude Code stores per-session transcripts at:

```bash
TRANSCRIPT_ROOT="$HOME/.claude/projects"
```

- Each project directory is the cwd path with `/` replaced by `-`.
- Each session is a `.jsonl` file; one JSON message per line.

Default to the current project (matches `$PWD` slug) and the last 7
days of transcripts. Override via `wk-learn scan --since=<N>d` or
`wk-learn scan --all` (every transcript on disk).

```bash
PROJECT_SLUG=$(echo "$PWD" | sed 's|/|-|g')
find "$TRANSCRIPT_ROOT/$PROJECT_SLUG" -name '*.jsonl' \
  -mtime -7 -type f 2>/dev/null
```

### Step S2: Extract interruption signals

For each transcript, scan messages for these patterns — each marks a
moment the user redirected the agent:

- Verbatim runtime markers: `[Request interrupted by user]`,
  `[Request interrupted by user for tool use]`.
- User messages immediately following an assistant tool call whose
  text starts with stop-words: `stop`, `wait`, `no`, `don't`, `do not`,
  `actually`, `hold on`, `that's wrong`, `not that`, `revert`, `undo`.
- User corrections that name a tool or skill the agent just invoked
  ("you shouldn't have run X", "we don't use Y here").
- Permission denials surfaced as user prose (the user typed a
  rejection rather than clicking deny).

Walk each `.jsonl` with `jq`. **Message text lives under
`.message.content`, not `.content`** — the top-level object carries
`.type` and `.message`, and `.message.content` is either a string or an
array of typed blocks. Extracting from `.content` returns empty and the
scan silently reports zero interruptions.

```bash
# Select conversational turns, then pull text from the correct path.
jq -rc '
  select(.type == "user" or .type == "assistant") |
  { type,
    text: ( .message.content
            | if type == "array" then (map(select(.type=="text") | .text) | join(" "))
              elif type == "string" then .
              else "" end ) }
' "$f"
```

- A transcript mixes many top-level `.type` values
  (`attachment`, `system`, `last-prompt`, `file-history-snapshot`,
  `permission-mode`, …). Only `user` / `assistant` carry conversation;
  filter to those two, never assume the whole file is conversational.
- **Zero-result guard:** if the selection yields zero `user` messages
  across all transcripts, do NOT report "no interruptions" — the
  extraction path is likely wrong for this schema version. Warn that
  the transcript schema looks unrecognised and fall back to
  reconstructing corrections from `git log` + commit messages, which
  is schema-independent.

Pair each interruption with the **immediately preceding assistant
turn** — the tool call, file edit, or proposed action that triggered
the redirect. That context is the learning's "What happened" body.

### Step S3: Classify each finding by affected skill

For every interruption, decide which skill needs to learn from it:

| Signal in the preceding turn | Likely skill |
|------------------------------|--------------|
| `gh pr create` / `gh pr edit` | `wk-pr` |
| `gh pr review` / inline comment payload | `wk-pr-review` |
| `git commit` / `git push` | `wk-commit` |
| `git rebase` / `git merge` / base-branch sync | `wk-pr-update` |
| Resolving reviewer threads | `wk-pr-resolve` |
| `bk` CLI / Buildkite URLs | `wk-buildkite` |
| `curl` / `jq` / `gh` / `git` / `aws` tool quirk | `wk-<tool>` (per the tool-routing HARD RULE) |
| `docker` commands / Dockerfile edits | `wk-docker` |
| Writing tests / mocks / fixtures | `wk-testing-skeleton` |
| Editing a `SKILL.md` | `wk-sharpen` |
| Daily sitrep dashboards | `wk-sitrep` |
| No specific skill — general agent behavior | `wk-workflow` |

When two skills could fit, prefer the one closest to the agent's
in-flight action. When none fits, default to `wk-workflow`.

### Step S4: Write one learning per finding

For each classified interruption, write
`$WK_SKILLS_HOME/learnings/skills/<skill-name>/<YYYY-MM-DD>_<slug>.md`
using the same frontmatter and body shape as Step 3 above —
including the Step 3 `wk-` strip so `<skill-name>` never carries the
prefix. Set
`type: correction` and `severity` based on impact (data loss / wrong
artifact shipped → `high`; cosmetic / scope drift → `medium`; minor
clarification → `low`).

**HARD RULE: strip incident-specific tokens.** Do not embed session
IDs, transcript paths, exact timestamps, file paths the user did
not authorize sharing, or verbatim user prose that names third
parties. Distill the principle exactly as the main learning flow
requires.

### Step S5: Deduplicate against existing learnings

Before writing each file, check whether a learning with the same
`(skill, slug)` already exists — including `.learned.md` archives.
Skip duplicates. If the existing file is unprocessed and the new
finding adds evidence, append a `## Additional evidence` bullet
rather than creating a parallel file.

### Step S6: Report

After processing, print a one-line summary per skill touched:

> "📝 Scan complete: {N} interruptions captured across {M} skills.
> Run `wk-sharpen` when ready to distill."

If zero interruptions surface, say so and exit — no learning files
are written for an uneventful scan.
