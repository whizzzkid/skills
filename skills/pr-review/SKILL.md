---
name: wk-pr-review
description: >-
  Thorough, critical code review of a GitHub pull request. Use when asked to
  review a PR, review code changes, help review this PR, create review comments,
  or investigate a pull request. Reads existing review comments, resolves stale
  threads, delegates deep investigation to wk-adversarial-review, and creates
  pending review comments via GitHub API. Modes: light (diff + claims),
  medium (default; harness + arch/functional review), heavy (runs the
  change and every local gate; confirms first). Optional `approve` token
  submits an approval when no concern or blocker remains; else pending.
  Trailing free text = user focus investigated with extra depth.
argument-hint: '[light|medium|heavy] [approve] [PR number or URL] [focus...]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr checkout:*)"
  - "Bash(gh api repos:*)"
  - "Bash(gh api graphql:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git pull:*)"
  - "Bash(grep:*)"
  - Read
  - Write
  - Grep
  - Glob
  - Agent
  - Skill
  - AskUserQuestion
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: "2026.10.20-175635"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Review

Gather context → delegate to [`wk-adversarial-review`](../adversarial-review/README.md) → post encouraging but critical
inline comments as a pending GitHub review. Requires authenticated `gh`, a GitHub remote, and `wk-adversarial-review`.

**HARD RULE:** All GitHub reads/writes follow [`wk-gh`](../gh/README.md). Invoke it (Skill tool) before drafting any
review body or comment; footer goes on the body and every inline comment.

**HARD RULE — optional reviewers require current-task opt-in.** Never launch an optional local/external model reviewer
unless the user requests it in this task; existing CI output is evidence, not authorization. Phase-owned dispatches
remain mandatory: `wk-adversarial-review`, `wk-arch-review`, `wk-design-review` — except where `light` mode defers
them below.

## Review Modes

Args parse positionally, all optional: mode → `approve` → PR number/URL → focus (the rest). Mode tokens `light` |
`medium` | `heavy` (case-insensitive); none → `medium`. "quick"/"skim" → `light`; "deep"/"exhaustive" → `heavy` (still
confirms). Each mode includes everything in the one above it.

| Mode | Adds | Time box |
|------|------|----------|
| `light` | Diff, description, `pr_claims` validated; objective static review | a few minutes |
| `medium` | Adversarial harness that tries to break the change; thorough arch + functional review | 10–15 min |
| `heavy` | Runs the change (browser if UI); every local gate; full path/edge/mutation matrix | unbounded, confirm first |

- **`light`:** Phases 1, 2, 4, 5 in full; Phase 3 consumes an existing clearance record only — never dispatches
  `wk-adversarial-review`. Arch/design detectors still run; a hit is not dispatched → tell the user in the terminal to
  re-run at `medium`.
  - Logic-bearing finding → prove it with one targeted run (single command, test, or snippet); unrun → post as
    `question:`, never `concern:` (the Phase 3 proof rule still binds, scaled down).
- **`medium`:** every phase as written. The adversarial harness must attack each changed behavior on multiple axes —
  invalid/hostile input, boundaries, ordering/concurrency, dependency failure, backward compatibility. Functional
  review traces each changed entrypoint caller → callee; arch review dispatches whenever the detector fires.
- **`heavy`:** **HARD RULE — confirm before heavy.** `AskUserQuestion` with the cost (wall time, local processes,
  dependency installs) before any heavy-only step; declined → `medium`. Non-interactive caller (dispatched subagent,
  loop) → run `medium`, report "heavy requested, not confirmed". Then add:
  - **Run the change:** launch via the `run` skill or the documented dev server, in the repo's documented container;
    UI diff → drive every changed view with Playwright (snapshot, console errors, broken interactions); CLI/API →
    exercise every claimed behavior end to end.
  - **Every local gate:** full test suite, linters, type-checker, coverage of changed lines, mutation testing of
    changed logic, security scanners the repo already configures.
  - **Path matrix:** happy/sad/edge row per changed behavior, each PASS/FAIL with the command; unrunnable rows listed
    with the reason.
  - **Local only:** never deploy, push, hit shared/production environments, or load real customer data (a run is
    verification, not a release).
