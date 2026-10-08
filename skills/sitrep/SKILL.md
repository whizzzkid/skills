---
name: wk-sitrep
description: >-
  Unified daily ops log backed by a SilverBullet workspace — replaces the
  former morning and evening standalone skills. `start` gathers the day's inbox,
  carries forward open items, and writes a live 3-column dashboard you edit in
  the browser. Optional `end` closes the day; the next `start` closes any
  unfinished prior day first. No standalone HTML files — SilverBullet renders
  everything.
argument-hint: '[start|end]'
env-vars:
  - SITREP_REPO
  - EMPLOYER
  - GITC_ROOT
allowed-tools:
  - Skill
  - Agent
  - Read
  - Write
  - "Bash(date:*)"
  - "Bash(mkdir:*)"
  - "Bash(test:*)"
  - "Bash(ls:*)"
  - "Bash(command:*)"
  - "Bash(jq:*)"
  - "Bash(sed:*)"
  - "Bash(printf:*)"
  - "Bash(open:*)"
  - "Bash(pgrep:*)"
  - "Bash(silverbullet:*)"
  - "Bash(docker *:*)"
  - "Bash(gh *:*)"
  - "Bash(git *:*)"
  - "mcp__*playwright*__browser_*"
  - "mcp__claude_ai_Slack_*__*"
  - "mcp__claude_ai_Gmail_*__*"
  - "mcp__claude_ai_Gcal_*__*"
  - "mcp__claude_ai_Granola_*__*"
  - "mcp__claude_ai_Gdrive_*__*"
  - "mcp__claude_ai_Gdocs_*__*"
  - "mcp__claude_ai_Github_*__*"
  - "mcp__claude_ai_Jira_*__*"
  - "mcp__claude_ai_Lattice_*__*"
model: sonnet
effort: high
model-invocable: false
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: "2026.08.18-210326"
  model:
    openai: gpt-5.6-terra
---

# Sitrep

Unified daily ops log backed by a SilverBullet workspace. One persistent live
page → replaces former morning/evening skills. No standalone HTML files, no
per-day live directories; dated snapshots at close.

## Sub-commands

- `/wk-sitrep start` — workday start routine.
- `/wk-sitrep end` — optional workday close routine.
- `/wk-sitrep` (no argument) — defaults to `start`; emits:
  > "Running wk-sitrep:start (default — no sub-command specified)"

## Core hard rules

- **HARD RULE — workspace-scoped output only.** All output stays in
  `$SITREP_REPO/$EMPLOYER/`. Never write sitrep files into cwd or
  `$WK_SKILLS_HOME`. Never assert a file missing without `Read`/`ls` — say
  "I have not read X", not "X is missing."
- **HARD RULE — no interactive triage.** Both sub-commands are compile-only
  (gather → render → write → open). Never call `AskUserQuestion` to
  keep/skip/resolve; user edits items in the browser directly.
- **HARD RULE — evidence connector gates.** Required connectors = every
  company-data domain in the sub-command's agent roster (source control
  excluded). Any required connector unavailable → abort publication (no write,
  no rollover, no brag). Gaps *inside* an available domain still render: label
  unavailable sources, preserve `data-done`/carry-over, withhold accrual
  artifacts until full-evidence reconciliation.

## Rendering contract

Layout, span patterns, urgency sorting, nesting constraints, and style rules:
[`references/rendering-contract.md`](references/rendering-contract.md).
Delegates HTML-block mechanics to
[`wk-silverbullet`](../silverbullet/README.md); this skill owns content
selection.

### Checkbox-span format

Canonical span + concrete toggle-handler recipe:
[`references/checkbox-span-handler.md`](references/checkbox-span-handler.md).

## Dismissed registry (cross-run de-dup)

User-resolved items vanish from `live.md` at `end` but the next `start` sweep
can rediscover them. A week-scoped JSONL registry suppresses those keys.

- Use one action-specific key per record; `start` drops gathered and carry-over
  matches from the current ISO week.
- Path, key, safe-write, validation, and `is_dismissed` recipes:
  [`references/dismissed-registry.md`](references/dismissed-registry.md).

## Step 0: Bootstrap (both sub-commands)

Resolve config → env → default for `$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT`
(`.sitrep.yml` at the working repo root wins), export `$TODAY`, `$LIVE_FILE`,
`$SNAPSHOT_FILE`, `$SNAPSHOT_URL`, `$WEEK_MEM_FILE`, `mkdir -p` their parents,
then ensure SilverBullet is serving `$SITREP_REPO` (docker deployment counts as
running; auto-start the CLI; hard-fail when neither exists). Canonical probe +
start recipes: [`references/bootstrap.md`](references/bootstrap.md).

## Sub-command: start

### Stage 0.5: Close unfinished prior day

