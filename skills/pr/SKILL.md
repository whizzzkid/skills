---
name: wk-pr
description: >-
  Create a GitHub pull request and manage the post-PR workflow. Use when asked
  to create a PR, open a PR, push for review, or manage a stacked PR. Handles
  draft creation, stacking, CI polling, self-review, automated feedback, and
  marking ready.
argument-hint: '[optional: base branch for stacking]'
allowed-tools:
  - "Bash(git symbolic-ref:*)"
  - "Bash(git diff:*)"
  - "Bash(git log:*)"
  - "Bash(gh pr create:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh pr view:*)"
  - "Bash(gh pr ready:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr reviews:*)"
  - "Bash(gh stack:*)"
  - "Bash(gh extension list:*)"
  - "Bash(gh api repos:*)"
  - Read
  - AskUserQuestion
  - Write
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
env-vars:
  - WK_SKILLS_EMPLOYEE_EMAIL
metadata:
  author: whizzzkid
  version: "2026.08.28-192046"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR

Create and manage GitHub PRs: draft mode, stacking, post-creation workflow that
ensures quality before marking ready.

## Hard Rules

0. **All GitHub reads/writes route through `wk-gh`.** Org scoping per `wk-gh`
   Step 1–2. Every PR title/body, review body, and comment body ends with the
   canonical outbound footer per `wk-gh` Step 4 — inject at heredoc/template
   render time, and run the `wk-gh` pre-emit gate on the PR body (reject if the
   `🦾 Generated with` commit-trailer variant is present or `DM me your
   feedback.</sup>` is absent) before `gh pr create`/`gh pr edit`.
   **Unconditional — independent of every other gate.** A "skip the review"
   instruction waives only Rule 2's review; it never disables `wk-gh` routing or
   the footer.
   **Markdown body safety:** use a single-quoted heredoc delimiter (`<<'EOF'`).
   Before and after each write, require expected literal markers and reject an
   empty, implausibly short, or shorter-than-submitted server body.
1. **Preserve PR body metadata across description rewrites.** Before
   overwriting the PR description, preserve metadata lines — see
   `skills/pr/references/pr-description-metadata.md`.
2. **Adversarial review gates merge, not publish — once per change.**
   - Push, `gh pr create`, and `gh pr ready` need no verdict.
   - Dispatch `wk-adversarial-review` once after Step 5 marks ready.
   - Merge and `gh pr merge --auto` require clear review lineage.
   - Finding-response commits and tree-identical rewrites preserve lineage;
     unmatched scope, refactor, or logic gets one delta-scoped review.
   - `blocked` → no merge. Fix via `wk-commit`, then re-invoke for targeted
     validation. No size or scope exemption.

   **No-ask on review findings.** Findings from any mandatory pre-flight review
   (`wk-adversarial-review`, and `wk-arch-review` once per its own contract when
   the diff carries an arch-bearing artifact) are mandatory to incorporate — never ask "should I fold these in?".
   After review returns, immediately act on every finding against the artifact:
   fix blockers, fold in improvements, update doc/spec/code, commit each via
   `wk-commit`. Incorporation is not user-gated. Pause only when a single
   finding is genuinely ambiguous and needs a design decision only the user can
   make — surface that one specific question, never a blanket "want me to
   incorporate these?".
3. **Resolve the true base before any scope measurement or `gh pr create`.**
   Run Step 1's merge-base distance detection unconditionally — never assume the
   default branch, even for an "obviously simple" branch. Wrong base → pulls a
   parent branch's commits into the diff, runs CI against the wrong target. When
   the resolved base differs from the default, surface it before proceeding.

   **Very important — gate `gh pr create` on the algorithm, not intuition.** Do
   not call `gh pr create` until Step 1's loop has actually run this session and
   set `$BEST_BASE`/`$BEST_DIST`. A branch that "obviously" targets the default is
   exactly where the loop gets skipped and a stacked branch silently mis-bases.
   `--base` takes `$BEST_BASE`'s computed value only — never a hand-typed branch
   name. If `$BEST_BASE != $DEFAULT_BRANCH`, surface the A/B/C prompt first.
