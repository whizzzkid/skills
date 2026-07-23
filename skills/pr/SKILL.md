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
  version: '2026.07.23-190838'
  model:
    openai: gpt-4.1-mini
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
1. **Preserve PR body metadata across description rewrites.** Before
   overwriting the PR description, preserve metadata lines — see
   `skills/pr/references/pr-description-metadata.md`.
2. **Adversarial review gates every transition.** Invoke
   `wk-adversarial-review` before:
   - First push that creates the PR (before `gh pr create`).
   - Every subsequent push to the PR branch.
   - `gh pr ready` (Step 5).
   - Any force-push or rebase that rewrites pushed history.

   `blocked` verdict → no `gh pr create`, no `gh pr ready`, no push. Fix
   blockers (each via `wk-commit`), re-invoke until clear. No size or scope
   exemption.

   **No-ask on review findings.** Findings from any mandatory pre-flight review
   (`wk-adversarial-review`, and `wk-arch-review` when a spec/design doc is in
   the diff) are mandatory to incorporate — never ask "should I fold these in?".
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

## Step 1: Assess Scope

### Detect the true base branch (run unconditionally)

Detect the branch's actual fork point before measuring scope. Assuming the
default branch is the base → PR with unrelated commits in the diff (from a
parent in-flight branch), CI failures against the wrong target, and a silent
stacked-PR lacking the `[<feature>-part-N/M]` annotation.

Compute merge-base distance between the current branch and every candidate base
— the default branch plus every open PR's `headRefName` (yours and others'). The
candidate with the **closest** merge-base (smallest commit distance) is the real
base; ties prefer the default branch.

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
                 | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

# Candidate set: default + every open PR's head ref
CANDIDATES=$(
  { echo "$DEFAULT_BRANCH"
    gh pr list --state open --json headRefName --jq '.[].headRefName'
  } | sort -u
)

BEST_BASE="$DEFAULT_BRANCH"
BEST_DIST=999999
HEAD_SHA=$(git rev-parse HEAD)
for CAND in $CANDIDATES; do
  # Resolve to origin/<cand>, else the local ref; a fetch failure must not drop a local-only candidate.
  REF="origin/$CAND"
  git rev-parse --verify --quiet "$REF" >/dev/null 2>&1 \
    || git fetch origin "$CAND" --quiet 2>/dev/null \
    || REF="$CAND"
  MB=$(git merge-base "$HEAD_SHA" "$REF" 2>/dev/null) || continue
  [ "$MB" = "$HEAD_SHA" ] && continue   # candidate is downstream of HEAD; not a base
  DIST=$(git rev-list --count "$MB..$HEAD_SHA")
  if [ "$DIST" -lt "$BEST_DIST" ] || \
     { [ "$DIST" -eq "$BEST_DIST" ] && [ "$CAND" = "$DEFAULT_BRANCH" ]; }; then
    BEST_DIST=$DIST
    BEST_BASE=$CAND
  fi
done
```

- **`$BEST_DIST` unchanged (`999999`) after the loop = detection FAILURE, not
  "base = default"** — no candidate yielded a merge-base. Before requiring an
  explicit `--base`, retry the merge-base directly against
  `origin/$DEFAULT_BRANCH` (fetch first); a stale local ref is the usual cause, so
  trust a succeeding remote result rather than defaulting.

If `$BEST_BASE` differs from `$DEFAULT_BRANCH`, surface to the user before doing
anything else — silent mis-basing is costly to undo:

> "This branch was forked from `{BEST_BASE}` (open PR #{N}), not
> `{DEFAULT_BRANCH}`. Choose:
>
> **A)** Create this PR with `--base {BEST_BASE}` and treat it as stacked (adds
> `[<feature>-part-N/M]` and `## Stack` to the body).
> **B)** Rebase onto `{DEFAULT_BRANCH}` first, then create against the default
> base.
> **C)** Cancel.
>
> Reply `A` / `B` / `C`."

