---
name: wk-pr-break
description: >-
  Take an existing PR that has grown too large and break it into a stack of
  smaller, reviewable, individually-shippable PRs. Reads the PR description,
  every comment surface (review threads, summaries, issue comments), the
  full diff, related learnings, and any linked tickets, then proposes a
  split plan where each child PR builds and passes in isolation, is ordered
  to stand alone, and prioritizes reviewer digestibility over raw line count.
  Use when asked to "split this PR", "break down this PR", "make smaller
  PRs from this", or when wk-pr-review flags a PR as too large to review.
argument-hint: '[<pr-number-or-url>]'
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Skill
  - "Bash(git:*)"
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr checks:*)"
  - "Bash(gh pr ready:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh api:*)"
  - Write
model: sonnet
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: '2026.06.12-015811'
  internal: false
  model:
    openai: gpt-4.1
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Break

Convert one large PR into a stack of small ones without losing
functionality, breaking review continuity, or shipping a half-finished
state on any intermediate branch.

```
Read PR ──► Read context ──► Identify seams ──► Plan stack
                                                  │
                                          (≤5 children, ordered)
                                                  │
                                                  ▼
                                       Validate invariants
                                                  │
                                                  ▼
                                         Present for approval
                                                  │
                                                  ▼
                                          Execute (per-child wk-pr)
```

---

## Five invariants — every plan must satisfy all five

1. **Functional equivalence.** All child PRs merged in order reproduce the parent's behavior exactly — nothing dropped, nothing added.
2. **Isolation.** Each child builds, lints, and passes its own tests on its own branch.
   - No "tests in PR 3 cover code in PR 1" shortcuts.
3. **Stack-order coherence.** Each child reads as a self-contained change without forward-references to later PRs.
4. **Description completeness.** Every child names its blocker (prior child), what it blocks (next child), and deferred work.
5. **Reviewer digestibility.** The split is judged by reviewer ergonomics, not LOC.
   - A 600-line rename that reviews as one coherent change beats two 300-line fragments.

If a draft plan violates any invariant, **rework the plan** — do not ship a violation.

**HARD RULE:** All GitHub reads/writes route through `wk-gh`. Every
child PR's title/body emitted by this skill ends with the canonical
outbound footer per `wk-gh` Step 4, appended after any child-specific
metadata block.

---

## Stage 0: Identify the PR and pre-flight

Resolve the target PR from the argument, current branch, or ask:

```bash
PR=$(gh pr view "${1:-}" --json number,headRefName,baseRefName,title,body,url \
     2>/dev/null || gh pr view --json number,headRefName,baseRefName,title,body,url)
```

If no PR is found, stop and ask the user for the PR number/URL —
this skill is not for unfinished local work.

Confirm the working tree is clean. A dirty tree means the user has
local changes that must be either committed or stashed before the
split — the plan generator works against a known commit set, not
against in-flight edits.

### Mark the original PR as draft