- **HARD RULE — close before overwrite.** Prior `date:` + no valid completed-end
  state → run the full `end` flow for that date before Stage 1; failure stops
  `start`.
- Marker, legacy detection, date rebinding, retry, and restoration:
  [`references/missed-end-rollover.md`](references/missed-end-rollover.md).

### Stage 1: Load previous live.md

- Read `$LIVE_FILE` if it exists. Extract open `data-done="false"` spans as
  carry-over, completed `data-done="true"` spans as a count only.
- Legacy `⬜` / `[ ]` / `✅` / `[x]` forms are read-only compatibility
  fallbacks; canonical state is `data-done`.
- Resolve previous working day from existing `date:` frontmatter. Cross-check
  carry-overs against live external state in Stage 2.
- Resolve and read `$PREV_SNAPSHOT_FILE`; treat every `## Achievements`
  subsection as candidate Stage 4b evidence, never a freshness waiver.

### Stage 2: Parallel data gathering

Launch 5 agents in parallel. Prepend
[`references/subagent-contract.md`](references/subagent-contract.md); append
[`references/yesterday-synthesis.md`](references/yesterday-synthesis.md) to
every available-domain prompt. Separate previous-workday evidence from today's
items.

Agent roster:

- **Slack:** unread DMs/mentions needing response; open threads awaiting reply;
  announcements. ToolSearch: `"slack"`.
- **Gmail:** unread emails needing response; sent emails without reply;
  announcements. ToolSearch: `"gmail"`.
- **Calendar + Granola + Google Drive:** today's meetings with agenda docs and
  last-session Granola notes; interviews lacking a prep/scorecard block (data
  only — orchestrator creates them in Stage 2c, per
  [`wk-cal`](../cal/README.md) §Interview Prep Scan).
  ToolSearch: `"gcal"`, `"granola"`, `"gdrive"`.
- **GitHub:** PRs needing review (`--draft=false`); your open PRs with failing
  CI or review comments; assigned issues; mentions. All `gh` commands require
  `--owner="$GITHUB_ORG"`. ToolSearch: `"github"`.
  - **HARD RULE — verify authorship, never infer it** (see the canonical
    Authorship filter in Stage 4 §Code & PRs). A PR enters "Your PRs" only after
    `gh pr view --json author` confirms it; route review-requested / mentions /
    involvement to other buckets. Prevents teammate/bot PRs surfacing as own.
  - **Sweep your own unsubmitted reviews** — reviews you authored in `state:
    PENDING`, org-wide every run, never only re-checking known PRs; surface each
    as ASAP until submitted or discarded.
- **Jira + Confluence:** assigned tickets needing action; ticket mentions;
  Confluence mentions. ToolSearch: `"jira"`, `"confluence"`.

Block handling per subagent contract: OAuth soft blocks degrade with CTA.
`tool_unavailable` → replay domain in main context; still toolless after replay
= missing connector (required → abort, optional → degrade).

#### Jira full open-ticket sweep

Always run a third JQL for all open assigned tickets:

```
assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC
```

Surface `In Review` / `Ready for Review` / `Blocked` / `On Deck`, past-due
tickets, and merged-PR-but-open transition candidates. Collapse no-activity /
no-due-date tickets into one `## 🗂 Jira backlog` section.

#### Cross-tracker pending-on-me sweep

Fold assigned items from every connected tracker into one pending-on-me view:

- Compare carry-over current status against the status recorded in the previous
  `live.md`; prefix changes with `🔁 {old}→{new}`.
- Append `⏳ {N}d` to items pending beyond 7 days.
- Read native priority/severity; items without priority sort lowest.
- Apply to every connected tracker; skip only when its MCP is absent.

### Stage 2b: Auto-transition merged-PR tickets

After agents return and before writing `live.md`, close tickets already finished
(`start` only; during `end`, render merged-but-open tickets as carry-forward,
never transition):

- For each Agent 5 ticket in `In Review` / `Ready for Review` with a linked PR,
  check merge state: `gh pr view <url> --json state,merged,mergedAt`.
- If merged within last 14 days, transition to `Done`. Denial is deterministic, so
  block-register the key on first denial and skip the re-attempt on later runs:
  re-verify merge, render `🔁 blocked N days` pinned in ASAP until a manual
  transition. Never retry or fail the run.
- Render as a `data-done="true"` `⚙️ Auto-Actions` item with
  `✅ auto-transitioned to Done by agent`; never render as an open TODO.

### Stage 2c: Create missing interview prep blocks (`start` only)

Orchestrator action after agents return, before writing `live.md`. A referenced
sibling-skill flow is an action to run, not framing to describe — subagents
gather read-only; the orchestrator owns every write.

