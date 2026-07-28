---
name: wk-pr-break
description: >-
  Break an over-large PR into a stack of smaller, individually-shippable
  PRs — reads the description, all comment surfaces, the full diff, and
  linked tickets, then proposes a split where each child builds in
  isolation. Use for "split this PR", "break down this PR", or when
  wk-pr-review flags a PR as too large.
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
  version: "2026.07.28-171053"
  internal: false
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Break

Convert one large PR into a stack of small ones. Never lose functionality, break review continuity, or ship a half-finished state on any intermediate branch.

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

1. **Functional equivalence** — all child PRs merged in order reproduce the parent's behavior exactly; nothing dropped, nothing added.
2. **Isolation** — each child builds, lints, passes its own tests on its own branch. No "tests in PR 3 cover code in PR 1" shortcuts.
3. **Stack-order coherence** — each child reads as a self-contained change; no forward-references to later PRs.
4. **Description completeness** — each child names its blocker (prior child), what it blocks (next child), and deferred work.
5. **Reviewer digestibility** — judge the split by reviewer ergonomics, not LOC. A 600-line rename that reviews as one coherent change beats two 300-line fragments.

Plan violates any invariant → **rework the plan**; never ship a violation.

**HARD RULE:** All GitHub reads/writes route through `wk-gh`. Every child PR's title/body ends with the canonical outbound footer per `wk-gh` Step 4, appended after any child-specific metadata block.

---

## Stage 0: Identify the PR and pre-flight

Resolve the target PR from the argument, current branch, or ask:

```bash
PR=$(gh pr view "${1:-}" --json number,headRefName,baseRefName,title,body,url \
     2>/dev/null || gh pr view --json number,headRefName,baseRefName,title,body,url)
```

- No PR found → stop and ask the user for the PR number/URL. This skill is not for unfinished local work.
- Confirm the working tree is clean. Dirty tree = local changes; commit or stash before the split. The plan generator works against a known commit set, not in-flight edits.

### Mark the original PR as draft

Before reading context or proposing seams, convert the original PR back to draft if it isn't already. While the split is in flight the PR is structurally incomplete (replacement stack hasn't shipped); leaving it ready-for-review invites approvals, auto-merge, or reviewer time spent on a PR about to be superseded.

```bash
PR_STATE=$(gh pr view --json isDraft --jq .isDraft)
if [ "$PR_STATE" = "false" ]; then
  gh pr ready --undo "$PR_NUM"
fi
```

- `gh pr ready --undo` is idempotent — calling it on an already-draft PR is a no-op.
- Call fails (e.g., PR has auto-merge enabled and the API refuses the transition) → stop and report. Do not break a PR that could merge mid-split.

Append a note to the PR description recording why it was returned to draft and the expected child stack count, so reviewers who land on the page understand the state:

```
> ⚠️ Returned to draft for split via `wk-pr-break`. A stack of
> ~{N} child PRs will replace this one. Original diff preserved
> here as the source of truth until the stack lands.
```

"Ready" state is restored by the user, on the original PR, only after every child PR has merged. This skill does not automatically promote the PR back to ready.

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

- "Can this be split?" / "Too large to review" → explicit reviewer ask; quote it in the plan.
- "Out of scope" / "Should be a follow-up" → candidates for the last child or a deferred follow-up.
- "Blocking concern" / "Don't merge until" → exit conditions on the corresponding child.

---

## Stage 2: Read related learnings and tickets

Surface knowledge that should inform the split:

- `$WK_SKILLS_HOME/learnings/skills/**/*.md` — entries mentioning the same files, concepts, or PR number. Often warn about coupling the planner would miss (e.g., "config X must travel with version Y").
- `$HOME/.claude/memory/retro-log.md` — entries near the PR's create date often capture context not yet promoted into a learning.
- Linked Jira ticket(s) (per `wk-jira` detection) — the ticket description names the user-visible scope; that scope is the contract the stack must collectively satisfy.