4. **Derive behavioral claims from the implementation, never narrate from
   intent.** Before finalizing any PR-body section describing behavioral rules,
   conditions, thresholds, or severity — re-read the source file and verify each
   claim against it. Quote a check's severity ladder directly from the file;
   never paraphrase from memory. A claim broader or narrower than the code (e.g.
   dropping a scope qualifier like "project-wide") misleads reviewers from the
   first draft, before any drift.

   **External-capability claims cite their upstream source.** A claim that a
   dependency/plugin supports a feature → link the upstream source file/line
   or docs proving it at composition time; after-the-fact citation is a defect.

   **Identifiers obey the same rule, with a command as their source.** Every run
   id, SHA, count, and artifact URL in the body is pasted from a command run this
   turn — never reconstructed from context. The surrounding sentence can be wholly
   true while the identifier in it names nothing that exists, so a *plausible*
   value is the failure mode, not a typo. A ticked checkbox is a claim too, and a
   link inside it is an identifier.

   ```bash
   gh run list --branch "$(git rev-parse --abbrev-ref HEAD)" \
     --json databaseId,headSha,conclusion --limit 1
   ```

## Step 1: Assess Scope

### Detect the true base branch (run unconditionally)

Compute merge-base distance to every candidate (default branch + open PR heads);
closest wins. Full algorithm, failure handling, and non-default-base prompt:
[`references/base-detection.md`](references/base-detection.md). `$BEST_BASE` is
the only value passed to `--base`.

### Measure scope against the resolved base

Use `$BEST_BASE` for the eventual `gh pr create --base` flag, but always
diff/measure scope against `origin/$BEST_BASE` (fetch first) — a stale local base
ref reports already-merged files as phantom additions and inflates LOC.

```bash
git fetch origin "$BEST_BASE" --quiet
git diff "origin/$BEST_BASE...HEAD" --stat
git diff "origin/$BEST_BASE...HEAD" --shortstat
```

- Diff exceeds ~30 lines → ask about splitting via `wk-pr-break`
  (in addition to stacking implied by `$BEST_BASE`).
- Borderline or unclear → ask the user's preference.
- Pass `$BEST_BASE` through to Step 2 — never re-detect or default back to
  `main`.

### Check open PRs for a related spec

[`references/check-open-prs-for-spec.md`](references/check-open-prs-for-spec.md).

## Step 2: Create Draft PR

Creating the PR is ungated — the single adversarial-review gate runs after
Step 5 marks it ready, so CI runs alongside it.

**Honor a review waiver.** User's current-session instruction waives review ("no
review needed") → suppress the Step 5 gate call; never rely on the user denying
the permission prompt to enforce their own instruction. (Rule 0 `wk-gh` routing +
footer still apply.)

**Always create PRs in draft mode** (`--draft` flag). Never create a non-draft
PR unless the user explicitly asks.

  **Early-ready override.** User directs immediate ready → `gh pr ready`
  after creation; self-review/CI/feedback continue post-ready.

  **Bot-ready gate.** Repo review bot approves only non-draft PRs → `gh pr ready` after creation; draft-until-CI default yields to the bot gate.

### Link the source plan and spec (pre-flight)

Before composing the body, locate the implementation plan the work derives from —
not just a high-level vision spec:

```bash
grep -rliE '<branch-phase-or-feature-keyword>' docs/plans docs/specs 2>/dev/null
```

- Found a plan under `docs/plans/` (or equivalent) → link it, anchored to the
  relevant phase section, under a `## Meta` block; link the spec too when present.
- The plan is the authoritative source of acceptance criteria — always surface it;
  a spec link is not a substitute for the plan link.
- **"Link the reference material" means add source URLs to the body, not copy
  files into the repo.** Satisfy a reference/citation request with the source URL;
  never create local copies of referenced files. Ambiguous reference request →
  clarify scope before creating any files.

### Resolve PR Body Template

Search the repo for a GitHub PR template; populate every section from the diff.
Full search order, population rules, and verification-section guarantee:
[`references/pr-template.md`](references/pr-template.md).

### Superseded & closed PRs

[`references/superseded-closed-prs.md`](references/superseded-closed-prs.md).

### Simple PR (fallback — no repo template found)

```bash
gh pr create --draft --base "$BEST_BASE" \
  --title "feat(scope): ✨ description" --body "$(cat <<'EOF'
## Summary
- What changed and why

## Test plan
- [ ] How to verify the changes

EOF
)"
```

`--base "$BEST_BASE"` MUST be present on every `gh pr create` — omitting it and
relying on the default re-introduces the mis-basing failure (Hard Rule 3).

