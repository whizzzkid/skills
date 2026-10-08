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

Produce a structured plan using the child block template and annotation routing table in [references/child-block-template.md](references/child-block-template.md). One block per child, plus a stack overview table. Populate `wk-pr`'s description template for each child.

---

## Stage 5: Validate the plan against the five invariants

Walk every invariant against every child: (1) functional equivalence — child diffs concatenated = parent diff, (2) isolation — each child builds/tests on its parent alone, (3) stack-order coherence — each reads as self-contained, (4) description completeness — Stack/Blockers/Follow-up populated, (5) reviewer digestibility — coherent claims, no mega/nano splits.

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

Branch naming (`-part-N` suffix), collision validation, and per-child execution loop (cut → apply → test → commit → PR → CI) are in [references/execution-loop.md](references/execution-loop.md). Child CI failure suggesting a bad seam → pause and ask before patching.

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