Before reading any context or proposing seams, convert the original
PR back to draft state if it isn't already. While the split is in
flight the PR is structurally incomplete (its replacement stack
hasn't shipped); leaving it ready-for-review invites approvals,
auto-merge, or reviewer time spent on a PR that is about to be
superseded.

```bash
PR_STATE=$(gh pr view --json isDraft --jq .isDraft)
if [ "$PR_STATE" = "false" ]; then
  gh pr ready --undo "$PR_NUM"
fi
```

`gh pr ready --undo` is idempotent — calling it on a PR that is
already a draft is a no-op. If the call fails (e.g., the PR has
auto-merge enabled and the API refuses the transition), stop and
report; do not proceed to break a PR that could merge mid-split.

Append a note to the PR description recording why the PR was
returned to draft and the expected child stack count, so reviewers
who land on the page understand the state:

```
> ⚠️ Returned to draft for split via `wk-pr-break`. A stack of
> ~{N} child PRs will replace this one. Original diff preserved
> here as the source of truth until the stack lands.
```

The "ready" state will be restored — by the user, on the original
PR — only after every child PR in the stack has merged. This skill
does not automatically promote the PR back to ready.

---

## Stage 1: Read every PR surface

Fetch all three comment surfaces every run. For full context on these
surfaces, see `skills/pr-resolve/SKILL.md` Step 3.

```bash
PR_NUM=$(gh pr view --json number --jq .number)
# Inline review comments (anchored to file:line)
gh api repos/{owner}/{repo}/pulls/$PR_NUM/comments --paginate
```

```bash
# Review summary bodies
gh api repos/{owner}/{repo}/pulls/$PR_NUM/reviews --paginate
```

```bash
# PR conversation (issue) comments
gh api repos/{owner}/{repo}/issues/$PR_NUM/comments --paginate
```

Also fetch:

- PR description — `gh pr view --json title,body`
- Commits — `git log --oneline $BASE..HEAD`
- Full diff — `gh pr diff $PR_NUM`

Scan each comment surface for **scope signals**:

- "Can this be split?" / "Too large to review" — explicit reviewer ask; quote it in the plan.
- "Out of scope" / "Should be a follow-up" — candidates for the last child or a deferred follow-up.
- "Blocking concern" / "Don't merge until" — become exit conditions on the corresponding child.

---

## Stage 2: Read related learnings and tickets

Surface the body of knowledge that should inform the split:

- `$WK_SKILLS_HOME/learnings/skills/**/*.md` — search for entries
  whose body mentions the same files, concepts, or PR number. They
  often warn about coupling the planner would otherwise miss
  (e.g., "config X must travel with version Y").
- `~/.claude/memory/retro-log.md` — entries near the PR's create
  date often capture context not yet promoted into a learning.
- Linked Jira ticket(s) (per `wk-jira` detection) — the ticket
  description names the user-visible scope; that scope is the
  contract the stack must collectively satisfy.

If a learning warns about coupling between two parts of the diff,
**those parts cannot live in different child PRs**. Record the
constraint and respect it when proposing seams.

---

## Stage 3: Identify the seams

Walk the diff and look for **natural cut lines**. A seam is a
boundary where one side of the diff makes sense without the other.
Categorize each candidate seam:

- **Infrastructure → primitives → feature.** A new feature commonly
  decomposes as: (1) shared helper / type / migration, (2) the
  primitive that uses it, (3) the user-visible feature on top.
- **Refactor before behavior change.** Moving / renaming code with
  no behavior change is its own PR; the behavior change goes on
  top of the cleaned-up shape.
- **Test scaffold before implementation.** Adding fixtures, mocks,
  or a new test framework can land separately from the
  implementation that uses them — often the smallest, easiest
  reviewable PR.
- **Per-layer slices.** UI ↔ API ↔ DB. Each layer's change can
  often ship behind a feature flag; the user-visible surface
  flips on in the final child.
- **Per-feature slices.** Multi-feature PRs rarely need to ship as
  one — split by user-visible capability and stack by dependency.
- **Cleanup last.** Removing dead code, deprecated paths, or stale
  tests goes in the **final** child once everything that depended
  on the old shape has shipped through earlier children.

A bad seam is one that requires both sides to merge for either to
make sense. Reject those.

### Seam-quality probe

For each candidate seam, ask:

- Can this side build, lint, and pass tests with the **other side
  reverted**? (Invariant 2.)
- Can a reviewer read this side as a coherent change without
  having seen the other side? (Invariant 3.)
- Does this side leave behind any dead-end (unused symbol,
  half-wired feature, dangling test) that a future child cleans
  up? If yes, the description must explicitly call it out.

If a seam needs a temporary scaffold to satisfy invariant 2 (e.g.,
a stub function that returns a default until a later child fills
it in), document the scaffold in the child's description and tag
the future child that removes it.

---

## Stage 4: Propose the stack

Cap the stack at **≤5 children**. More than 5 indicates the seam
analysis is over-fragmenting; merge the smallest pieces back
together. Fewer is fine — sometimes 2 children is the right answer.

Produce a structured plan, one block per child:

```
### Child PR {n}/{N}: <conventional-subject> (~<size hint>)

**Stack position:** Built on top of {parent} (#parent or "main").
**Scope:** <one-paragraph user-visible description>.
**Files touched:** <list of paths or globs>; net diff ~<lines>.
**Builds / tests in isolation:** <yes — what verifies it>.
**Depends on:** <prior children in the stack, or "none">.
**Blocks:** <subsequent children, or "none">.
**Follow-up:** <deferred work this PR explicitly does not include>.
**Reviewer note:** <one sentence on why this is the natural seam>.
```

Also produce a **stack overview** table:

```
1. <subject>            (~80 LOC)   — refactor, no behavior change
2. <subject>            (~120 LOC)  — primitive on top of (1)
3. <subject>            (~200 LOC)  — feature wired through primitive
4. <subject>            (~40 LOC)   — cleanup of legacy code path
```

Every child PR's draft description must mention:

- **Stack** — links to the parent (and ultimately the original PR).
- **Blockers** — what merges before this can merge (the `Depends
  on` line).
- **Follow-up** — what this PR explicitly defers, with links to
  the child PR(s) that will pick it up, or a TODO with a tracking
  ticket if the follow-up is post-stack.

This matches `wk-pr`'s description template (see Step 2 there);
the `wk-pr-break` plan **populates** that template for each child.

### Propagate parent annotations into the right child

Extract annotations from Stage 1 (title, body, comments, commit trailers) and route each
to the appropriate child. When in doubt, include rather than drop.

| Annotation | Routing |
|------------|---------|
| `Closes #N` / `Fixes #N` | **Final child only** — earlier children carry `Refs #N`. |
| `Refs #N` / `Related to #N` | Every child touching code in the issue's scope. |
| `[BOARD-NUM]` Jira key | Every child's title (umbrella ticket; `wk-jira` transitions on final child). |
| Design doc / RFC / spec URL | Every child — reviewers of any slice need the design context. |
| Deploy / migration callout | The child that introduces the dependency, and the final child. |
| Linked demo / screenshot / Loom | The user-visible feature child (usually last). |
| `Co-Authored-By:` trailers | Commits that ship the corresponding work, per original mapping. |

For each child block, add an **Annotations** subsection so the user can audit routing:

```
**Annotations propagated:**
- Refs #NNN (Closes moves to final child)
- Spec: docs/specs/feature-x.md
- [BOARD-NUM] Jira suffix on title
```

---

## Stage 5: Validate the plan against the five invariants

Before presenting the plan to the user, walk every invariant
against every child:

| Invariant | Check |
|-----------|-------|
| 1. Functional equivalence | Concatenate the child diffs; confirm equality with the original PR's diff (modulo whitespace/conflict markers). `git diff` between the original tip and the projected tip after the last child merges should be empty. |
| 2. Isolation | For each child, mentally simulate landing only that child onto its parent — does the test command pass? Does the linter? If a child requires a forward-reference, redesign the seam. |
| 3. Stack-order coherence | Read each child's description in order with no knowledge of later children. Does each one read as a sensible change on its own? |
| 4. Description completeness | Each draft has Stack, Blockers, Follow-up populated. None is "TBD". |
| 5. Reviewer digestibility | Each child reviews as one coherent claim. No mega-child; no nano-child that's just a one-liner separated for the count. |

If any check fails, return to Stage 3 and re-cut the seams. Do
not ship a violating plan.

---

## Stage 6: Present for approval

Show the user:

1. The original PR header (title, URL, base, current size).
2. The stack overview table.
3. Each child block from Stage 4, in stack order.
4. Any constraints surfaced in Stage 1/2 that drove the cuts
   (reviewer asks quoted; learnings cited).
5. The single command path forward:

> "Approve to execute? `(a) yes, build the stack` /
> `(b) edit the plan` / `(c) save plan to file and stop`."

Auto mode default: `(c) save plan to file and stop` — building a
PR stack is a destructive multi-PR operation that exceeds the
autonomy budget for unattended runs. Generate the plan as
`docs/plans/pr-break-{pr-num}.md` (or the project's existing plan
location if one is established) and return.

---

## Stage 7: Execute (only on explicit approval)

### Child branch naming

Every child branch reuses the original PR's branch name with a
`-part-N` suffix, where `N` is the child's stack position starting
at **1**:

```
<original-branch>          # parent / source
<original-branch>-part-1   # first child (cut from $BASE_BRANCH)
<original-branch>-part-2   # second child (cut from -part-1)
<original-branch>-part-3   # third child (cut from -part-2)
...
```

If the original branch already ends in `-part-N` (the user is
re-splitting an already-split PR), append onto the **leaf** name —
do not double-suffix. `feat/foo-part-2` becoming a 2-child split
produces `feat/foo-part-2-part-1` and `feat/foo-part-2-part-2`,
not `feat/foo-part-1` (which would collide with a sibling).

Validate the names before cutting branches:

```bash
ORIG_BRANCH=$(gh pr view "$PR_NUM" --json headRefName --jq .headRefName)
for n in $(seq 1 "$N"); do
  CHILD="$ORIG_BRANCH-part-$n"
  if git show-ref --verify --quiet "refs/heads/$CHILD" \
     || git ls-remote --exit-code --heads origin "$CHILD" >/dev/null 2>&1; then
    echo "Branch $CHILD already exists locally or on origin; aborting."
    exit 1
  fi
done
```

Name collisions abort the run rather than silently overwriting —
re-running `wk-pr-break` after a partial failure must not clobber
the prior attempt's branches.

### Per-child execution

For each child, in stack order:

1. Cut the child branch from its parent (the previous child's
   branch, or `$BASE_BRANCH` for the first child).
2. Apply the child's diff. Source the diff from the original
   PR's branch via `git checkout <orig> -- <paths>` for whole
   files, or `git apply` of a pre-prepared patch for partial
   files. The original PR's branch stays unchanged until all
   children have been opened.
3. Run the project's test command (Phase 3 of `wk-workflow`); if
   it fails, stop — invariant 2 was violated by the seam, not by
   execution.
4. Invoke `wk-commit` for the child's commit (signed,
   conventional, single emoji).
