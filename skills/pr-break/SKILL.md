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
  version: "2026.10.09-184159"
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

Convert one large PR into a stack of small ones. Never lose functionality, break review continuity, or ship a
half-finished state on any intermediate branch. Flow: read PR → read context → identify seams → plan stack (≤5 children,
ordered) → validate invariants → present for approval → execute (per-child `wk-pr`).

## Five invariants — every plan must satisfy all five; violation → **rework the plan**, never ship it

1. **Functional equivalence** — all child PRs merged in order reproduce the parent's behavior exactly; nothing dropped,
   nothing added.
2. **Isolation** — each child builds, lints, passes its own tests on its own branch. No "tests in PR 3 cover code in PR
   1" shortcuts.
3. **Stack-order coherence** — each child reads as a self-contained change; no forward-references to later PRs.
4. **Description completeness** — each child names its blocker (prior child), what it blocks (next child), and deferred
   work.
5. **Reviewer digestibility** — judge the split by reviewer ergonomics, not LOC. A 600-line rename that reviews as one
   coherent change beats two 300-line fragments.

**HARD RULE:** All GitHub reads/writes follow [`wk-gh`](../gh/README.md). Each child PR body's footer goes after any
child-specific metadata block.

## Stage 0: Identify the PR and pre-flight

Resolve the target PR from the argument, current branch, or ask:

```bash
PR=$(gh pr view "${1:-}" --json number,headRefName,baseRefName,title,body,url \
     2>/dev/null || gh pr view --json number,headRefName,baseRefName,title,body,url)
```

- No PR found → stop and ask for the PR number/URL; this skill is not for unfinished local work. Dirty working tree →
  commit or stash before the split; the plan works against a known commit set, not in-flight edits.

**Mark the original PR as draft.** Before reading context or proposing seams, convert the original PR to draft if it
isn't already: a ready PR invites approvals, auto-merge, or reviewer time on a PR about to be superseded.

```bash
PR_STATE=$(gh pr view --json isDraft --jq .isDraft)
if [ "$PR_STATE" = "false" ]; then
  gh pr ready --undo "$PR_NUM"
fi
```

- `gh pr ready --undo` is idempotent (no-op on an already-draft PR). Call fails (e.g., auto-merge enabled and the API
  refuses the transition) → stop and report. Do not break a PR that could merge mid-split.
- Append this note to the PR description:

```
> ⚠️ Returned to draft for split via `wk-pr-break`. A stack of
> ~{N} child PRs will replace this one. Original diff preserved
> here as the source of truth until the stack lands.
```

- Never promote the PR back to ready: the user restores "ready" on the original PR only after every child PR has merged.

## Stage 1: Read every PR surface

Fetch all three comment surfaces every run (context: `skills/pr-resolve/SKILL.md` Step 3):

```bash
PR_NUM=$(gh pr view --json number --jq .number)
# Inline review comments (anchored to file:line)
gh api repos/{owner}/{repo}/pulls/$PR_NUM/comments --paginate
# Review summary bodies
gh api repos/{owner}/{repo}/pulls/$PR_NUM/reviews --paginate
# PR conversation (issue) comments
gh api repos/{owner}/{repo}/issues/$PR_NUM/comments --paginate
```

Also fetch: description (`gh pr view --json title,body`), commits (`git log --oneline $BASE..HEAD`), full diff
(`gh pr diff $PR_NUM`). Scan comments for **scope signals**: "Can this be split?" / "Too large to review" → explicit
reviewer ask, quote it in the plan; "Out of scope" / "Should be a follow-up" → candidates for the last child or a
deferred follow-up; "Blocking concern" / "Don't merge until" → exit conditions on the corresponding child.

## Stage 2: Read related learnings and tickets

- Read `$WK_SKILLS_HOME/learnings/skills/**/*.md` entries mentioning the same files, concepts, or PR number (they warn
  about coupling, e.g. "config X must travel with version Y"); `$HOME/.claude/memory/retro-log.md` entries near the PR's
  create date; linked Jira ticket(s) (per `wk-jira` detection), whose user-visible scope is the contract the stack must
  collectively satisfy.
