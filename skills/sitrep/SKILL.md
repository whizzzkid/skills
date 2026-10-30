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
  - "mcp__claude_ai_Notion*__*"
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
  version: "2026.10.30-194506"
  model:
    openai: gpt-5.6-terra
---

# Sitrep

Run `/wk-sitrep start` (default, no arg) at workday start; `/wk-sitrep end` optionally closes it. One persistent live
page; dated snapshots at close; no standalone HTML.

## Core hard rules

- **HARD RULE — never write outside `$SITREP_REPO/$EMPLOYER/`.** Never write `morning.md`, `evening.md`, or any sitrep
  file into cwd or `$WK_SKILLS_HOME`.
- **HARD RULE — no interactive triage.** Compile-only (gather → render → write → open); never `AskUserQuestion` to
  keep/skip/resolve; write items unconditionally as `data-done="false"` spans; user edits in browser. The connector
  report below is in-response, never a prompt.
- **HARD RULE — recompute every weekday from its date.** Before writing any day-of-week label (page, snapshot,
  standup), derive it from the ISO date (`date -j -f %Y-%m-%d <d> +%a`; GNU: `date -d <d> +%a`). Source disagrees →
  write the computed day and note the correction; agent- and message-supplied weekdays are claims.
- **HARD RULE — never assert missing without checking.** `Read`/`ls` the path first; unchecked → say "I have not read
  X", not "X is missing."
- **HARD RULE — publish first, report connector gaps after.** A missing, unauthenticated, permission-denied, or blocked
  connector never stops the run: write, verify, and commit the page from the domains that answered. Never abort or
  wait for instruction before publishing.
  - **Label every gap on the page.** Meta lists each gap connector + failure kind; the affected section says
    "⚠️ {connector} unavailable — not reverified". Preserve `data-done`/carry-over for its items; never claim an outcome
    from a missing domain; brag-log entries need evidence from an available domain.
  - **Report after publish.** Final response ends with `Connector gaps`: per connector — failure kind (no tool / auth
    required / permission denied / blocked), affected sections, fix CTA (re-auth link or command). Mark optional
    connectors `(optional)`. No gaps → omit the block.
  - **Optional connectors** (DX): absent → skip their sections silently on the page; never a gap CTA beyond the
    `(optional)` line.
  - **User waivers only, never agent-inferred.** Connectors in `.sitrep.yml` `waived_connectors:` (written only when the
    user waives "for all runs") plus any waived for this run drop out of the report; echo every waiver in Meta.
  - **Offer migration in the report.** Gap connector + an available connector covering the same domain → offer
    "migrate roster" beside "waive once" / "waive always". User confirms → edit the skill source in one pass: roster
    agent line, ToolSearch hint, `allowed-tools`, Requirements MCP list. Never migrate on inference.
- **HARD RULE — push only to an approved destination.** Never `git push` until Step 0's push-destination gate sets
  `PUSH_ALLOWED=1`: `origin`'s owner must be in `.sitrep.yml` `push_owners:` (else `$GITHUB_ORG`). Unset list, no
  remote, or any other owner → commit locally, skip every push this run, tell the user to move the repo to an
  employer-managed org. Private visibility is not approval (a personal account's private repo is a personal
  destination; the page holds work data).
  - Keep confidential figures (spend, cost, forecasts) out of the page and snapshots — link the source system instead.

References: layout/spans/urgency/nesting/styles [`references/rendering-contract.md`](references/rendering-contract.md)
(HTML-block mechanics via [`wk-silverbullet`](../silverbullet/README.md)); canonical span + toggle handler
[`references/checkbox-span-handler.md`](references/checkbox-span-handler.md); week-scoped JSONL that suppresses
user-resolved items (path, key, safe-write, validation)
[`references/dismissed-registry.md`](references/dismissed-registry.md).

## Step 0: Bootstrap (both sub-commands)

Resolve `$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT` (`.sitrep.yml` wins), export `$TODAY`, `$LIVE_FILE`,
`$SNAPSHOT_FILE`, `$SNAPSHOT_URL`, `$WEEK_MEM_FILE`, `mkdir -p` parents, set `PUSH_ALLOWED` (push-destination gate),
ensure SilverBullet serving. Absolutize `$SITREP_REPO` first (relative → against the `.sitrep.yml` dir); its git
toplevel may be a parent repo, so never assume they are equal. Recipes:
[`references/bootstrap.md`](references/bootstrap.md).

## Sub-command: start