PR titles use the same conventional commit + emoji scheme as commit messages.

### Jira key suffix

Detect via `wk-jira`'s resolution order. Key found → append `[<KEY>]` as the
last title token. No key → no suffix.

### Stacking multiple PRs

Use the official `gh stack` extension when available; it owns linked branch and
PR lifecycle. Use the manual convention only when the extension is unavailable.

- Probe once (`gh stack view`); non-zero / not-installed / repo-not-enabled →
  manual fallback.
- **HARD RULE — recover an existing stack as one unit.** Never rebase or push
  layers independently. Snapshot refs; use `gh stack rebase` with `--continue`
  or `--abort`; verify ancestry and full tests before `gh stack push`, then
  verify every remote head, current-head CI run, thread, and body-cited commit.
  Apply the recovery sequence in the reference below.
- **Read merge/dependency order from `baseRefName`, never `part-N` labels or
  memory** — query each PR's base (`gh pr view <n> --json baseRefName`); a
  trunk-based PR is independent, a PR merges only after the PR owning its base.
  Labels drift after any re-parent and fabricate nonexistent dependencies.

`gh stack` command sequence, availability probe, and the manual fallback recipe:
[`references/gh-stack-stacking.md`](references/gh-stack-stacking.md).

### Body extras

[`references/pr-body-extras.md`](references/pr-body-extras.md) — apply each matching sub-step.

## Step 3: Post-Creation Workflow

**HARD RULE — no early return after `gh pr create`.** PR creation is the
midpoint of this workflow, not the terminus. Continue immediately into Step 3
without returning control to the user. The only valid stopping points before
`gh pr ready` (Step 5):

- CI still failing after 3 fix-loop attempts.
- A `blocked` adversarial-review verdict requiring user design input.
- Explicit user interjection.

Reporting the PR URL and stopping is a violation — the user expects the full
lifecycle (description sync → CI poll → self-review → feedback triage → ready) on
a single invocation.

**Side actions never terminate the workflow.** Any ancillary action after
`gh pr create` (cross-repo comment, Slack/Jira/docs link, tracking-issue update)
is a continue signal, not completion — treat "I just posted on X" as continue.

After the draft PR is created (or after pushing new commits to an existing PR):

- **Important — open it in the browser first.** In the SAME response that runs
  `gh pr create`, run `gh pr view --web` before any description sync, self-review,
  or CI poll — bind it as one atomic create-then-open step, not a skippable later
  bullet. Skip only in a confirmed headless / non-interactive session.

1. **Update PR description** — Review the existing description; if it has
   drifted, update with `gh pr edit`. **Before overwriting**, preserve metadata
   lines per Hard Rule 1 (`skills/pr/references/pr-description-metadata.md`).

   **HARD RULE — no-ask on drift sync.** Drift between artifact and reality is an
   obviously-always-yes fix; never ask the user "want me to update the PR body?"
   before syncing. The decision to sync is not user-gated. Only ask when the
   *content* of the sync is ambiguous (e.g., two equally-plausible rewrites of a
   bullet). Applies to PR description, self-review threads, Jira ticket body, and
   project docs touched by the change.
2. **Invoke `wk-self-review` immediately** — the moment `gh pr create` returns,
   before the CI-poll launch. CI takes minutes; staging the draft in that window
   means the PR is closer to ready when CI finishes.

   **HARD RULE — self-review launches before the CI poll, never after CI green.**
   Deferring `wk-self-review` until CI is green is a recurring violation — treat
   the deferral as a blocker-equivalent. The intuitive "CI green → then review"
   order is wrong. **Structural gate: do not start the CI poll (item 3) until the
   pending self-review draft is posted.**

   **HARD RULE — never compose inline comment payloads directly from `wk-pr`.**
   Always delegate to `wk-self-review` via the Skill tool. The pending-review
   draft (`POST /pulls/{n}/reviews` with `event` omitted) is enforced by
   `wk-self-review`; raw `gh api repos/.../pulls/{n}/comments` posts inline
   comments immediately and bypasses the GitHub-UI Submit checkpoint. Never call
   that endpoint from this skill.

3. **Poll CI** — Launch a background polling job (using the pass-the-build agent
   if available) to wait for all build steps to pass. Do not proceed while CI is
   failing.

## Step 4: Once CI is Green