- Learning warns about coupling between two parts of the diff → **those parts cannot live in different child PRs**.
  Record and respect the constraint.

## Stage 3: Identify the seams

Walk the diff for natural cut lines and categorize each candidate per
[references/seam-catalog.md](references/seam-catalog.md); reject any seam that requires both sides to merge for either
to make sense. **Seam-quality probe** — for each candidate seam, ask:

- Can this side build, lint, pass tests with the **other side reverted**? (Invariant 2.)
- Can a reviewer read this side as a coherent change without having seen the other side? (Invariant 3.)
- Does this side leave a dead-end (unused symbol, half-wired feature, dangling test) a future child cleans up? Yes → the
  description must explicitly call it out.
- Does this side add a gate / validation / enforcement that goes CI-red when the data it checks is absent? Yes → the PR
  **providing that data must be an ancestor**, never a descendant. Order by data-dependency, not conceptual layer
  (schema → enforcement → data inverts it); a mis-ordered gate is CI-red in isolation and needs post-hoc
  `git rebase --onto` surgery to reorder.

Seam needs a temporary scaffold to satisfy invariant 2 (e.g., a stub returning a default until a later child fills it
in) → document the scaffold in the child's description and tag the future child that removes it.

**HARD RULE — ordinals track the base graph, order is read only from `baseRefName`.** Reordering a stack after its PRs
exist (`git rebase --onto` to re-parent a child) invalidates the `part-N/M` ordinals — they now imply a merge order the
base graph contradicts and become an actively-misleading source of truth. In the same step either renumber the labels to
the new topological order, or drop ordinal labels and state each PR's parent explicitly (`base: <branch>`). Derive any
merge/dependency order strictly from `baseRefName` edges (`gh pr view <n> --json headRefName,baseRefName`) — never from
`part-N` labels or memory; after any re-parent, confirm the ordinal sequence still matches the base graph and fix
mismatches before stating the order anywhere.

## Stage 4: Propose the stack

Cap at **≤5 children**: more than 5 → over-fragmenting; merge the smallest pieces back together (fewer is fine, even 2).
Write one block per child plus a stack overview table using the template and annotation routing table in
[references/child-block-template.md](references/child-block-template.md). Populate `wk-pr`'s description template for
each child.

## Stage 5: Validate the plan against the five invariants

Walk every invariant against every child: (1) functional equivalence — child diffs concatenated = parent diff, (2)
isolation — each child builds/tests on its parent alone, (3) stack-order coherence — each reads as self-contained, (4)
description completeness — Stack/Blockers/Follow-up populated, (5) reviewer digestibility — coherent claims, no
mega/nano splits. Any check fails → return to Stage 3 and re-cut. Never ship a violating plan.

## Stage 6: Present for approval

Show: (1) original PR header (title, URL, base, current size), (2) stack overview table, (3) each child block in stack
order, (4) constraints from Stage 1/2 that drove the cuts (reviewer asks quoted, learnings cited), (5) the single
command path forward:

> "Approve to execute? `(a) yes, build the stack` /
> `(b) edit the plan` / `(c) save plan to file and stop`."

Auto mode default: `(c) save plan to file and stop` — building a PR stack is a destructive multi-PR operation exceeding
the unattended autonomy budget. Write the plan to `docs/plans/pr-break-{pr-num}.md` (or the project's established plan
location) and return.

## Stage 7: Execute (only on explicit approval)

Follow [references/execution-loop.md](references/execution-loop.md) for branch naming (`-part-N` suffix), collision
validation, and the per-child loop (cut → apply → test → commit → PR → CI). Child CI failure suggesting a bad seam →
pause and ask before patching.

Hand-offs to `wk-workflow`, `wk-pr`, `wk-commit`, `wk-pr-resolve`, `wk-pr-update`:
[references/coordination.md](references/coordination.md).

## Post-Completion

Invoke `wk-learn pr-break`.