- **Stage 0.5 — Close unfinished prior day.** **HARD RULE — close before overwrite.** Prior `date:` with no valid end
  state → full `end` flow first; failure stops `start`. User explicitly declares the stale page closed → skip the
  rollover, carry its open spans forward, note it in Meta. Closed day = previous workday → one shared gather feeds
  both flows. Dirty-path check: tracked non-artifact → stop; untracked non-artifact → ignore, never stage. Details:
  [`references/missed-end-rollover.md`](references/missed-end-rollover.md).
- **Stage 1 — Load previous live.md.** Read `$LIVE_FILE`: open `data-done="false"` → carry-over, completed → count.
  Canonical state is `data-done` (legacy glyphs read-only). Resolve previous working day from frontmatter. Read
  `$PREV_SNAPSHOT_FILE`; treat `## Achievements` as candidate evidence, never freshness waiver.
  - **Same-day re-run** (`date:` = `$TODAY`) → regather every domain, or state in Meta and the response that the
    earlier gather (with its time) was reused; never present a reused gather as fresh.
- **Stage 2 — Gather in parallel.** Launch 5 agents; prepend
  [`references/subagent-contract.md`](references/subagent-contract.md), append
  [`references/yesterday-synthesis.md`](references/yesterday-synthesis.md); separate previous-workday from today.
  - **Slack:** unread DMs/mentions, open threads, announcements. ToolSearch: `"slack"`.
  - **Gmail:** unread needing response, sent without reply, announcements. ToolSearch: `"gmail"`.
  - **Calendar + Notion + Drive:** today's meetings with agendas and Notion meeting notes; interviews lacking
    prep/scorecard (data only — Stage 2c creates). ToolSearch: `"gcal"`, `"notion"`, `"gdrive"`.
  - **GitHub:** PRs needing review (`--draft=false`), your open PRs with failing CI/comments, assigned issues, mentions.
    All `gh` requires `--owner="$GITHUB_ORG"`. ToolSearch: `"github"`. **HARD RULE — verify authorship** via
    `gh pr view --json author`, never infer. Sweep unsubmitted reviews (`state: PENDING`, org-wide) with a batched
    GraphQL `reviews(states: PENDING, author:)` over the candidate PRs (not `gh search`); return each draft's review
    URL, comment count and its PR's state (open vs merged/closed orphan).
  - **Jira + Confluence:** assigned tickets, mentions, Confluence mentions. ToolSearch: `"jira"`, `"confluence"`. Always
    run the full open-ticket sweep `assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC`; surface
    `In Review`/`Blocked`/`On Deck`, past-due, merged-but-open candidates; no-activity tickets → `## 🗂 Jira backlog`.
    **Activity = user-authored change.** `updated` moves on anyone's edit: count a ticket as the user's work only when
    a changelog entry or comment in the window is authored by the user; many tickets sharing one stamp = bulk edit.
  - Block handling: OAuth soft blocks degrade with CTA; `tool_unavailable` → replay in main; still toolless = missing
    connector.
  - Truncated result (ends mid-item) → re-request only the named sections with the contract's word cap; never
    compile a cut-off report as complete.
  - Cross-tracker pending-on-me: fold all trackers into one view; compare carry-over status vs previous `live.md` and
    prefix changes `🔁 {old}→{new}`; append `⏳ {N}d` for >7 days; sort by native priority (missing → lowest).
- **Stage 2b — Auto-transition merged-PR tickets.** `start` only, before writing `live.md`: tickets in
  `In Review`/`Ready for Review` with linked PR → check merge state; merged within 14 days → transition to `Done`.
  Denial → block-register key, render `🔁 blocked N days` in ASAP. Render as `data-done="true"` `⚙️ Auto-Actions`.
- **Stage 2c — Create missing interview prep blocks.** Per interview lacking prep/scorecard →
  [`wk-cal`](../cal/README.md) block-creation: 15-min prep before, 45-min scorecard after (user-stated length wins;
  scan forward on busy slots). Render a block as done only after `wk-cal`'s post-create re-list confirms duration and
  zero overlap; failed check → warn item, never a done span.
- **Stage 3 — Compile open items.** Merge agent results + carry-over; drop completed + dismissed; write survivors as
  `data-done="false"` spans. Content inventory (skip empty): Carry-over, Meeting Prep, Slack, Email, GitHub, Jira,
  Confluence. Sort/mark urgency per rendering contract.