1. **Run `wk-pr-resolve` drift check** — Description, self-review threads, and
   reviewer comments may have changed during the CI wait window. Invoke
   `wk-pr-resolve` to surface and resolve any drift before proceeding. Sync per
   the no-ask drift rule in Step 3.

2. **Sync PR description and check off CI items** — Re-read the description
   against the current change; check off any test-plan items now satisfied by
   green CI; sync any drifted content with `gh pr edit`. Description sync is not
   a push-time-only action — re-run after every state change (CI green, new
   commits, review verdict).

3. **HARD RULE — self-review is mandatory after CI green.** If Step 3's parallel
   self-review was skipped for any reason (e.g., the agent judged the diff
   "obvious"), invoke `wk-self-review` now. No size, simplicity, or scope
   exemption. Skipping requires explicit user instruction in the current session
   — never silent skip.

4. **Address automated review feedback** — Fetch existing review comments from
   automated tools:

   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   gh pr reviews
   ```

   Present these as a numbered list with a suggested fix for each. Ask the user:
   "How would you like to handle these automated review comments?" Wait for the
   user's response before proceeding.

   **Triage bias — fix small correct findings; defer is the exception.** A small
   (<~10-line), correct-premise finding is cheaper to fix in-round than to defer,
   which forces a re-approval round. Fix any correct-premise finding with a small
   fix; reserve defer for large, contested, or out-of-scope findings; when
   unsure, fix. Frame it as "fixing these, deferring X because Y", not "fix one,
   defer the rest".

## Step 5: Mark Ready

**HARD RULE — never end a turn with ANY draft PR whose work is done.** Any push to
an open draft PR carries an implicit commitment to `gh pr ready`, which waits on
neither CI nor a verdict. The only valid exits before `gh pr ready`:

- Explicit user instruction to pause / hold-as-draft.
- Work genuinely unfinished (not merely unreviewed or CI-red).

Iteration rounds (refactor, dedup, follow-up commits) do not reset this
commitment — each push restarts the path to ready, not the licence to stop.
"Pushed the fix" is not "work complete"; "marked ready" is — for every draft the
session opened, not only the last.

### Adversarial-review gate (after ready, before merge)

Invoke `wk-adversarial-review` after the PR is ready. **This is the completion
gate and the only dispatch point for the change.** CI runs concurrently.

Clearance follows the reviewed body of work, not SHA equality; lineage rules per
Hard Rule 2. No other skill or later push dispatches a run.

**HARD RULE — verify CI for the *current* HEAD before merge, not before ready.**
Marking ready never waits on CI. A green CI result against an earlier HEAD does
not satisfy the merge gate. Every push that lands new commits starts a fresh CI
run — confirm the run for the current HEAD SHA has **completed** and is green
before merging, and never assume a prior run covers the new
commits. Each push = one CI run that must finish. An **empty**
`statusCheckRollup` is vacuously green — require the provider's checks present,
not merely absence of red (an unregistered build reads as premature all-green).

```bash
gh pr view --json statusCheckRollup,headRefOid \
  --jq '{head: .headRefOid, checks: [.statusCheckRollup[]|(.status//.state)]|unique}'
```

Re-poll until every entry for the current `headRefOid` is terminal and green.

**HARD RULE — check off the test-plan boxes before `gh pr ready`, not after.**
Marking ready does not wait on CI or on a review verdict — both run after it —
but the body must never overstate: re-read it and tick every test-plan checkbox
already satisfied by passing local checks, leave the rest unticked, and re-sync
the moment CI goes terminal. Unchecked boxes on a ready PR read as work not
done; ticked-but-unverified boxes are worse. Any run id, SHA, or link written
while ticking comes from a command run this turn (Hard Rule 4) — this step is
where invented identifiers get in.

After the self-review is posted, automated feedback is addressed, and the
test-plan checkboxes are synced:

```bash
gh pr ready
```

Confirm to the user:
> "PR #{number} is marked ready for review: {url}"

**Trivial-PR auto-merge fast path.** Net diff <25 lines + adversarial review
`clear` with zero findings → `gh pr merge --auto --squash`. Quote the verdict;
note line count in the body. Logic-bearing or ≥25-line diffs take the full CI
poll.

## Step 6: Session Retro

After the PR is marked ready, invoke `wk-retro` to capture session learnings —
reviews what went well, what was corrected, and promotes actionable lessons to
the appropriate project files.

---