- For each interview the Calendar domain reports lacking a prep/scorecard block,
  call [`wk-cal`](../cal/README.md)'s block-creation flow: a 15-min prep block
  before, a 30-min scorecard block after (scan forward in 30-min increments when
  the immediate slot is busy).
- Before Stage 3, record the five-day interview-scan result and either created
  block links or the no-slot/write-access fallback.

### Stage 3: Compile open items

- Merge agent results with carry-over. Drop carry-overs whose external record
  shows completion; drop any item whose key `is_dismissed` for the current week.
- Write every surviving item as a `data-done="false"` checkbox span in the
  correct column. No prompts.

Content inventory, skip empty:

1. Carry-over from previous `live.md`
2. Today's Meeting Prep
3. Slack — Needs Response / Follow-ups
4. Email — Needs Response / Follow-ups
5. GitHub — PRs to Review / Your PRs / Issues
6. Jira — Tickets / Mentions
7. Confluence — Mentions

Sort and mark urgency per the rendering contract.

### Stage 4: Write live.md

Re-read `$LIVE_FILE` before writing. Preserve `data-done="true"` spans. Prefer
`Edit` over full `Write`. Write as `sitrep-row` / three `sitrep-col` divs (no
blank lines inside); frontmatter: `date`, `employer`, `generated_with`,
`generated_at`. Assign unique sequential `data-t` IDs.

- **col1:** Calendar + Slack + Email (meeting lines, prep, needs-response).
- **col2:** ASAP + Auto-Actions + GitHub + Jira.
- **col3:** Meta + Standup + This Week + Notes + Backlog.

### Stage 4b: Standup snippet

Render standup in col3 as a copy block:

Use the canonical rich-copy block verbatim from
[`references/standup-copy-block.md`](references/standup-copy-block.md).

Delegate formatting to [`wk-slack`](../slack/README.md) §Standup Snippet; this
skill owns selection.

- **HARD RULE — Yesterday is date-bounded multi-source synthesis.** Apply
  [`references/yesterday-synthesis.md`](references/yesterday-synthesis.md);
  reject prior standup/session memory as evidence.
- **Yesterday:** 3-4 highest-impact outcomes with PR URLs. **Today:** top 3-4
  ASAP items. **Blockers:** always present, `None` when empty.
- Apply [`wk-slack`](../slack/README.md) §Standup privacy filter and §Standup
  Snippet formatting. Rich body = one `<ul>` with three `<li>` branches.
- Verify skin-tone emoji (`👈🏽`/`👉🏽`) survive the write.

### Stage 5: Verify render, then open

- **HARD RULE — gate announcement on a verified render.** `browser_navigate` to
  the live URL, then `browser_evaluate` the containment assertion (3 non-empty
  `.sitrep-col`, every `.st-copy-block`/`.st-item` inside a column). Assert
  containment, not just presence — an ejected block passes a count check. On
  `false`, fix per [`wk-silverbullet`](../silverbullet/README.md) Step 6.
- Verify standup copy interaction per
  [`references/standup-copy-block.md`](references/standup-copy-block.md).
- `browser_close` the automation window before `open`.

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/live.md"
```

> "Live page ready — {X} items, {Y} meetings, {Z} carry-overs."

### Stage 6: Commit and push

Commit and push without prompt:

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📋 start $TODAY — {N} items, {M} meetings"
git -C "$SITREP_REPO" push
```

Fold auto-actions into the same commit, or a follow-up
`chore(sitrep): ✅ {action}`.

### Stage 7: Auto-launch PR reviews (`start` only)

Auto-action after the live page commits — one review worktree per PR awaiting
your review, rendered as a done ⚙️ Auto-Action.

- **Pending draft only.** Subagent follows wk-pr-review Phase 5; never submit,
  approve, or request changes — live reviews are irreversible (only PENDING is
  deletable).
- **Reserve slots for mandatory nested workers** — a parent holding the last slot
  deadlocks on the child it must spawn; serialize rather than saturate.
- Mechanics (source bucket, allowlist, local clone, nested-slot budget, per-PR
  worktree flow): [`references/auto-review.md`](references/auto-review.md).

Then invoke [`wk-learn sitrep`](../learn/README.md).

## Sub-command: end

### Stage 1: Read live.md

- Read `$LIVE_FILE`. Extract completed `data-done="true"` spans, open
  `data-done="false"` spans, notes under `## Notes`, standup data. Legacy
  checkbox glyphs are compatibility fallbacks only.
- If `$LIVE_FILE` absent, continue from agents.

### Stage 2: Parallel data gathering

Launch 7 agents in parallel. Include the gathering-subagent contract
(`references/subagent-contract.md`) verbatim.

Agent roster:

- **GitHub/git:** today's commits, PRs created/merged/reviewed, issues closed.
  Requires `$GITHUB_ORG`.