- **Stage 4 — Write live.md.** Re-read `$LIVE_FILE`; preserve `data-done="true"` spans; prefer `Edit` over `Write`.
  Three-column `sitrep-row`/`sitrep-col`: **col1** Calendar + Slack + Email; **col2** ASAP + GitHub Inbox +
  Auto-Actions + Jira; **col3** Meta + Standup + This Week + Notes + Backlog. Frontmatter: `date`, `employer`,
  `generated_with`, `generated_at`. Sequential `data-t` IDs.
  - **Important: actionable means checkbox.** Every item the user must act on — each link in a link list included — is
    its own `st-item` with an `st-cb` and `data-t`; checkbox-less text is for non-actionable content only (a list of
    links is items, not presentation). Action sections sit directly under ASAP, one short line per item.
  - **Info lines are spans too.** Inside a column, each non-actionable line (meeting, FYI, sub-heading) is a
    checkbox-less `<span class="st-item st-info">`; only a section's `**bold**` header stays bare. Never raw text or a
    `<br>`-terminated line (observed: a raw-text rewrite nested columns 2-3 inside column 1).
  - **HARD RULE — GitHub Inbox.** One col2 section lists everything on GitHub waiting on the user, one checkbox item
    per link (`st-item st-nested`, `[repo\#N: title](url) — note`): merges, review requests (allowlist vs other repos)
    and each unsubmitted PENDING draft on an open PR (linking its review URL). Open PRs only: drop merged, closed and
    already-approved PRs and every orphan draft on them. Never a bare count or a prose run of PR numbers.
  - **Generate spans; never hand-type them.** Emit item spans from an inline generator over the compiled item list
    (e.g. a `jq` filter on stdin — no script file, per the write-scope HARD RULE): sequential `data-t`, canonical
    handler and copy-block markup verbatim, `#` → `\#`. Same for `end` Stage 5 (hand-typed handlers and IDs drift).
  - **Patch lines without eating `\#`.** Replace a line in place via shell parameter substitution, never a
    `sed`/`awk` replacement (both strip the `\` from `\#`); `\#` count before = after, else re-patch.
  - **Multi-line patch → newline in a variable.** Assign `nl=$'\n'` first and substitute `$nl`; an inline `$'\n'`
    stays literal inside a double-quoted substitution under zsh. After any patch, grep for stray literal `\n` text
    and assert every `data-t` ID is unique and on its own line.
- **Stage 4b — Standup snippet.** Render in col3 using the canonical rich-copy block from
  [`references/standup-copy-block.md`](references/standup-copy-block.md); formatting via
  [`wk-slack`](../slack/README.md) §Standup Snippet.
  - **HARD RULE — Yesterday is date-bounded multi-source synthesis.** Apply
    [`references/yesterday-synthesis.md`](references/yesterday-synthesis.md); reject prior standup/session memory.
  - **Yesterday:** 3-4 highest-impact outcomes with PR URLs. **Today:** top 3-4 ASAP. **Blockers:** always present,
    `None` when empty.
  - Apply `wk-slack` privacy filter + formatting. Rich body = `<ul>` with three `<li>`. Verify skin-tone emoji survive
    write.
- **Stage 5 — Verify render, then open.** **HARD RULE — gate the "Live page ready" announcement on a verified render.**
  `open` confirms nothing; containment alone cannot fail on columns nested inside each other (`closest('.sitrep-col')`
  and scoped counts stay true). Before announcing, `browser_navigate` → `browser_evaluate`, all must hold:
  - **Geometry:** exactly 3 non-empty `.sitrep-row > .sitrep-col` (direct children), zero `.sitrep-col .sitrep-col`,
    and distinct, strictly increasing `getBoundingClientRect().left` across the three.
  - **Containment, not presence:** every `.st-copy-block`/`.st-item` inside a column (scoped count = global count).
  - **Checkboxes:** zero `.st-item:not(.st-info)` without an `.st-cb`.
  - **Screenshot:** `browser_take_screenshot` and confirm three side-by-side columns.
  - `false` → fix the markup per `wk-silverbullet` Step 6. Never reshape content to pass a clause; a clause that
    rejects canonical markup is the defect — fix the clause.
  - Verify standup copy per [`references/standup-copy-block.md`](references/standup-copy-block.md). `browser_close`
    before `open`, then announce "Live page ready — {X} items, {Y} meetings, {Z} carry-overs."

  ```bash
  open "http://localhost:$SITREP_PORT/$EMPLOYER/live.md"
  ```

- **Stage 6 — Commit and push.**

  ```bash
  git -C "$SITREP_REPO" add "$LIVE_FILE"
  git -C "$SITREP_REPO" commit -m "chore(sitrep): 📋 start $TODAY — {N} items, {M} meetings"
  if test "$PUSH_ALLOWED" = 1; then git -C "$SITREP_REPO" push; else echo "push skipped: origin owner not approved"; fi
  ```

- **Stage 7 — Auto-launch PR reviews.** One review worktree per PR awaiting review, rendered as done `⚙️ Auto-Action`
  that replaces the section's placeholder line in place (never appended beside it). Pending draft only — never
  submit/approve/request changes. Re-check live state right before dispatch and again before publishing: merged, closed
  or approved → no review, no listed draft. Run `/wk-pr-review` in **light** mode; the orchestrator `open`s each posted
  draft's review URL. Reserve slots for nested workers. Mechanics:
  [`references/auto-review.md`](references/auto-review.md). Then invoke `wk-learn sitrep`; end the response with the
  `Connector gaps` report.

## Sub-command: end

- **Stage 1 — Read live.md.** Extract completed (`data-done="true"`), open (`data-done="false"`), notes, standup. Absent
  → continue from agents.
- **Stage 2 — Gather in parallel.** Launch 7 agents with
  [`references/subagent-contract.md`](references/subagent-contract.md):
  - **GitHub/git:** today's commits, PRs created/merged/reviewed, issues closed.
  - **Calendar + Notion:** meetings with decisions/actions; tomorrow's prep.
  - **Slack:** unanswered DMs/mentions, notable contributions. **Gmail:** unreplied emails, notable outgoing.
  - **Lattice:** pending feedback with deadlines, new feedback.
  - **Jira + Confluence:** user-authored activity (per `start`), unanswered comments, Confluence mentions. Full sweep:
    `assignee = currentUser() AND statusCategory != Done`.
  - **DX (optional):** review turnaround, cycle time, deploy frequency vs averages. Unavailable → omit DX sections.
- **Stage 3 — Compile into two buckets.** Historical → snapshot (done items, meeting notes, achievements, feedback, DX,
  stats); pending → live.md (tomorrow's prep, untracked actions, unanswered items, Lattice requests, DX improvements,
  confirmed pending spans). Cross-validate pending against external state (GitHub merged, Jira Done, Calendar occurred,
  Slack replied); ambiguous → pending; drop items with no link.
- **Stage 4 — Write snapshot.md.** Historical only, never pending; existing → merge, don't overwrite. Authorship filter:
  include as user's only when `gh pr view --json author` confirms author/co-author/primary approver; enumerate via
  `gh search prs --author @me`. Template: [`references/snapshot-template.md`](references/snapshot-template.md). Append
  QPR-worthy items to `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md`.
- **Stage 5 — Rewrite live.md.** Re-read first; write completed keys to `$WEEK_MEM_FILE`; rewrite with pending only —
  drop completed + date-specific FYI; re-number `data-t` from `t1`. Columns: **col1** prep, **col2** carry-forward +
  follow-ups + DX, **col3** notes. Record `end_completed_at:`.
- **Stage 6 — Open snapshot.** `open "$SNAPSHOT_URL"` — announce done/carried/documented counts.
- **Stage 7 — Distill learnings.** `$WK_SKILLS_HOME` set + unprocessed learnings → highest severity first, cap 5; invoke
  [`wk-sharpen`](../sharpen/README.md).
- **Stage 8 — Mark complete, commit, push.** Invoke `wk-learn sitrep`; add `end_completed_at: {ISO_8601_UTC}` to
  `$LIVE_FILE` (gaps do not withhold it); end the response with the `Connector gaps` report.

  ```bash
  BRAG_LOG="$SITREP_REPO/$EMPLOYER/QPR/brag-log.md"
  git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE"
  test ! -f "$WEEK_MEM_FILE" || git -C "$SITREP_REPO" add "$WEEK_MEM_FILE"
  test ! -f "$BRAG_LOG" || git -C "$SITREP_REPO" add "$BRAG_LOG"
  git -C "$SITREP_REPO" commit -m "chore(sitrep): 📸 end $TODAY — {N} done, {M} carried forward"
  if test "$PUSH_ALLOWED" = 1; then git -C "$SITREP_REPO" push; else echo "push skipped: origin owner not approved"; fi
  ```

## Requirements

- QPR season: once-per-day nudge, never blocking: [`references/qpr-nudge.md`](references/qpr-nudge.md).
- Env: `$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT` (default `3000`), `$GITHUB_ORG`, `$GITC_ROOT` (default `$HOME/gitc`).
  Tools: `jq`; `silverbullet` CLI serving `$SITREP_REPO`.
- MCP: Slack, Gmail, Calendar, Notion, Drive, Docs, GitHub, Jira, Lattice; DX optional.