- **Time box:** soft, checked at phase boundaries. Over budget → finish the current phase, post what is proven, list
  uncovered items in the terminal; never silently truncate. Mode and coverage go to the terminal, never the review body.

## Approve Flag

`approve` token (case-insensitive) → `APPROVE = true`; absent → pending review only; the word inside focus text is
never the flag.

- **HARD RULE — approval needs the literal token from the user in this task.** Never infer it from tone ("looks
  fine", "ship it"), a prior task, or a dispatching caller's prompt; dispatched subagents and loops never approve
  (approval is irreversible and speaks for the user).
- **Approve gate — all must hold at Phase 5, else hold as pending:** zero `concern:` comments in this review
  (`blocker` maps there in Phase 3); adversarial/arch verdict not `blocked`; no prior own concern still open (Phase 2
  re-review); no failing required check (`gh pr view --json statusCheckRollup`); current user is not the PR author
  (GitHub 422s self-approval). `suggestion:`/`question:`/`praise:` never block.
- Gate fails → post pending as usual; tell the terminal "approve requested; held as pending: {reasons}".

## Focus Argument

`user_focus` = free text after the last recognized token (quotes optional); empty → none.

- **Extra care, not exclusive scope** — review the full diff as usual; focus never suppresses other findings.
- Phase 1: split focus into `review_focus` items tagged `source: user`, ranked ahead of author asks; resolve each to
  the files/symbols it names (grep); unmatched → say so in the announce line, never guess.
- Phase 3: pass `user_focus` verbatim to `wk-adversarial-review` as the priority target; every mode (incl. `light`)
  attacks each focus item with at least one targeted run on the multi-axis list in Review Modes.
- Phase 4: findings on focus items post inline like any other. Report each item's outcome (finding / clean, with the
  evidence) in the terminal; never quote or answer the user's focus in the review body (private steering, not an
  author ask).

## Phase 1: Context

On a PR branch: `gh pr view --json number,title,body,baseRefName,headRefName,url,files,commits,reviews`. On main/no PR:
ask for number/URL, then `gh pr checkout`.

- **Verify local HEAD:** compare `git rev-parse HEAD` vs `gh pr view --json headRefOid --jq '.headRefOid'`. Mismatch →
  `git pull --ff-only`; pull fails → use `gh pr diff` as source of truth; note desync in summary.
- **Collect:** title, body, linked issues, full diff, changed files, commits, base, size. Recommend a stack when large
  or mixing concerns.
- **Review focus:** parse the description for explicit asks → `review_focus` list of `{topic, files, question,
  severity-hint}`; drop boilerplate. Prioritize them in Phase 3; answer every ask in Phase 4 (unanswered = gap).
- **Claims:** parse description + commit messages for assertions (behavior, "no-op", perf, "tested X", "fixes Y") →
  `pr_claims`; every mode marks each Confirmed / Refuted / Unverified. Refuted → comment.
  - Empirical claims (mutation results, test counts, gating, "fails without the fix") → replay in a detached scratch
    worktree; reading alone never confirms them. `light` caps at one targeted run per claim, else Unverified.
  - Cited figures (counts, timestamps, CI windows, "fails in env X not Y") → re-derive from primary data (CI API,
    logs) and rerun the author's own experiment; most figures checking out never confirms the rest. Pair log events
    by matching the result line's pattern, never the next physical line (payloads span lines).
  - Related PRs the description calls pending or "lands first" → check their merge state; merged → re-check the
    follow-up steps it predicted.
  - Tee full test output to a log file, never `tail -1`; rerun a bare FAIL before treating it as real.
