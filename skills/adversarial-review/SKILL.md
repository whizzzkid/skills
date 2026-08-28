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
  version: "2026.08.28-053208"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Adversarial Review

Resolve base → surface map → mechanical sweeps → fresh adversarial subagent → playground validation → verdict → fix loop → re-review.

## Non-Negotiable Contract

1. **Clear lineage.** Publishing is ungated; merging requires clear review
   lineage. Apply
   [`references/clearance-lineage.md`](references/clearance-lineage.md).
2. **No docs-only exemption.** Docs, specs, skills, executable instructions can
   carry logic errors, stale counts, or bad commands.
3. **One dispatch per change — completion gate owns it.** Every other caller
   reads `.review-playground/.{cleared,blocked}-{HEAD_SHA}.json`; missing means
   "not yet at the gate", never permission to run.
4. **One re-review only when lineage breaks; waiver is final.** Apply the
   clearance-lineage rules above. A waiver or fatigue signal stops dispatch for
   this session in every later step; never re-litigate it.
5. **Mechanical first.** Run all sweeps before LLM reasoning.
6. **Block before negotiate.** Blockers stop the caller. Downgrade severity only with explicit user confirmation.
7. **Reproduce before claim.** Runtime-behavior findings reproduced in `.review-playground/` or downgraded to `question`.
8. **Diff-anchored findings.** Commentable findings map to diff lines; outside-diff issues → file-level or verdict-body notes.
9. **Gate, not actor.** Do not push, edit the PR, or post review comments from this skill.
10. **Arch layer hands over, once.** Arch-bearing artifact or topology change in the diff (`wk-arch-review`'s trigger) → read its record, else dispatch it once and fold the findings; never re-derive topology critique here.
11. **Artifact over authority.** A container executing branch-controlled code
    receives a host-fetched least-privilege artifact, never an agent or
    credential used only to fetch it.

## Step 1: Resolve Context and Build Surface Map

Resolve authoritative base dynamically. Hardcoding `main` is forbidden.

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

Per changed file, capture:

- New/modified functions, methods, classes, signatures, CLI flags, env vars, public API entries.
- New/modified test functions and fixtures.
- Removed lines; mark refactors **net-new** vs **relocated**.
- Touched docs, specs, READMEs, in-code help strings, plugin manifests.
- Diff kind: `feature`, `bugfix`, `refactor`, `docs`, `infra`.

## Step 2: Mechanical Sweep Catalog

Run every sweep unconditionally. Use first matching severity; escalate when a suggestion proves a HARD RULE violation.

| ID | Trigger | Check | Severity | Fix / escalation |
|---|---|---|---|---|
| 2.0 | Every run, before the subagent | Probe for a configured second-opinion / automated-review tool (`command -v <tool>` on `PATH`, or its env flag); re-derive presence each run, never from a standing user-config rule. Present-but-not-invoked is a finding — ambient prose / memory rules lose to context pressure, only an executed sweep row guarantees the run. | Blocker | Invoke it this turn, read its output, fold its blockers/majors; gate the verdict on a clean run. A specialized-tool finding in its own domain (error-handling, type-precision, test-coverage) stands even when the general subagent cleared the same code — complementary, not redundant; never dismiss it as a false positive on that basis. |
| 2.1 | Any security/redaction/credential touch | Grep full diff for secret leakage to stderr, `curl -H "Authorization: Bearer $VAR"`, credential flag values in source/docs/shell, or a secret on a live subcommand argv (`--password=$X`, `--token=$X`) — world-readable via `ps`/`/proc` even when the value stays in-process. | Blocker | Move to `curl -u`, netrc, or a `chmod 600` credentials file; pass runtime secrets by env var, never on argv. |
| 2.2 | Changed script/module/parallel pipeline | List directory siblings and whole-repo raw tool invocations. Task registry/wrapper authoritative → grep workflows, setup/help text, and source comments; only its definition may retain the raw command. Copied directive (`soft_fail`, `retry`, `timeout`, exit-code handling`) → verify behavioral/exit-code contract transfers (pattern copy ≠ contract transfer). | Blocker | Route raw calls through registry/wrapper; apply to every sibling or justify absence. Quote source sibling contract for copied directives, or flag pending verification. |
| 2.3 | New guard/null-check/defensive branch, OR a flagged *missing* guard | Trace upstream transforms for reachability and sentinel completeness. A map field left `nil` by `json.Unmarshal` (absent JSON key, not `{}`) is a live absent-key path — confirm the schema always has the key before calling it dead. Before flagging a *missing*-guard/empty-value as a blocker, trace the producer: if it errors on the caller's short-circuit path or guarantees non-empty on success (test-pinned), the guard is unnecessary. A partition predicate reading a nilable field via bracket/`[]` access defers the nil error past the decision point. A `${var:-default}` whose upstream guard (`set -e`, `jq -e` type check, `|| exit`) already aborts is dead — the default documents an unreachable path. But an explicit `|| { exit; }` guard after that type-check *is* the failure-surfacing remedy → defense-in-depth, not a dead guard: classify it suggestion/question, confirm intent, never blocker. | Blocker | Fix dead guards; handle jq falsy output (`"null"`); document why a structurally-guaranteed guard is absent; in a partition predicate use strict access (`.fetch`/equivalent) so nil fails fast at the boundary, not in a downstream formatter; drop the dead `:-default` or replace with explicit failure-surfacing. |
| 2.4 | Added/modified comments or docs claims | Check assertive claims (`always`, `never`, `must`, `works`) and intent phrases against implementation; flag new/changed doc comments whose one sentence chains independent reasons (`because`/`while`/`so that`). A capability verb (runs, executes, validates, enforces, blocks, prevents) carries no citable figure, so a numbers-only grounding pass skips it — require each to name its implementing symbol. A diff that deletes one member of a documented set of alternatives (install paths, test modes, deploy targets, config options) makes every survivor newly load-bearing — execute each verbatim. The deletion changes a survivor's criticality without changing its text, so no other sweep looks at it. | Suggestion | Update/delete stale comments; add pinning tests for universal claims; split independent clauses. Fix a failing survivor in this diff — the relocation downgrade does not apply when the diff removed the alternative that was masking the defect. |
| 2.5 | Base/branch refs or build-time branch discovery | Grep for hardcoded `main...HEAD`, `origin/main`, `master...HEAD`; require build labels to prefer CI-provider branch metadata before invoking git and reject empty or detached `HEAD`. | Blocker | Use dynamic base resolution. For build labels, use provider metadata with a git fallback; test with git unavailable and a detached checkout. |
| 2.6 | Version pins | Grep Dockerfiles, tool/package manifests, and GitHub Actions for `latest`, `stable`, `nightly`, unpinned tags, `^`, or `~`. | Blocker | Pin exact versions or official-action majors. |
| 2.7 | Signature/contract widening | Grep every caller/initializer for required params/fields; grep open merge/spread/update against structural containers; sweep the whole repo for stubs, injected globals, and harness implementations; on a single-field-struct→plain-param collapse, check whether the field's zero-value (`""`/`0`/`false`/`nil`) reaches ≥2 callers for different semantic reasons. | Blocker | Update all call sites or add defaults; add allowlist/reserved-key/collision guards; an overloaded zero-value needs a named const or per-call-site comment. Drive one real consumer per distinct harness; type-checking alone does not clear the contract. |
| 2.8 | New/removed flags, symbols, errors, tests, docs terms | Sync docs, READMEs, specs, tests, PR body, in-code help, tables, test counts. On a parameter/symbol rename, also grep the owning class/module docstring for the old name AND any behavioral phrase it qualified — prose claims don't match a symbol grep. A clean 2.8 grep is not proof of a clean PR body — that is 2.10's job; never report full sync until 2.10 also runs on the same diff. | Blocker | Update all enumerations; include synonym/casing variants for removed terms; sync stale docstring phrasing in the same commit as the rename. |
| 2.9 | Design-pivot docs/specs | Verify plans, ADRs, specs, inline comments match the new logical shape. | Blocker | Update dependent artifacts in the same branch. |
| 2.10 | Existing PR | Fetch title/body; check behavior wording, test counts, file lists, remaining work, metadata, Jira suffix, rename/enum drift, rollout/ops section for prod-facing diffs. Enum-like body lists (symbols, tags, flags, codes): grep post-diff code for all values; any missing from the body is drift. On any rename diff, also grep the body PROSE (not just enum lists) for every OLD literal name and any stale count the diff changed — enum-value checks miss narrative mentions. | Blocker | Record body drift as post-push TODO; fix before marking ready. |
| 2.14 | Pre-push hook config | Inspect `.lefthook.yml`, `.husky/pre-push`, `.git/hooks/pre-push`, `bin/ci`; enumerate every gate and multi-phase anchor. | Blocker | Run every gate locally; fix missing hook-phase wiring. |
| 2.15 | Source diff | Invoke `wk-workstyle check <path>` report-only on every source file (includes `wk-workstyle-docstrings` for any file with doc comments or public API symbols); on test dedup into `shared_examples`/parameterized factories, audit dropped caller-specific coverage. | Suggestion | Surface magic values, nested ternaries, missing public docs, sad-path gaps, branch/test mismatches, async timing, stale comments, empty catches, duplicated test helpers, bugfix-without-regression-test; also flag: stale `@param`/`@return` entries, WHAT-only comments, missing callable signature docs on public API additions, and comments exceeding the project column limit; restore per-caller log-label assertions, entry-point integration coverage, and caller env-var-fallback tests the shared block hides. |
| 2.19a | Added Struct/Record/interface/Go field | Grep tests for direct concrete-value assertion on the new field. When the field is serialized via `.to_s`/equivalent, also include a nil/false/0 case — the zero-value path through a serialization boundary is the common production path and a `NoMethodError` there escapes happy-path specs. | Blocker | Add direct assertion; `respond_to?`/presence alone is insufficient; add the nil/zero-value serialization case. |
| 2.24 | External command with expanded names | Grep commands like tar/rm/cp/mv/grep/chmod/git/curl for missing `--` before untrusted expanded args. | Blocker | Insert `--` before positional args. |
| 2.40 | Diff touches token scope, secret access, or privilege escalation | Verify the PR body carries `## Problem` (why the elevated scope), `## Approach` (why narrower alternatives were ruled out), and `## Testing` (how the permission was exercised). | Blocker | Any section absent on a security-sensitive diff is a finding; placeholder-only bodies fail checks. |
| 2.44 | Merge/rebase conflict resolved at a function call site | Compare both sides' arg counts against the current base-branch signature; base is authoritative for required params (a side missing one is stale, not caller-wins). Also diff both sides for safety primitives (`signal.Stop`, `context.Cancel*`, `sync.*`, `defer`, `close(`, `os.RemoveAll`, resource releases) present on either side but absent from the result — base is canonical, so a missing guard is a dropped contract. | Blocker | Take the side matching the base signature; flag the short call. Restore any base-side safety primitive absent from the result unless the incoming commit removed it with rationale; green tests don't prove it unneeded. |
| 2.88 | Diff adds or edits code whose caller maps exit status to severity (verifier/rake task, linter, hook wrapper, CI gate, `--check`/`--verify` mode) | Read the caller and record its status→severity mapping — which codes block, which downgrade to a warning, which are ignored. Then grep the gate's own body for raising lookups (`\.fetch\(`, `T\.must\(`, `unwrap\(`, `panic`, `\[\]!`, `!\.`) on an absent/renamed key: the raise exits on a *non-blocking* status, so the very drift the gate exists to catch ships fail-open. Reading the gate body in isolation clears it — only the status contract exposes it. | Blocker | Route every failure through the blocking status, or extend the wrapper's mapping to block it. A raise→report conversion adds a branch no existing control drives → add one and mutation-verify it (restore the raising form, confirm exactly that control fails, restore). Then sweep every sibling of the same shape before clearing — one instance implies others, and a fix made earlier in the branch does not cover a later sibling. |
| 2.91 | Diff adds/narrows nil/empty sentinel branch | Locate every consumer and its render predicate; confirm sentinel unreachable when consumer is live — a non-emptiness gate lets nil through. | Blocker | Align render predicate with sentinel; pin invariant (non-nil when consumer active). |

Lower-frequency, non-inline sweeps live in
[`references/sweep-catalog-extended.md`](references/sweep-catalog-extended.md);
apply each under the same unconditional rule when its trigger matches.

## Step 3: Fresh Adversarial Subagent

After sweeps, dispatch a fresh subagent with no prior session context. Pipe `git diff "$BASE...HEAD"` directly plus the PR title/body purpose section; never hand-transcribe; verify hunk boundaries if excerpting.

Subagent must be adversarial, objective, naming-aware, and diff-sensitive, plus the stances below:

- **Coverage-aware:** test-only commits → enumerate paths, flag unexercised ones. But a private helper exercised transitively through its public caller *is* covered — don't flag a coverage gap on it, nor on a sibling branch already exercised by an equivalent case (coupling tests to private helpers couples them to implementation detail).
- **Narrate the "why" on a narrow merge-resolution/bugfix diff:** name the kept conflict side and the bugfix's exact defect mechanism, and tell the subagent to verify those claims against the diff, not assert them. A large/organic diff still needs the generic sweep.
- **Refactor-aware:** demand removed-line audit; every removed line is relocated or intentionally dropped.
- **Relocation-aware:** downgrade inherited pre-existing issues carried unchanged by a pure move — but not when the diff *deleted* the alternative that was masking the issue (2.4).
- **Introduction-claim-aware:** before calling a behavior newly introduced, grep the `-` lines of the same hunk.
- **Runtime-behavior-cautious:** never `blocker` a tool-behavior-under-failure claim (exit codes, signals, buffering, pipe semantics) from first principles — at most `question` pending the Step 5 repro (contract #8).
- **Absence-claim-cautious:** a finding that a "safe no-op" or missing error-path write is a defect must cite a concrete failure scenario. Absence of defensive code is not itself a defect — writing a default (e.g. `{}`) on read failure can clobber legitimate local-only state. Cap at `question` without a repro.
- **Intent-aware:** weigh the PR title/body purpose (piped in above). A change the PR explicitly documents as intentional, test-only, or throwaway (e.g. a CI gate removed to force a step to run) is stated context — do not flag documented-intentional design as a `blocker`. The guard still holds on production branches, where the pattern is unflagged.
- **Design-invariant-aware:** when a diff adds a helper/function beside existing code carrying a design-rationale comment (e.g. a global cleaned by an EXIT trap on signal), verify the new code honors that stated invariant; a divergence is a structural bug.
- **Artifact-provenance-aware:** state derived from a produced artifact (summary, report, comment, log) must be gated on the artifact's production fidelity — a degraded, partial, or fallback production path voids any state inference drawn from the artifact's content or existence. "Artifact exists" ≠ "artifact is complete."

### Categories to Hunt

`category:` (Step 4) values: [`references/hunt-categories.md`](references/hunt-categories.md).

## Step 4: Findings Format and Severity

Each finding uses:

```
severity:   blocker | suggestion | question
file:       path
line:       N (must exist in the diff's commentable set)
category:   one of the hunt categories
finding:    one sentence
rationale:  1-3 sentences, citing exact diff lines
fix-sketch: concrete code or command, not narrative
```

- `blocker`: correctness, security, data loss, HARD RULE violations.
- `suggestion`: naming/style/readability unless tied to a hard rule.
- `question`: genuine uncertainty.
- Omit hedging, filler, praise, diff restatement.

## Step 5: Playground Validation

Create `.review-playground/` only if needed (never commit a `.gitignore` entry for it); confine writes there.

- One script per runtime-behavior finding; drive each with the production runtime.
- **Important — scope every local run to the changed examples; never a suite or a whole spec directory.** CI owns suite pass/fail (a green local run adds nothing; a red one is usually environmental, not a PR defect). Name the changed method's spec file and filter to it (`<runner> <spec-file> -e '<changed method>'`). Spend local effort driving the change's failure paths (timeouts, exhausted retries, malformed/partial responses, degraded deps, non-zero exits).
- Mutation-test each new test: flip a conditional, hardcode a return, swap args, remove an assertion → green = fake test. **Each cycle inherits that scoping** — N mutations × a full directory is the dominant cost, and a killing test is by construction among the changed examples.
- App cannot boot → use standalone playground. Fetch pinned upstream source, replicate method signatures, cite SHA/tag:

  ```bash
  gh api "repos/{owner}/{repo}/contents/{path}?ref={tag-or-sha}" --jq '.content' | base64 -d
  ```


### Runtime matrix

Run every interpreter the diff exercises, not whatever is first on `PATH`. Per-language version sources:
[`references/playground-specialized-checks.md`](references/playground-specialized-checks.md).

### Specialized & doc-diff checks

When the diff shape matches a specialized case (producer→consumer layout, cluster
promotion/dedup, interface contract change, allowlist/privilege target contract, cross-step
file persistence), or every changed file is docs/prose/fixture data, apply the matching block from
[`references/playground-specialized-checks.md`](references/playground-specialized-checks.md).

## Step 6: Verdict and Records

Deduplicate by `(file, line, category)`, then return one verdict.

- **Clear:** zero blockers and zero unverified high-confidence runtime claims.
  Print commit range, HEAD SHA, and counts. Write
  `.review-playground/.cleared-{HEAD_SHA}.json` with SHA, base, timestamp,
  verdict, counts, and finding fingerprints.
- **Blocked:** print every blocker and write
  `.review-playground/.blocked-{HEAD_SHA}.json` with the same metadata plus each
  finding's fingerprint, reproducer, and fix sketch. Caller fixes and re-invokes.
- **Suggestions only:** print suggestions; offer A/B/C: fix all in-line, clear
  with TODO, or defer to tracked work. Auto mode defaults to A when every
  fix-sketch is <10 lines, else B.

### Bot Reviewer Handling

Bot reviewers exist (`*[bot]`) → append:

- Bots retract and repost replacement threads post-push; re-fetch after push and match by `(path, line, body_excerpt)`, not REST comment ID.
- Emit `session_resolved_classes` keyed by `(path_prefix, concern_class)` so callers skip bot echoes.
- Bot flip-flop (re-flagging a line it earlier made you change) = self-contradiction → dismiss citing the invariant, never oscillate.

## Step 7: Fix Loop and Hand Back

On blocked verdict:

- **Scope off-ramp first.** When a blocker's remedy is a nontrivial new mechanism/feature or design change (not a contained fix), offer *narrow/revert the triggering change + defer the deeper fix to a follow-up PR* alongside fix-inline — prefer it when the blocker sits in complexity this PR introduced (removing that code often beats adding more to make it correct).

1. Caller fixes each blocker via `wk-commit` (one atomic commit per fix).
2. Fix every structurally-parallel sibling in the same round. For a
   value/message/constant-reporting defect, grep the entire changed file for
   every site of the same shape; fix each unless divergence is justified.
3. Re-invoke:
   - Delta maps only to recorded findings → validate those findings; skip full
     sweeps and subagent. All fixed → write current-HEAD clear record.
   - Unmatched new work → run one delta-scoped review per Contract 4.
4. Loop targeted validation until clear, max 3 cycles.
5. After 3 cycles, stop; recurrence means diagnosis or design is wrong.

PR-body-only blocker (sweep 2.8/2.10 body drift, no code change) → fix via `gh pr edit`, no new commit; re-verify against the same HEAD SHA. The `.cleared-{HEAD_SHA}.json` stays valid (code unchanged); a no-op commit pollutes history.

Do not autosquash post-rebase artifact fixes mid-chain — commit standalone,
then apply the lineage rule. Print the verdict line to the caller
(Contract item 10: gate, not actor).

## Requirements

- `gh` CLI authenticated.
- Repo with base branch resolvable via `gh pr view` or `git symbolic-ref refs/remotes/origin/HEAD`.
- Write access to `.review-playground/` (gitignored).
- Runtime matrix installed via `mise` or equivalent when matrix checks run.

## Post-Completion

Invoke `wk-learn adversarial-review`.