- Auto mode picks **A** — preserving the existing fork point is non-destructive;
  the stacked-PR convention covers the metadata.
- **B** invokes `wk-pr-update` to rebase before proceeding.

**Draft-base override.** Before defaulting to **A**, check whether `$BEST_BASE`
is the head of an open PR still in **draft** state:

```bash
DRAFT=$(gh pr list --state open --head "$BEST_BASE" \
          --json isDraft --jq '.[0].isDraft')
```

If `DRAFT == true`, the parent has not merged and stacking produces two PRs the
reviewer must sequence — usually a false split where both changesets should land
together. Surface the draft status in the prompt and **default auto mode to B**
(retarget to `$DEFAULT_BRANCH`, include both changesets) instead of A. Stacking
on a draft base then requires explicit user opt-in.

**Merged-base check.** Before targeting any explicitly-named base branch — a
`wk-pr` base argument, or a reviewed branch chosen for a follow-up PR — verify it
is not already merged. Auto-detection only scans `--state open` PRs, so a merged
branch never enters the candidate set; the explicit-base path has no such guard.

```bash
gh pr view "$BASE_CANDIDATE" --json state --jq .state
```

If `state == "MERGED"`, the branch is gone and the follow-up must target
`$DEFAULT_BRANCH`. Retarget to `$DEFAULT_BRANCH`, notify the user, never push to
a merged branch.

### Measure scope against the resolved base

Use `$BEST_BASE` for the eventual `gh pr create --base` flag, but always
diff/measure scope against `origin/$BEST_BASE` (fetch first) — a stale local base
ref reports already-merged files as phantom additions and inflates LOC.

```bash
git fetch origin "$BEST_BASE" --quiet
git diff "origin/$BEST_BASE...HEAD" --stat
git diff "origin/$BEST_BASE...HEAD" --shortstat
```

- Diff exceeds ~30 lines → ask the user about splitting further via
  `wk-pr-break` (in addition to any stacking implied by `$BEST_BASE`).
- Borderline or unclear → ask the user's preference.
- Pass `$BEST_BASE` through to Step 2 — never re-detect or default back to
  `main`.

### Check open PRs for a related spec before adding a new one

Branch adds a doc under `docs/specs/` (or equivalent) → search open PRs for a
same-domain spec before treating it as standalone; prefer stacking onto an
existing spec over a parallel doc (a parallel in-flight spec forces a later
consolidation). Query + routing:
[`references/check-open-prs-for-spec.md`](references/check-open-prs-for-spec.md).

## Step 2: Create Draft PR

### Adversarial-review gate (run before `gh pr create`)

**Honor a review waiver before dispatching.** User's current-session instruction
waives review ("no review needed") → suppress this Skill call and continue to
`gh pr create`; never rely on the user denying the permission prompt to enforce
their own instruction. (Rule 0 `wk-gh` routing + footer still apply.)

Invoke `wk-adversarial-review` against `$BEST_BASE...HEAD`. Do not proceed to
`gh pr create` until the verdict is `clear` (or `suggestions-only` and the user
accepted the offered A/B/C choice).

On `blocked`, address each blocker with atomic `wk-commit` invocations, re-invoke
`wk-adversarial-review`. Loop until clear.

**Always create PRs in draft mode** (`--draft` flag). Never create a non-draft
PR unless the user explicitly asks.

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

Before composing the PR body, check the target repo for a GitHub PR template.
Search these paths in order, use the first match:

```bash
TEMPLATE_FILE=""
for tpl in \
  .github/pull_request_template.md \
  .github/PULL_REQUEST_TEMPLATE.md \
  pull_request_template.md \
  PULL_REQUEST_TEMPLATE.md; do
  [ -f "$tpl" ] && TEMPLATE_FILE="$tpl" && break
done

# If no single file matched, check the multi-template directory
if [ -z "$TEMPLATE_FILE" ]; then
  for d in .github/PULL_REQUEST_TEMPLATE .github/pull_request_template; do
    [ -d "$d" ] && ls "$d"/*.md && break
  done
fi
```

