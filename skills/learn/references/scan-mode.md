# Scan Mode: Mine Session Transcripts for Interruptions

Invoke as `wk-learn scan` (or auto-invoked by `wk-retro`). Scans recent session
transcripts for moments where the user interrupted the agent or told it to stop,
classifies each by affected skill, writes one learning file per finding.

## Step S1: Resolve the transcript source

Use the active runtime's native transcript provider or resource when one is
available. Never infer that a missing directory in one runtime's filesystem
means the current session has no transcript.

1. Detect the active runtime from session/tool context, or accept an explicitly
   supplied transcript provider.
2. Select turns matching the current session before widening by project and
   recency.
3. No matching runtime transcript → scan the available current-conversation
   history and emit an explicit degradation notice.
4. Neither source available → report the evidence gap; never report zero
   interruptions as a scan verdict.

See [runtime-aware transcript
selection](runtime-aware-transcript-selection.md).

### Claude Code filesystem adapter

Claude Code stores per-session transcripts at:

```bash
TRANSCRIPT_ROOT="$HOME/.claude/projects"
```

- Each project directory = the cwd path with `/` replaced by `-`.
- Each session = a `.jsonl` file; one JSON message per line.

Default to the current project (matches `$PWD` slug) and the last 7 days. Override
via `wk-learn scan --since=<N>d` or `wk-learn scan --all` (every transcript on
disk).

```bash
# Claude normalizes EVERY non-alphanumeric (/, _, ., …) to - in project dir names.
PROJECT_SLUG=$(echo "$PWD" | sed 's|[^A-Za-z0-9]|-|g')
find "$TRANSCRIPT_ROOT/$PROJECT_SLUG" -name '*.jsonl' -mtime -7 -type f 2>/dev/null
```

- **Slug-mismatch fallback:** any transform narrower than `[^A-Za-z0-9]` (e.g. only
  `/`, or `/` + `_`) silently matches nothing for a path with an unhandled separator
  — an underscore or a dotted segment (`first.last` home dir). If the slug-derived dir
  does not exist, list `$TRANSCRIPT_ROOT` and pick the entry with the longest common
  substring before reporting zero transcripts.

## Step S2: Extract interruption signals

Scan each transcript for these patterns — each marks a moment the user
redirected the agent:

- Verbatim runtime markers: `[Request interrupted by user]`,
  `[Request interrupted by user for tool use]`.
- User messages immediately following an assistant tool call whose text starts
  with stop-words: `stop`, `wait`, `no`, `don't`, `do not`, `actually`, `hold
  on`, `that's wrong`, `not that`, `revert`, `undo`.
- User corrections naming a tool or skill the agent just invoked ("you shouldn't
  have run X", "we don't use Y here").
- Permission denials surfaced as user prose (user typed a rejection rather than
  clicking deny).

Walk each `.jsonl` with `jq`. **Message text lives under `.message.content`, not
`.content`** — the top-level object carries `.type` and `.message`, and
`.message.content` is either a string or an array of typed blocks. Extracting
from `.content` returns empty → the scan silently reports zero interruptions.

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

- A transcript mixes many top-level `.type` values (`attachment`, `system`,
  `last-prompt`, `file-history-snapshot`, `permission-mode`, …). Only `user` /
  `assistant` carry conversation; filter to those two, never assume the whole
  file is conversational.
- **Zero-result guard:** if the selection yields zero `user` messages across all
  transcripts → do NOT report "no interruptions"; the extraction path is likely
  wrong for this schema version. Warn that the transcript schema looks
  unrecognised and fall back to current-conversation history. If that is
  unavailable, reconstruct corrections from `git log` + commit messages and
  label the result degraded.

Pair each interruption with the **immediately preceding assistant turn** — the
tool call, file edit, or proposed action that triggered the redirect. That
context is the learning's "What happened" body.

## Step S3: Classify each finding by affected skill

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

When two skills could fit → prefer the one closest to the agent's in-flight
action. When none fits → default to `wk-workflow`.

## Step S4: Write one learning per finding

For each classified interruption, write
`$WK_SKILLS_HOME/learnings/skills/<skill-name>/<YYYY-MM-DD>_<slug>.md` using the
same frontmatter and body shape as Step 3 — including the Step 3 `wk-` strip so
`<skill-name>` never carries the prefix. Set `type: correction` and `severity` by
impact: data loss / wrong artifact shipped → `high`; cosmetic / scope drift →
`medium`; minor clarification → `low`. Default `verified-against-source: no` — a
transcript-derived mechanism is inferred unless the turns show the artifact was
read or driven.

**HARD RULE: strip incident-specific tokens.** Do not embed session IDs,
transcript paths, exact timestamps, file paths the user did not authorize
sharing, or verbatim user prose that names third parties. Distill the principle
exactly as the main learning flow requires.

## Step S5: Deduplicate against existing learnings

Before writing each file, check whether a learning with the same `(skill, slug)`
already exists — including `.learned.md` archives. Skip duplicates. If the
existing file is unprocessed and the new finding adds evidence → append a `##
Additional evidence` bullet rather than creating a parallel file.

## Step S6: Report

After processing, print a one-line summary per skill touched:

> "📝 Scan complete: {N} interruptions captured across {M} skills.
> Run `wk-sharpen` when ready to distill."

If zero interruptions surface → say so and exit; no learning files are written
for an uneventful scan.