5. Invoke `wk-pr` to open the child as a draft PR with the
   description populated from Stage 4.
6. Wait for CI to go green via the standard `wk-workflow` Phase 6
   loop.

After all children are open, update the original PR's description
to reference the stack ("This PR is being shipped as a stack:
#child1, #child2, ..."). Do **not** close the original PR until
the stack lands — it remains the source of truth for the full
diff during review.

If a child fails CI in a way that suggests the seam is wrong (not
a flaky test, not an infra blip), pause and ask the user before
patching the child — the failure may indicate that the plan needs
to be re-cut.

---

## Coordination with other skills

- **`wk-workflow`** — this skill produces the plan that `wk-workflow`
  Phase 1 would otherwise produce manually for a multi-step task.
  Stage 7 invokes Phase 6 loop logic per child.
- **`wk-pr`** — each child PR is opened via `wk-pr`'s draft + CI +
  ready flow. The Stage 4 child block is the input.
- **`wk-commit`** — child commits use `wk-commit`'s conventional
  format with single-emoji classifier.
- **`wk-pr-resolve`** — comments collected in Stage 1 may also
  inform `wk-pr-resolve` if the original PR has open feedback;
  the planner's job is structural, not addressing the comments.
- **`wk-pr-update`** — if children land out of order or main
  moves under the stack, use `wk-pr-update` to keep each child's
  base current.

---

## Quick Reference

| Trigger | Stages |
|---------|--------|
| `/wk-pr-break` (current branch's PR) | 0 → 6 always; 7 on approval |
| `/wk-pr-break <pr-num>` | Same; explicit PR target |
| Auto mode | 0 → 6 then save plan to file and stop |
| Reviewer asks "can this be split?" | Quote the ask; cite as the trigger in the plan |
| Plan violates an invariant | Return to Stage 3; never ship a violating plan |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr-break`).