| Scenario | Action |
|----------|--------|
| Single template file found | Read it and use as the PR body structure |
| Template directory found | List the `.md` files, ask the user which to use, then read it |
| No template found | Fall back to the hardcoded templates below |

When using a repo template:

- **Populate every section** with real content derived from the diff and commit
  history. No placeholder text or unfilled sections.
- **Preserve the template's structure** — keep its headings, order, and any
  boilerplate (checkboxes, legal text, etc.) intact.
- **Stacked PRs** → append a `## Stack` section after the summary (or first
  heading) if the template does not already include one.
- Template sections irrelevant to the current changes → fill with "N/A" or a
  brief note explaining why they don't apply.
- **Guarantee a verification section.** After populating, confirm a Testing /
  Test plan / verification section exists. If none, append `## Testing` listing
  concrete checks run (commands + outcomes: linters/formatters clean, hooks run
  locally, CI/pipeline template render, manual steps). Treat a missing
  verification section as drift to fix before `gh pr create` — a
  description-check bot otherwise flags "Testing section missing" and forces a
  second cycle.
- **Prod-facing diff & incident-triggered bugfix bodies** have extra required
  sections — see the Body extras reference below; apply at composition time.

### Superseded & closed PRs

`Closes`/`Fixes`/`Resolves #N` close **issues** only, never a PR; a
squash-merged + deleted-base PR cannot be reopened or retargeted. Full close
semantics and the fresh-superseding-PR recipe:
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

`--base "$BEST_BASE"` MUST be present on every `gh pr create` call — never omit
it and rely on the default; defaulting silently re-introduces the mis-basing
failure mode.

PR titles use the same conventional commit + emoji scheme as commit messages.

### Jira key suffix

Before composing the title, detect a Jira key (`[A-Z][A-Z0-9]+-\d+`) from the
branch name and most recent commit message:

```bash
JIRA_KEY=$(git rev-parse --abbrev-ref HEAD | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1)
[ -z "$JIRA_KEY" ] && JIRA_KEY=$(git log -1 --pretty=%B | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1)
```

Key found and title does not already end with `[<KEY>]` → append it as the last
token: `feat(scope): ✨ description [<KEY>]`. Prevents wk-jira Stage 3 from
patching a keyless title after the PR already exists. No key found → compose the
title without a suffix; do not invent one.

### Stacking multiple PRs

Splitting work into a stack of dependent PRs → **prefer the `gh stack` extension**
(`github/gh-stack`) when available: it is installed AND the repo is enabled for
the stacks preview (gh v2.0+). Delegate the whole stack lifecycle (branch
creation, base chaining, cascading rebase, linked submission) to it — never
hand-chain `--base`.

- Probe once (`gh stack view`); non-zero / not-installed / repo-not-enabled →
  manual fallback.
- Every PR in a merged stack gets `[<feature>-part-N/M]` as its final title
  token (N = 1-based position, M = stack size; after any `[<KEY>]`), in both the
  `gh stack` and manual paths.
- **Read merge/dependency order from `baseRefName`, never `part-N` labels or
  memory** — query each PR's base (`gh pr view <n> --json baseRefName`); a
  trunk-based PR is independent, a PR merges only after the PR owning its base.
  Labels drift after any re-parent and fabricate nonexistent dependencies.
- Manual fallback: `[<feature>-part-N/M]` title suffix + injected `## Stack`
  body + `--base previous-branch`, each PR green in isolation.

`gh stack` command sequence, availability probe, and the manual fallback recipe:
[`references/gh-stack-stacking.md`](references/gh-stack-stacking.md).

### Body extras — cross-links, previews, incident & rollout sections