- **Calendar + Granola:** today's meetings with decisions, action items, open
  questions; tomorrow's meetings flagged for prep.
- **Slack:** unanswered DMs/mentions; notable contributions.
- **Gmail:** unreplied emails; notable outgoing emails.
- **Lattice:** pending feedback requests with deadlines; new feedback.
- **Jira + Confluence:** Jira activity; unanswered Jira comments; Confluence
  mentions. Run the full open-ticket sweep:
  `assignee = currentUser() AND statusCategory != Done`.
- **DX:** review turnaround, cycle time, deploy frequency vs team/org averages;
  improvement actions.

### Stage 3: Compile

Merge into two buckets:

- **Historical → snapshot:** user-checked done items, externally confirmed done
  items, meeting notes, achievements, feedback, DX metrics, day stats.
- **Pending → live.md:** tomorrow's prep, untracked actions, unanswered
  Slack/email/Jira/Confluence, Lattice requests, peer feedback opportunities,
  DX improvements, every externally-confirmed pending span.

Detect state by `data-done`, not glyphs. Cross-validate pending spans against
external state (GitHub merged/closed, Jira Done, Calendar occurred, Slack
replied). Report detected-done vs user-checked-done separately. Ambiguous →
pending. Drop items with no link.

### Stage 4: Write snapshot.md

Snapshot is historical only; never write pending items into it. If
`$SNAPSHOT_FILE` exists, re-read and merge — append newly completed items and
meeting notes rather than overwriting.

**Authorship filter (canonical):** include a PR as the user's only when
`gh pr view <pr> --json author` confirms author / co-author / primary approving
reviewer — carry-over lists, review queues, and prior agent reports are NOT
proof. Enumerate own PRs via `gh search prs --author @me` (add
`--merged --merged-at <range>` for wins). Applies to "Your PRs", snapshot wins,
and standup alike.

Snapshot template (front-matter + Achievements / Meeting Notes / Issues / DX /
Day Stats): [`references/snapshot-template.md`](references/snapshot-template.md).

Append QPR-worthy items to `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` with `🌟`.

### Stage 5: Rewrite live.md

Re-read `$LIVE_FILE` before rewriting. Write completed keys to `$WEEK_MEM_FILE`
(Dismissed registry). Rewrite with pending items only — drop completed spans and
date-specific FYI. Re-number `data-t` from `t1`; sort per rendering contract.

Three-column layout: **col1** tomorrow's meeting prep, **col2** carry-forward +
follow-ups + DX, **col3** notes. Frontmatter `date: {TODAY}` +
`note: "Scrubbed {N} completed items"`; `end_completed_at:` records close.

### Stage 6: Open snapshot in browser

`open "$SNAPSHOT_URL"` — announce done/carried/documented counts and brag
highlight.

### Stage 7: Distill accumulated learnings

If `$WK_SKILLS_HOME` is set and unprocessed learning files exist: process
highest severity first, cap at 5 per run, carry the rest. Invoke
[`wk-sharpen`](../sharpen/README.md) with each file as input. Do not rename
files here; [`wk-sharpen`](../sharpen/README.md) owns `.learned.md` renames.

### Stage 8: Mark complete, commit, and push

Invoke [`wk-learn sitrep`](../learn/README.md). After Stages 1–7 and learning
capture succeed, add `end_completed_at: {ISO_8601_UTC}` to `$LIVE_FILE`; a
missing marker makes the next `start` retry the close. Commit and push without
prompt:

```bash
BRAG_LOG="$SITREP_REPO/$EMPLOYER/QPR/brag-log.md"
git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE"
test ! -f "$WEEK_MEM_FILE" || git -C "$SITREP_REPO" add "$WEEK_MEM_FILE"
test ! -f "$BRAG_LOG" || git -C "$SITREP_REPO" add "$BRAG_LOG"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📸 end $TODAY — {N} done, {M} carried forward"
git -C "$SITREP_REPO" push
```

## QPR season awareness

Once-per-day quarterly-review nudge, never blocking: banner windows, placement,
and brag-log accrual — [`references/qpr-nudge.md`](references/qpr-nudge.md).

## Requirements

- Env: `$SITREP_REPO` (workspace repo path), `$EMPLOYER` (org slug for path
  scoping), `$SITREP_PORT` (SilverBullet port, default `3000`), `$GITHUB_ORG`
  (`gh` org scope), `$GITC_ROOT` (local clone root for Stage 7 reviews, default
  `$HOME/gitc`).
- `jq` (dismissed-registry JSON); `silverbullet` CLI able to serve `$SITREP_REPO`.
- MCP servers for Slack, Gmail, Calendar, Granola, Drive, Docs, GitHub, Jira, Lattice.