- Announce: > "Reviewing PR #N (`{mode}`): *title* — X files, Y commits. Base: `{base}`. Author asks: {k}. Claims:
  {c}. Focus: {user_focus | none}."
- **Architecture:** run the [`wk-arch-review`](../arch-review/README.md) detector over `gh pr diff <n> --name-only`.
  Clearance at `.review-playground/.arch-cleared-{SHA}.json` → consume; else
  `Skill(wk-arch-review, args="<path | PR>")`. Fold findings into Phase 3/4.
- **HARD RULE — spec-doc claims about existing code are Unverified.** Named structs/fields, "reuses X", "~N-line port" →
  grep/read to confirm; delegate batch to one subagent. Re-verify a posted finding the moment a later result
  contradicts it.
- **Design:** diff touches styles/tokens/theme/components/stories/a11y → `Skill(wk-design-review, args="consult <n>")`
  before Phase 3.

## Phase 2: Existing review comments

Fetch, classify stale threads, build the Phase 3/4 exclusion list via
[`references/graphql-unresolved-threads.md`](references/graphql-unresolved-threads.md) — REST for bodies, GraphQL for
`isResolved`/`isOutdated`.

- **Stale when:** `position` null; file changed after `updated_at`; line content mismatches. Categorize **stale
  (fixed)**, **stale (unclear)**, **active**; bodies referencing absent files → **stale (superseded)**.
- **HARD RULE:** Never resolve threads without explicit user consent. Present list, confirm, match each by
  `path`+`line`+`body`, resolve via GraphQL mutation.
- **Queues:** `bot_findings_to_validate` (active bot comments → Phase 3) and exclusion list
  `(file, line_range, topic)` → prevents dupes. Re-scope bot severity: grep trigger + one hop downstream.
- **Re-review:** prior comments by the current user exist → close the loop before new issues per
  [references/re-review-follow-up.md](references/re-review-follow-up.md); a modified file proves an attempt, not a fix.

## Phase 3: Adversarial investigation

