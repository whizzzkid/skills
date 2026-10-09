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
  version: "2026.10.09-003641"
  model:
    openai: gpt-5.6-terra
---

# Sitrep

Unified daily ops log backed by a SilverBullet workspace. One persistent live
page; dated snapshots at close. No standalone HTML files.

## Sub-commands

- `/wk-sitrep start` — workday start.
- `/wk-sitrep end` — optional workday close.
- `/wk-sitrep` (no arg) — defaults to `start`.

## Core hard rules

- **Workspace-scoped output only.** All output stays in `$SITREP_REPO/$EMPLOYER/`. Never write into cwd or `$WK_SKILLS_HOME`. Never assert missing without `Read`/`ls`.
- **No interactive triage.** Compile-only (gather → render → write → open). Never `AskUserQuestion`; user edits in browser.
- **Evidence connector gates.** Required connectors = every company-data domain in agent roster (source control excluded). Any unavailable → abort publication. Gaps inside available domains → label, preserve `data-done`/carry-over, withhold accrual artifacts.

## Rendering contract

Layout, spans, urgency, nesting, styles: [`references/rendering-contract.md`](references/rendering-contract.md). HTML-block mechanics delegated to [`wk-silverbullet`](../silverbullet/README.md).

### Checkbox-span format

Canonical span + toggle handler: [`references/checkbox-span-handler.md`](references/checkbox-span-handler.md).

## Dismissed registry

Week-scoped JSONL suppresses user-resolved items across runs. Path, key, safe-write, validation: [`references/dismissed-registry.md`](references/dismissed-registry.md).

## Step 0: Bootstrap (both sub-commands)

Resolve `$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT` (`.sitrep.yml` wins), export `$TODAY`, `$LIVE_FILE`, `$SNAPSHOT_FILE`, `$SNAPSHOT_URL`, `$WEEK_MEM_FILE`, `mkdir -p` parents, ensure SilverBullet serving. Recipes: [`references/bootstrap.md`](references/bootstrap.md).

## Sub-command: start

### Stage 0.5: Close unfinished prior day

**HARD RULE — close before overwrite.** Prior `date:` with no valid end state → full `end` flow first; failure stops `start`. Details: [`references/missed-end-rollover.md`](references/missed-end-rollover.md).

### Stage 1: Load previous live.md

Read `$LIVE_FILE`. Extract open `data-done="false"` as carry-over, completed as count. Canonical state is `data-done` (legacy glyphs read-only). Resolve previous working day from frontmatter. Read `$PREV_SNAPSHOT_FILE`; treat `## Achievements` as candidate evidence, never freshness waiver.

### Stage 2: Parallel data gathering

Launch 5 agents. Prepend [`references/subagent-contract.md`](references/subagent-contract.md); append [`references/yesterday-synthesis.md`](references/yesterday-synthesis.md). Separate previous-workday from today.

Agent roster:

- **Slack:** unread DMs/mentions, open threads, announcements. ToolSearch: `"slack"`.
- **Gmail:** unread needing response, sent without reply, announcements. ToolSearch: `"gmail"`.
- **Calendar + Granola + Drive:** today's meetings with agendas and notes; interviews lacking prep/scorecard (data only — Stage 2c creates). ToolSearch: `"gcal"`, `"granola"`, `"gdrive"`.
- **GitHub:** PRs needing review (`--draft=false`), your open PRs with failing CI/comments, assigned issues, mentions. All `gh` requires `--owner="$GITHUB_ORG"`. ToolSearch: `"github"`.
  - **HARD RULE — verify authorship** via `gh pr view --json author`, never infer. Sweep unsubmitted reviews (`state: PENDING`, org-wide).
- **Jira + Confluence:** assigned tickets, mentions, Confluence mentions. ToolSearch: `"jira"`, `"confluence"`.

Block handling: OAuth soft blocks degrade with CTA. `tool_unavailable` → replay in main; still toolless = missing connector.

#### Jira full open-ticket sweep

Always: `assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC`. Surface `In Review`/`Blocked`/`On Deck`, past-due, merged-but-open candidates. No-activity tickets → `## 🗂 Jira backlog`.

#### Cross-tracker pending-on-me sweep

Fold all trackers into one view. Compare carry-over status vs previous `live.md`; prefix changes `🔁 {old}→{new}`. Append `⏳ {N}d` for >7 days. Sort by native priority (missing → lowest).

### Stage 2b: Auto-transition merged-PR tickets

Before writing `live.md` (`start` only): tickets in `In Review`/`Ready for Review` with linked PR → check merge state. Merged within 14 days → transition to `Done`. Denial → block-register key, render `🔁 blocked N days` in ASAP. Render as `data-done="true"` `⚙️ Auto-Actions`.

### Stage 2c: Create missing interview prep blocks

Per interview lacking prep/scorecard → [`wk-cal`](../cal/README.md) block-creation: 15-min prep before, 30-min scorecard after (scan forward on busy slots).

### Stage 3: Compile open items

Merge agent results + carry-over. Drop completed + dismissed. Write survivors as `data-done="false"` spans. Content inventory (skip empty): Carry-over, Meeting Prep, Slack, Email, GitHub, Jira, Confluence. Sort/mark urgency per rendering contract.

### Stage 4: Write live.md

Re-read `$LIVE_FILE`. Preserve `data-done="true"` spans. Prefer `Edit` over `Write`. Three-column `sitrep-row`/`sitrep-col`; frontmatter: `date`, `employer`, `generated_with`, `generated_at`. Sequential `data-t` IDs.

