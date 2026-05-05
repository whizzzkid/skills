---
name: wk-pr-break
description: >-
  Take an existing PR that has grown too large and break it into a stack of
  smaller, reviewable, individually-shippable PRs. Reads the PR description,
  every comment surface (review threads, summaries, issue comments), the
  full diff, related learnings, and any linked tickets, then proposes a
  split plan obeying five invariants: (1) all child PRs together reproduce
  the original functionality; (2) each child PR builds and tests pass in
  isolation; (3) the stack order makes each change make sense on its own;
  (4) every child PR's description names its blockers and follow-up work;
  (5) the split prioritizes reviewer digestibility, not raw line count.
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
metadata:
  author: whizzzkid
  version: '2026.05.01-080947'
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

1. **Functional equivalence.** All child PRs merged in stack order
   reproduce the parent PR's behavior exactly. No feature dropped; no
   behavior added.
2. **Isolation.** Each child PR builds, lints, and passes its own
   tests on its own branch. No "tests in PR 3 cover code in PR 1"
   shortcuts.
3. **Stack-order coherence.** Each child reads as a self-contained
   change in its own right — a refactor, a primitive, a feature
   slice — without forward-references to PRs that don't exist yet.
4. **Description completeness.** Every child PR description names
   what it depends on (parent PR in the stack), what it blocks
   (children that follow), and what it leaves for follow-up
   (deferred work, known TODOs, dead code that lives until the
   final child).
5. **Reviewer digestibility.** The split is judged by reviewer
   ergonomics, not LOC. A 600-line refactor that reviews as one
   coherent rename beats two 300-line PRs that fragment the rename.

If a draft plan violates any invariant, **rework the plan** — do
not ship a violation and call it good enough.

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

Three surfaces, all read every run (the same three-surface rule
that `wk-pr-resolve` uses — silent-skip on any surface drops
context the planner needs):

```bash
PR_NUM=$(gh pr view --json number --jq .number)

# Inline review comments (anchored to file:line)
gh api repos/{owner}/{repo}/pulls/$PR_NUM/comments --paginate

# Review summary bodies
gh api repos/{owner}/{repo}/pulls/$PR_NUM/reviews --paginate

# PR conversation (issue) comments
gh api repos/{owner}/{repo}/issues/$PR_NUM/comments --paginate
```

Plus:

- The PR description (title + body) — captures intent, linked tickets,
  test plan.
- Every commit on the branch — `git log --oneline $BASE..HEAD`.
- The full diff — `gh pr diff $PR_NUM`.

Scan each comment surface for **scope signals** the planner must
honor:

- "Can this be split?" / "Too large to review" / "Please break this
  up" — explicit reviewer ask. Quote the comment in the plan.
- "Out of scope" / "Should be a follow-up" — flagged candidates for
  the **last** child PR or for a deferred follow-up.
- "Blocking concern" / "Don't merge until" — these become **exit
  conditions** on the corresponding child PR.

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

The original PR carries metadata that downstream readers and
automation rely on — GitHub issue links, Jira keys, design-doc
URLs, deploy/test notes, hand-curated context. The split must
preserve every annotation, but distribute them so each child
carries only what is relevant to *its* slice. Blindly copying
every annotation into every child creates noise; dropping any
annotation loses traceability.

Extract from Stage 1's reads — title, body, comments, commit
trailers — and classify each annotation:

| Annotation kind | Routing rule |
|-----------------|--------------|
| `Closes #N` / `Fixes #N` (GitHub issue auto-close) | **Final child only.** Closing the issue before the user-visible behavior ships claims work that hasn't shipped. The earlier children carry `Refs #N` instead, so the issue thread still surfaces them. |
| `Refs #N` / `Related to #N` (non-closing reference) | **Every child** that touches code in the issue's scope. Cheap context for reviewers; no auto-close side effect. |
| Jira key suffix `[BOARD-NUM]` (per `wk-jira`) | **Every child's title.** The shared ticket is the umbrella; `wk-jira`'s state machine still transitions In Progress → In Review → Done off the *final* child's merge, not each one. |
| Linked design doc / RFC / spec URL | **Every child.** Reviewers of any slice need the design context to evaluate fit. |
| Linked benchmark / perf data / load-test result | **The child that touches the path being measured.** Other children skip — the data does not apply to them. |
| Linked screenshot / Loom / demo | **The user-visible feature child** (usually the final one, or the per-feature slice that produces the demo'd state). |
| Hand-written reviewer notes ("ignore the test churn", "this depends on env var X being set") | **The child(ren) that actually require the note.** Drop from children where the note is irrelevant. |
| `Co-Authored-By:` trailers from the parent's commits | Preserve on the **commits** that ship the corresponding work, per the original commit-to-author mapping. |
| Deploy / migration callouts ("requires data migration", "feature flag X must be on") | **The child that introduces the dependency** AND the **final child** if the dependency stays load-bearing once the stack lands. |

When in doubt about routing, prefer **including** the annotation in
a child over dropping it — the cost of an extra `Refs #N` line is
zero; the cost of losing a deploy callout is real.

For each child block in Stage 4's plan output, add an
**Annotations** subsection listing the propagated metadata so the
user can audit routing during Stage 6 review:

```
**Annotations propagated:**
- Refs #NNN (issue from parent — Closes moves to final child)
- Spec: docs/specs/feature-x.md (carried from parent)
- [<KEY>] Jira suffix on title
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