Learning warns about coupling between two parts of the diff → **those parts cannot live in different child PRs**. Record the constraint and respect it when proposing seams.

---

## Stage 3: Identify the seams

Walk the diff for **natural cut lines**. A seam is a boundary where one side of the diff makes sense without the other. Categorize each candidate:

- **Infrastructure → primitives → feature** — feature decomposes as: (1) shared helper/type/migration, (2) the primitive using it, (3) the user-visible feature on top.
- **Refactor before behavior change** — moving/renaming code with no behavior change is its own PR; the behavior change lands on top of the cleaned-up shape.
- **Test scaffold before implementation** — fixtures, mocks, or a new test framework can land separately from the implementation that uses them; often the smallest, easiest reviewable PR.
- **Per-layer slices** — UI ↔ API ↔ DB. Each layer can often ship behind a feature flag; the user-visible surface flips on in the final child.
- **Per-feature slices** — multi-feature PRs rarely need to ship as one; split by user-visible capability, stack by dependency.
- **Cleanup last** — removing dead code, deprecated paths, or stale tests goes in the **final** child, once everything depending on the old shape has shipped through earlier children.

Bad seam = requires both sides to merge for either to make sense. Reject those.

### Seam-quality probe

For each candidate seam, ask:

- Can this side build, lint, pass tests with the **other side reverted**? (Invariant 2.)
- Can a reviewer read this side as a coherent change without having seen the other side? (Invariant 3.)
- Does this side leave a dead-end (unused symbol, half-wired feature, dangling test) a future child cleans up? Yes → the description must explicitly call it out.
- Does this side add a gate / validation / enforcement that goes CI-red when the data it checks is absent? Yes → the PR **providing that data must be an ancestor**, never a descendant. Order by data-dependency, not conceptual layer (schema → enforcement → data inverts it); a mis-ordered gate is CI-red in isolation and needs post-hoc `git rebase --onto` surgery to reorder.

Seam needs a temporary scaffold to satisfy invariant 2 (e.g., a stub returning a default until a later child fills it in) → document the scaffold in the child's description and tag the future child that removes it.

**HARD RULE — ordinals track the base graph, order is read only from `baseRefName`.** Reordering a stack after its PRs exist (`git rebase --onto` to re-parent a child) invalidates the `part-N/M` ordinals — they now imply a merge order the base graph contradicts and become an actively-misleading source of truth. In the same step either renumber the labels to the new topological order, or drop ordinal labels and state each PR's parent explicitly (`base: <branch>`). Derive any merge/dependency order strictly from `baseRefName` edges (`gh pr view <n> --json headRefName,baseRefName`) — never from `part-N` labels or memory; after any re-parent, confirm the ordinal sequence still matches the base graph and fix mismatches before stating the order anywhere.

---

## Stage 4: Propose the stack

Cap the stack at **≤5 children**. More than 5 → seam analysis is over-fragmenting; merge the smallest pieces back together. Fewer is fine — sometimes 2 children is the right answer.

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
- **Blockers** — what merges before this can merge (the `Depends on` line).
- **Follow-up** — what this PR explicitly defers, with links to the child PR(s) that pick it up, or a TODO with a tracking ticket if the follow-up is post-stack.

This matches `wk-pr`'s description template (Step 2 there); the `wk-pr-break` plan **populates** that template for each child.

### Propagate parent annotations into the right child

Extract annotations from Stage 1 (title, body, comments, commit trailers) and route each to the appropriate child. When in doubt, include rather than drop.

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

Before presenting, walk every invariant against every child:

| Invariant | Check |
|-----------|-------|
| 1. Functional equivalence | Concatenate the child diffs; confirm equality with the original PR's diff (modulo whitespace/conflict markers). `git diff` between the original tip and the projected tip after the last child merges should be empty. |
| 2. Isolation | For each child, mentally simulate landing only that child onto its parent — does the test command pass? Does the linter? If a child requires a forward-reference, redesign the seam. |
| 3. Stack-order coherence | Read each child's description in order with no knowledge of later children. Does each one read as a sensible change on its own? |
| 4. Description completeness | Each draft has Stack, Blockers, Follow-up populated. None is "TBD". |
| 5. Reviewer digestibility | Each child reviews as one coherent claim. No mega-child; no nano-child that's just a one-liner separated for the count. |

Any check fails → return to Stage 3 and re-cut the seams. Never ship a violating plan.

---

## Stage 6: Present for approval

Show the user:

1. Original PR header (title, URL, base, current size).
2. Stack overview table.
3. Each child block from Stage 4, in stack order.
4. Constraints surfaced in Stage 1/2 that drove the cuts (reviewer asks quoted; learnings cited).
5. The single command path forward:

> "Approve to execute? `(a) yes, build the stack` /
> `(b) edit the plan` / `(c) save plan to file and stop`."

Auto mode default: `(c) save plan to file and stop` — building a PR stack is a destructive multi-PR operation exceeding the autonomy budget for unattended runs. Generate the plan as `docs/plans/pr-break-{pr-num}.md` (or the project's existing plan location if established) and return.

---

## Stage 7: Execute (only on explicit approval)

### Child branch naming

Every child branch reuses the original PR's branch name with a `-part-N` suffix, where `N` is the child's stack position starting at **1**:

```
<original-branch>          # parent / source
<original-branch>-part-1   # first child (cut from $BASE_BRANCH)
<original-branch>-part-2   # second child (cut from -part-1)
<original-branch>-part-3   # third child (cut from -part-2)
...
```

Original branch already ends in `-part-N` (re-splitting an already-split PR) → append onto the **leaf** name; do not double-suffix. `feat/foo-part-2` becoming a 2-child split produces `feat/foo-part-2-part-1` and `feat/foo-part-2-part-2`, not `feat/foo-part-1` (which would collide with a sibling).

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

Name collisions abort the run rather than silently overwriting — re-running `wk-pr-break` after a partial failure must not clobber the prior attempt's branches.

### Per-child execution

For each child, in stack order:

1. Cut the child branch from its parent (the previous child's branch, or `$BASE_BRANCH` for the first child).
2. Apply the child's diff. Source it from the original PR's branch via `git checkout <orig> -- <paths>` for whole files, or `git apply` of a pre-prepared patch for partial files. The original PR's branch stays unchanged until all children are opened.
3. Run the project's test command (Phase 3 of `wk-workflow`); fails → stop. Invariant 2 was violated by the seam, not by execution.
4. Invoke `wk-commit` for the child's commit (signed, conventional, single emoji).
5. Invoke `wk-pr` to open the child as a draft PR with the description populated from Stage 4.
6. Wait for CI to go green via the standard `wk-workflow` Phase 6 loop.

After all children are open, update the original PR's description to reference the stack ("This PR is being shipped as a stack: #child1, #child2, ..."). Do **not** close the original PR until the stack lands — it remains the source of truth for the full diff during review.

Child fails CI in a way suggesting the seam is wrong (not a flaky test, not an infra blip) → pause and ask the user before patching the child. The failure may indicate the plan needs re-cutting.

---

## Coordination with other skills

- **`wk-workflow`** — produces the plan `wk-workflow` Phase 1 would otherwise produce manually for a multi-step task. Stage 7 invokes Phase 6 loop logic per child.
- **`wk-pr`** — each child PR opens via `wk-pr`'s draft + CI + ready flow. The Stage 4 child block is the input.
- **`wk-commit`** — child commits use `wk-commit`'s conventional format with single-emoji classifier.
- **`wk-pr-resolve`** — comments collected in Stage 1 may inform `wk-pr-resolve` if the original PR has open feedback; the planner's job is structural, not addressing the comments.
- **`wk-pr-update`** — children land out of order or main moves under the stack → use `wk-pr-update` to keep each child's base current.

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