- **col1:** Calendar + Slack + Email
- **col2:** ASAP + Auto-Actions + GitHub + Jira
- **col3:** Meta + Standup + This Week + Notes + Backlog

### Stage 4b: Standup snippet

Render in col3 using canonical rich-copy block from [`references/standup-copy-block.md`](references/standup-copy-block.md). Formatting via [`wk-slack`](../slack/README.md) §Standup Snippet.

- **HARD RULE — Yesterday is date-bounded multi-source synthesis.** Apply [`references/yesterday-synthesis.md`](references/yesterday-synthesis.md); reject prior standup/session memory.
- **Yesterday:** 3-4 highest-impact outcomes with PR URLs. **Today:** top 3-4 ASAP. **Blockers:** always present, `None` when empty.
- Apply `wk-slack` privacy filter + formatting. Rich body = `<ul>` with three `<li>`. Verify skin-tone emoji survive write.

### Stage 5: Verify render, then open

**HARD RULE — gate on verified render.** `browser_navigate` → `browser_evaluate` containment (3 non-empty `.sitrep-col`, every `.st-copy-block`/`.st-item` inside a column). `false` → fix per `wk-silverbullet` Step 6. Verify standup copy per [`references/standup-copy-block.md`](references/standup-copy-block.md). `browser_close` before `open`.

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/live.md"
```

> "Live page ready — {X} items, {Y} meetings, {Z} carry-overs."

### Stage 6: Commit and push

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📋 start $TODAY — {N} items, {M} meetings"
git -C "$SITREP_REPO" push
```

### Stage 7: Auto-launch PR reviews

One review worktree per PR awaiting review, rendered as done `⚙️ Auto-Action`. Pending draft only — never submit/approve/request changes. Reserve slots for nested workers. Mechanics: [`references/auto-review.md`](references/auto-review.md). Then invoke `wk-learn sitrep`.

## Sub-command: end

### Stage 1: Read live.md

Extract completed (`data-done="true"`), open (`data-done="false"`), notes, standup. Absent → continue from agents.

### Stage 2: Parallel data gathering

Launch 7 agents with [`references/subagent-contract.md`](references/subagent-contract.md):

- **GitHub/git:** today's commits, PRs created/merged/reviewed, issues closed.
- **Calendar + Granola:** meetings with decisions/actions; tomorrow's prep.
- **Slack:** unanswered DMs/mentions, notable contributions.
- **Gmail:** unreplied emails, notable outgoing.
- **Lattice:** pending feedback with deadlines, new feedback.
- **Jira + Confluence:** activity, unanswered comments, Confluence mentions. Full sweep: `assignee = currentUser() AND statusCategory != Done`.
- **DX:** review turnaround, cycle time, deploy frequency vs averages.

### Stage 3: Compile

Two buckets:
- **Historical → snapshot:** done items, meeting notes, achievements, feedback, DX, stats.
- **Pending → live.md:** tomorrow's prep, untracked actions, unanswered items, Lattice requests, DX improvements, confirmed pending spans.

Cross-validate pending against external state (GitHub merged, Jira Done, Calendar occurred, Slack replied). Ambiguous → pending. Drop items with no link.

### Stage 4: Write snapshot.md

Historical only; never pending. Existing → merge, don't overwrite.

**Authorship filter:** include as user's only when `gh pr view --json author` confirms author/co-author/primary approver. Enumerate via `gh search prs --author @me`. Template: [`references/snapshot-template.md`](references/snapshot-template.md). Append QPR-worthy items to `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md`.

### Stage 5: Rewrite live.md

Re-read first. Write completed keys to `$WEEK_MEM_FILE`. Rewrite with pending only — drop completed + date-specific FYI. Re-number `data-t` from `t1`. Three columns: **col1** prep, **col2** carry-forward + follow-ups + DX, **col3** notes. Record `end_completed_at:`.

### Stage 6: Open snapshot

`open "$SNAPSHOT_URL"` — announce done/carried/documented counts.

### Stage 7: Distill learnings

`$WK_SKILLS_HOME` set + unprocessed learnings → highest severity first, cap 5. Invoke [`wk-sharpen`](../sharpen/README.md).

### Stage 8: Mark complete, commit, push

Invoke `wk-learn sitrep`. Add `end_completed_at: {ISO_8601_UTC}` to `$LIVE_FILE`.

```bash
BRAG_LOG="$SITREP_REPO/$EMPLOYER/QPR/brag-log.md"
git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE"
test ! -f "$WEEK_MEM_FILE" || git -C "$SITREP_REPO" add "$WEEK_MEM_FILE"
test ! -f "$BRAG_LOG" || git -C "$SITREP_REPO" add "$BRAG_LOG"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📸 end $TODAY — {N} done, {M} carried forward"
git -C "$SITREP_REPO" push
```

## QPR season awareness

Once-per-day nudge, never blocking: [`references/qpr-nudge.md`](references/qpr-nudge.md).

## Requirements

- Env: `$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT` (default `3000`), `$GITHUB_ORG`, `$GITC_ROOT` (default `$HOME/gitc`).
- `jq`; `silverbullet` CLI serving `$SITREP_REPO`.
- MCP: Slack, Gmail, Calendar, Granola, Drive, Docs, GitHub, Jira, Lattice.