Scope per [Review Modes](#review-modes). Clearance at `.review-playground/.cleared-{HEAD_SHA}.json` → consume; else
(`medium`/`heavy`) dispatch `Skill(wk-adversarial-review)` for structured findings + verdict. Prioritize `review_focus`; fold Phase 1 `wk-arch-review` findings; mark exclusion-list
overlaps `[COVERED]`; map `blocker` → Phase 4 `concern` (`suggestion`/`question` pass through). Agent verdicts override
static reasoning — drop/revise candidates the results refute.

**HARD RULE — logic-bearing findings need empirical proof.** Executable logic (incl. `wk-arch-review` findings) → drive
the real implementation or a faithful harness with adversarial inputs; record PASS/FAIL before Phase 4. Never compose
comments from un-run reasoning.

**HARD RULE — check derivation before contradicting a figure.** Grep the artifact for its derivation rule; read a timing
constant's whole comment block before replacing it. Refuted but derivation unstated → clarity suggestion, not drop.
Failing line not in diff → environmental.

**Bot findings:** route each through the same engine → `Confirmed` / `Refuted` / `Inconclusive`. Silent skip forbidden.

## Phase 4: Review comments

No comment cap — surface every actionable finding. Inline: bugs, suggestions, genuine intent/behavior questions; never
narration, generic praise, or bot agreements (in the body either). Default approve-with-concerns; never "blocker" in
author-facing text — use "concern"/"limitation". One to two sentences.

- Severity: **`concern:`** critical/security/data-loss (sparingly); **`suggestion:`** style/naming/refactoring
  (default); **`question:`** genuine uncertainty; **`praise:`** non-obvious patterns (generic → omit).
- Body: `**{severity}:** {observation}` + optional context/evidence/fix.
- **HARD RULE — attribute agent evidence:** "My agent ran `<X>` and found `<Y>`", never bare "I verified" — in inline
  comments and body. Bare first-person only for the human's own posture.
- Prefer ` ```suggestion ` fences for concrete replacements on diff lines: match exact whitespace (verify with
  `cat -A`); one fence = one contiguous range, split non-adjacent fixes; fence lines replace exactly
  `start_line..line` — a context line goes inside the range or out of the fence (else it duplicates); lines outside
  diff → anchor a nearby diff line, plain example, note manual apply.
- **HARD RULE — no duplicates** (same file/line range + same concern). Check the Phase 2 exclusion list. Human dup →
  skip if it holds; reply only with new info or evidenced disagreement. Bot dup → Phase 3 outcome per
  [`references/bot-finding-validation.md`](references/bot-finding-validation.md); Confirmed → silent skip.
- **HARD RULE — valid positions.** Every comment targets a diff line. `+` and context = valid `RIGHT`; removed = not.
  ±5 same hunk → move; else file-level or body.
- Answer every author `review_focus` item inline or in body `Re: <question>`; mark each `answered: inline | body |
  open`. `source: user` items → terminal only, per [Focus Argument](#focus-argument).

Present a numbered summary (`1. [concern] src/auth.ts:42 — description`), then go straight to Phase 5 in the same turn —
never ask "post as pending review?". The review stays pending (bar a passing approve gate), so the user decides at
submit time.

## Phase 5: Post review

**HARD RULE:** Auto-create pending review after Phase 4 unless user said "don't post"/"wait"/"let me review first". User
submits from GitHub UI; never call submit/approve/request-changes — sole exception: [Approve Flag](#approve-flag) gate
passes → submit that pending review as `APPROVE`, never `COMMENT`/`REQUEST_CHANGES`. Omit `event` from the create
POST (422 on `"PENDING"`).

Recheck the reviewed head before each POST, append by delete+recreate, and post follow-ups live:
[references/posting-pending-review.md](references/posting-pending-review.md).

- **Important:** build every payload with the Write tool — never inline `jq -n '…'` or any single-quoted shell string
  (an apostrophe in a comment body ends the quote and breaks the call).

**HARD RULE — the POST is its own single Bash call.** Footer build, payload (Write tool), footer gate, and `open` each
run as separate calls; never chain them with the `gh api ... --method POST`. Denied with `a hook changed this call's
input` → retry the identical POST once ([`wk-env`](../env/README.md) Step 3.6); denied again → stop, report the payload
path, ask the user to re-authorize or post it. Never a third attempt.

**HARD RULE — distinct findings anchor at their own line** — own comment on the subject's diff line, never buried in a
reply on an adjacent thread. Replies only continue the *same* finding.

**HARD RULE — the body is the verdict line plus the `wk-gh` footer, with or without concerns.** Verdict: `LGTM 🚀`
(clean), `LGTM, one minor nit` / `LGTM, two minor questions`, or `Approving with concerns`. Inline comments carry the
substance; GitHub shows them under the review. Ban praise-adjective openers.

- Never in the body: a `— <risk>` suffix, thread pointers, praise or "the rest looks right", process meta-commentary
  (review depth, what was checked), bot/duplicate-thread bookkeeping, restated inline findings, diff narration. Review
  depth → tell the user in the terminal.
- One extra sentence each, only for: a change-wide concern with no inline anchor; a `Re:` answer to an un-anchored
  author `review_focus` item; an evidenced bot reply per [`bot-finding-validation`](references/bot-finding-validation.md).
- **HARD RULE — pre-POST body gate:** count sentences before the footer; cut any past the verdict that is not one of
  those three.

**HARD RULE — open URL on every create/recreate**, whether or not the POST response parsed; parse failure → re-query for
`html_url`, never drop the open. Trust `path`+`body`, not `line` for verification.

> "Pending review with N comments — {html_url}. Submit on GitHub when ready."

Approved → > "Approved with N comments — {html_url}."

## Post-Completion

Invoke `wk-learn pr-review`.
