---
name: wk-adversarial-review
description: >-
  Adversarial review of the current branch before it merges; blocks until
  every finding clears. Runs exactly once per change, at the completion
  gate — plan fully executed, PR published and marked ready — so CI runs
  alongside it. Never per push, per commit, or per resolve cycle: every
  other caller reads the recorded verdict instead of dispatching.
argument-hint: '[optional: explicit base branch]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr list:*)"
  - "Bash(gh api repos:*)"
  - "Bash(gh api graphql:*)"
  - "Bash(git diff:*)"
  - "Bash(git log:*)"
  - "Bash(git status:*)"
  - "Bash(git merge-base:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git symbolic-ref:*)"
  - "Bash(git fetch:*)"
  - "Bash(grep:*)"
  - "Bash(rg:*)"
  - "Bash(awk:*)"
  - "Bash(sed:*)"
  - "Bash(find:*)"
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Agent
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Adversarial Review

## Non-Negotiable Contract

1. **Clear lineage.** Publishing is ungated; merging requires clear review lineage. Apply
   [`references/clearance-lineage.md`](references/clearance-lineage.md).
2. **No docs-only exemption.** Docs, specs, skills, executable instructions can carry logic errors, stale counts, or bad
   commands.
3. **One dispatch per change — completion gate owns it.** Every other caller reads
   `.review-playground/.{cleared,blocked}-{HEAD_SHA}.json`; missing means "not yet at the gate", never permission to
   run.
4. **One re-review only when lineage breaks; waiver is final.** Apply the clearance-lineage rules above. A waiver or
   fatigue signal stops dispatch for this session in every later step; never re-litigate it.
5. **Mechanical first.** Run all sweeps before LLM reasoning.
6. **Block before negotiate.** Blockers stop the caller. Downgrade severity only with explicit user confirmation.
7. **Reproduce before claim.** Runtime-behavior findings reproduced in `.review-playground/` or downgraded to
   `question`.
8. **Diff-anchored findings.** Commentable findings map to diff lines; outside-diff issues → file-level or verdict-body
   notes.