Four body-composition sub-steps (Stack cross-links, markdown-preview links,
incident bugfix body, Rollout section) live in
[`references/pr-body-extras.md`](references/pr-body-extras.md). Apply each that
matches when composing the body.

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

**HARD RULE — never end a turn with a draft PR whose work is done.** Any push to
an open draft PR carries an implicit commitment: re-run the adversarial gate,
then `gh pr ready` once CI is green. The only valid exits before `gh pr ready`:

- CI failing after 3 fix-loop attempts.
- An open `blocked` adversarial-review verdict.
- Explicit user instruction to pause / hold-as-draft.

Iteration rounds (refactor, dedup, follow-up commits) do not reset this
commitment — each push restarts the path to ready, not the licence to stop.
"Pushed the fix" is not "work complete"; "marked ready" is.

### Final adversarial-review gate

Invoke `wk-adversarial-review` one more time against PR HEAD before
`gh pr ready`. Self-review, CI fixes, and automated-feedback resolution may have
introduced new commits since Step 2's gate. Re-running catches drift between
draft and ready.

**Scoped skip — mechanical-only delta.** If the *only* commits since the last
`clear` verdict are direct mechanical responses to that verdict's own blockers
(no new logic, no refactor, no scope addition), the final gate may be skipped.
Note the skip and the cleared HEAD SHA in the PR. Any commit touching logic or
adding behavior still requires re-running the gate.

**HARD RULE — verify CI for the *current* HEAD before `gh pr ready`.** A green
CI result against an earlier HEAD does not satisfy the gate. Every push that
lands new commits starts a fresh CI run — confirm the run for the current HEAD
SHA has **completed** and is green before marking ready; never race `gh pr ready`
ahead of a still-`running` build, and never assume a prior run covers the new
commits. Each push = one CI run that must finish. An **empty**
`statusCheckRollup` is vacuously green — require the provider's checks present,
not merely absence of red (an unregistered build reads as premature all-green).

```bash
gh pr view --json statusCheckRollup,headRefOid \
  --jq '{head: .headRefOid, checks: [.statusCheckRollup[].status] | unique}'
```

Re-poll until the run for the current `headRefOid` is `COMPLETED` and green.

**HARD RULE — check off the test-plan boxes before `gh pr ready`, not after.**
The CI-green sync (Step 4.2) is a blocking precondition for `gh pr ready`, not an
aspiration: re-read the PR body and tick every test-plan checkbox now satisfied
by green CI and passing local checks. Unchecked boxes on a ready PR read as work
not done. Do not call `gh pr ready` until the body's checkboxes match reality.

After the self-review is posted, automated feedback is addressed, the test-plan
checkboxes are synced, and the adversarial-review verdict is `clear`:

```bash
gh pr ready
```

Confirm to the user:
> "PR #{number} is marked ready for review: {url}"

**Trivial-PR auto-merge fast path.** When the net diff is under 25 lines
(`git diff $BASE...HEAD --shortstat`) **and** the final adversarial-review
verdict is `clear` with zero findings, skip the poll-and-wait CI loop: mark
ready, then `gh pr merge --auto --squash` so it lands the moment required checks
pass. Note the line count and auto-merge intent in the PR body so reviewers see
why. Any logic-bearing change, or a diff at/over the threshold, takes the full
CI poll above — the fast path is for mechanical, low-risk deltas only.

## Step 6: Session Retro

After the PR is marked ready, invoke `wk-retro` to capture session learnings —
reviews what went well, what was corrected, and promotes actionable lessons to
the appropriate project files.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "create a PR" | Full workflow: draft → CI → self-review → ready → retro |
| "stack this PR" | Delegate to `gh stack` when available; else manual `[<feature>-part-N/M]` + `--base` |
| "mark PR ready" | Skip to step 5 |
| New commits pushed | Re-run from step 3 (update description, re-poll CI) |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr`).