9. **Gate, not actor.** Do not push, edit the PR, or post review comments from this skill.
10. **Arch layer hands over, once.** Arch-bearing artifact or topology change in the diff (`wk-arch-review`'s trigger) →
    read its record, else dispatch it once and fold the findings; never re-derive topology critique here.
11. **Artifact over authority.** A container executing branch-controlled code receives a host-fetched least-privilege
    artifact, never an agent or credential used only to fetch it.

## Step 1: Resolve Context and Build Surface Map

Resolve the authoritative base dynamically; hardcoding `main` is forbidden. Requires: `gh` authenticated; base
resolvable via `gh pr view` or `git symbolic-ref refs/remotes/origin/HEAD`; write access to `.review-playground/`
(gitignored); runtime matrix installed via `mise` or equivalent when matrix checks run.

```bash
DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null | sed 's@^origin/@@')
DEFAULT=${DEFAULT:-main}
PR_NUM=$(gh pr view --json number --jq .number 2>/dev/null || echo "")
if [ -n "$PR_NUM" ]; then
  BASE=$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)
else
  BASE="$DEFAULT"
fi
git fetch origin "$BASE" --quiet
MERGE_BASE=$(git merge-base HEAD "origin/$BASE")
```

Refuse to proceed on uncommitted changes. Build the surface map:

```bash
git diff "$BASE...HEAD" --stat
git diff "$BASE...HEAD" --name-status
git log "$BASE..HEAD" --oneline
```

Per changed file capture: new/modified functions, methods, classes, signatures, CLI flags, env vars, public API entries;
new/modified tests and fixtures; removed lines, with refactors marked **net-new** vs **relocated**; touched docs, specs,
READMEs, in-code help strings, plugin manifests; diff kind (`feature`, `bugfix`, `refactor`, `docs`, `infra`).

## Step 2: Mechanical Sweep Catalog

Run every sweep unconditionally. Use first matching severity; escalate when a suggestion proves a HARD RULE violation.
Core sweeps (IDs 2.0–2.91): [`references/sweep-catalog.md`](references/sweep-catalog.md). Lower-frequency sweeps:
[`references/sweep-catalog-extended.md`](references/sweep-catalog-extended.md), applied under the same unconditional
rule when the trigger matches.

## Step 3: Fresh Adversarial Subagent

After sweeps, dispatch a fresh subagent with no prior session context. Pipe `git diff "$BASE...HEAD"` directly plus the
PR title/body purpose section; never hand-transcribe; verify hunk boundaries if excerpting. Make it adversarial,
objective, naming-aware, and diff-sensitive, and brief it with every stance in
[`references/subagent-stances.md`](references/subagent-stances.md) (coverage, narrate-why, refactor, relocation,
introduction-claim, runtime-behavior, absence-claim, intent, design-invariant, artifact-provenance). `category:` values:
[`references/hunt-categories.md`](references/hunt-categories.md).

## Step 4: Findings Format and Severity
```
severity:   blocker | suggestion | question
file:       path
line:       N (must exist in the diff's commentable set)
category:   one of the hunt categories
finding:    one sentence
rationale:  1-3 sentences, citing exact diff lines
fix-sketch: concrete code or command, not narrative
```

`blocker`: correctness, security, data loss, HARD RULE violations. `suggestion`: naming/style/readability unless tied to
a hard rule. `question`: genuine uncertainty. Omit hedging, filler, praise, diff restatement.

## Step 5: Playground Validation

- Create `.review-playground/` only if needed (never commit a `.gitignore` entry for it); confine writes there. One
  script per runtime-behavior finding; drive each with the production runtime.
- **Important — scope every local run to the changed examples; never a suite or a whole spec directory.** CI owns suite
  pass/fail (a green local run adds nothing; a red one is usually environmental, not a PR defect). Name the changed
  method's spec file and filter to it (`<runner> <spec-file> -e '<changed method>'`). Spend local effort driving the
  change's failure paths (timeouts, exhausted retries, malformed/partial responses, degraded deps, non-zero exits).
- Mutation-test each new test: flip a conditional, hardcode a return, swap args, remove an assertion → green = fake
  test. **Each cycle inherits that scoping** — N mutations × a full directory is the dominant cost, and a killing test
  is by construction among the changed examples.
- App cannot boot → standalone playground: fetch pinned upstream source, replicate method signatures, cite SHA/tag:

  ```bash
  gh api "repos/{owner}/{repo}/contents/{path}?ref={tag-or-sha}" --jq '.content' | base64 -d
  ```

- Runtime matrix: run every interpreter the diff exercises, not whatever is first on `PATH`. Specialized shapes
  (producer→consumer layout, cluster promotion/dedup, interface contract change, allowlist/privilege target contract,
  cross-step file persistence) or an all-docs/prose/fixture diff: apply the matching block. Both (incl. per-language
  version sources): [`references/playground-specialized-checks.md`](references/playground-specialized-checks.md).

## Step 6: Verdict and Records

Deduplicate by `(file, line, category)`, then return one verdict.
- **Clear:** zero blockers and zero unverified high-confidence runtime claims. Print commit range, HEAD SHA, and counts.
  Write `.review-playground/.cleared-{HEAD_SHA}.json` with SHA, base, timestamp, verdict, counts, and finding
  fingerprints.
- **Blocked:** print every blocker and write `.review-playground/.blocked-{HEAD_SHA}.json` with the same metadata plus
  each finding's fingerprint, reproducer, and fix sketch. Caller fixes and re-invokes.
- **Suggestions only:** print suggestions; offer A/B/C: fix all in-line, clear with TODO, or defer to tracked work. Auto
  mode defaults to A when every fix-sketch is <10 lines, else B.

Bot reviewers (`*[bot]`) present → also: bots retract and repost replacement threads post-push, so re-fetch after push
and match by `(path, line, body_excerpt)`, not REST comment ID; emit `session_resolved_classes` keyed by
`(path_prefix, concern_class)` so callers skip bot echoes; bot flip-flop (re-flagging a line it earlier made you change)
= self-contradiction → dismiss citing the invariant, never oscillate.

## Step 7: Fix Loop and Hand Back

On blocked verdict, offer the scope off-ramp first: when a blocker's remedy is a nontrivial new mechanism/feature or
design change (not a contained fix), offer *narrow/revert the triggering change + defer the deeper fix to a follow-up
PR* alongside fix-inline — prefer it when the blocker sits in complexity this PR introduced (removing that code often
beats adding more to make it correct). Then:

1. Caller fixes each blocker via `wk-commit` (one atomic commit per fix).
2. Fix every structurally-parallel sibling in the same round. For a value/message/constant-reporting defect, grep the
   entire changed file for every site of the same shape; fix each unless divergence is justified.
3. Re-invoke: delta maps only to recorded findings → validate those findings, skip full sweeps and subagent; all fixed →
   write current-HEAD clear record. Unmatched new work → run one delta-scoped review per Contract 4.
4. Loop targeted validation until clear, max 3 cycles. After 3 cycles, stop; recurrence means diagnosis or design is
   wrong.

PR-body-only blocker (sweep 2.8/2.10 body drift, no code change) → fix via `gh pr edit`, no new commit; re-verify
against the same HEAD SHA. The `.cleared-{HEAD_SHA}.json` stays valid (code unchanged); a no-op commit pollutes history.
Do not autosquash post-rebase artifact fixes mid-chain — commit standalone, then apply the lineage rule. Print the
verdict line to the caller (Contract 9: gate, not actor).

## Post-Completion

Invoke `wk-learn adversarial-review`.
