---
name: wk-adversarial-review
description: >-
  Adversarial pre-flight review of the current branch before anything leaves the
  machine. Activates whenever the agent is about to push, mark a PR ready, or
  introduce new commits onto an existing PR. Spawns a fresh critique agent that
  treats the diff as a stranger's code, runs mechanical pre-push checks
  distilled from past reviewer/bot findings, validates assumptions in a
  playground, and refuses to clear the branch until every blocker is resolved.
  Auto-invoked from wk-workflow Phase 4, wk-pr before draft creation or push,
  and wk-pr-resolve before Step 8 push. No code, no commit, no PR transition
  leaves the machine without passing this skill.
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
  version: '2026.06.25-231013'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Adversarial Review

Resolve base → surface map → mechanical sweeps → fresh adversarial subagent → playground validation → verdict → fix loop → re-review.

## Non-Negotiable Contract

1. **No push without clear verdict.** Run before every push, `gh pr ready`, force-push, and rebase that rewrites pushed history. No opt-out.
2. **No docs-only exemption.** Docs, specs, skills, executable instructions can carry logic errors, stale counts, bad commands.
3. **Per-feature gate.** Run once on complete implementation before publishing → fix residuals in ≤1 follow-up → re-review.
4. **Idempotent within a session.** No new commits since last clear verdict → print prior clearance record.
5. **Scope re-reviews.** After clear verdict, sweep only `git diff <cleared-sha>..HEAD`; record clearance at `.review-playground/.cleared-{HEAD_SHA}.json`.
6. **Mechanical first.** Run all sweeps before LLM reasoning.
7. **Block before negotiate.** Blockers stop the caller. Downgrade severity only with explicit user confirmation.
8. **Reproduce before claim.** Runtime-behavior findings reproduced in `.review-playground/` or downgraded to `question`.
9. **Diff-anchored findings.** Commentable findings map to diff lines; outside-diff issues → file-level or verdict-body notes.
10. **Gate, not actor.** Do not push, edit the PR, or post review comments from this skill.

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
| 2.1 | Any security/redaction/credential touch | Grep full diff for secret leakage to stderr, `curl -H "Authorization: Bearer $VAR"`, or credential flag values in source/docs/shell. | Blocker | Move to `curl -u`, netrc, or a `chmod 600` credentials file. |
| 2.2 | Changed script/module/parallel pipeline | List directory siblings and whole-repo sibling toolchain invocations. A directive (`soft_fail`, `retry`, `timeout`, exit-code handling) copied from a sibling → verify the sibling's behavioral/exit-code contract actually transfers (pattern copy ≠ contract transfer). | Blocker | Apply to every sibling or justify absence; quote the sibling's contract for any copied directive, or flag it pending verification. |
| 2.3 | New guard/null-check/defensive branch, OR a flagged *missing* guard | Trace upstream transforms for reachability and sentinel completeness. A map field left `nil` by `json.Unmarshal` (absent JSON key, not `{}`) is a live absent-key path — confirm the schema always has the key before calling it dead. Before flagging a *missing*-guard/empty-value as a blocker, trace the producer: if it errors on the caller's short-circuit path or guarantees non-empty on success (test-pinned), the guard is unnecessary. | Blocker | Fix dead guards; handle jq falsy output (`"null"`); document why a structurally-guaranteed guard is absent. |
| 2.4 | Added/modified comments or docs claims | Check assertive claims (`always`, `never`, `must`, `works`) and intent phrases against implementation; flag new/changed doc comments whose one sentence chains independent reasons (`because`/`while`/`so that`). | Suggestion | Update/delete stale comments; add pinning tests for universal claims; split independent clauses. |
| 2.5 | Base/branch refs | Grep for hardcoded `main...HEAD`, `origin/main`, `master...HEAD`. | Blocker | Use dynamic base resolver. |
| 2.6 | Version pins | Grep Dockerfiles, tool/package manifests, and GitHub Actions for `latest`, `stable`, `nightly`, unpinned tags, `^`, or `~`. | Blocker | Pin exact versions or official-action majors. |
| 2.7 | Signature/contract widening | Grep every caller/initializer for required params/fields; grep open merge/spread/update against structural containers; on a single-field-struct→plain-param collapse, check whether the field's zero-value (`""`/`0`/`false`/`nil`) reaches ≥2 callers for different semantic reasons. | Blocker | Update all call sites or add defaults; add allowlist/reserved-key/collision guards; an overloaded zero-value needs a named const or per-call-site comment. |
| 2.8 | New/removed flags, symbols, errors, tests, docs terms | Sync docs, READMEs, specs, tests, PR body, in-code help, tables, test counts. On a parameter/symbol rename, also grep the owning class/module docstring for the old name AND any behavioral phrase it qualified — prose claims don't match a symbol grep. | Blocker | Update all enumerations; include synonym/casing variants for removed terms; sync stale docstring phrasing in the same commit as the rename. |
| 2.9 | Design-pivot docs/specs | Verify plans, ADRs, specs, inline comments match the new logical shape. | Blocker | Update dependent artifacts in the same branch. |
| 2.9.1 | Spec/interface with multi-mode type | Review structs/unions/records with ≥4 fields consumed by different modes. | Suggestion | Make compatibility explicit via consumer requirements or producer support matrix. |
| 2.10 | Existing PR | Fetch title/body; check behavior wording, test counts, file lists, remaining work, metadata, Jira suffix, rename/enum drift, rollout/ops section for prod-facing diffs. Enum-like body lists (symbols, tags, flags, codes): grep post-diff code for all values; any missing from the body is drift. | Blocker | Record body drift as post-push TODO; fix before marking ready. |
| 2.11 | External API/CLI request shape | Require local reproduction of new payload/header/invocation or explicit user opt-out; verify error schema keys. | Blocker | Reproduce success/error responses; never assume API keys. |
| 2.12 | Prior self-review exists | Fetch threads; compare new rationale against stale approach comments. | Suggestion | Drop duplicates, cross-reference, or resolve superseded threads. |
| 2.13 | Direct comment API | Grep for `gh api .../pulls/<id>/comments`. | Blocker | Remove raw comment posting; verdict output only. |
| 2.14 | Pre-push hook config | Inspect `.lefthook.yml`, `.husky/pre-push`, `.git/hooks/pre-push`, `bin/ci`; enumerate every gate and multi-phase anchor. | Blocker | Run every gate locally; fix missing hook-phase wiring. |
| 2.15 | Source diff | Invoke `wk-workstyle check <path>` report-only on every source file (includes `wk-workstyle-docstrings` for any file with doc comments or public API symbols); on test dedup into `shared_examples`/parameterized factories, audit dropped caller-specific coverage. | Suggestion | Surface magic values, nested ternaries, missing public docs, sad-path gaps, branch/test mismatches, async timing, stale comments, empty catches, duplicated test helpers, bugfix-without-regression-test; also flag: stale `@param`/`@return` entries, WHAT-only comments, missing callable signature docs on public API additions, and comments exceeding the project column limit; restore per-caller log-label assertions, entry-point integration coverage, and caller env-var-fallback tests the shared block hides. |
| 2.16 | Plugin/skill diff | Scan `SKILL.md`/plugin manifest for authoring-repo-relative paths. | Blocker | Use `${CLAUDE_PLUGIN_ROOT}/`, inline fallback, or pinned upstream fetch. |
| 2.17 | Dynamic-language diff; inline refactor of a helper | For each call kept/added, grep module/imported namespace for the definition. Inverse: for each helper defined/kept, grep non-test files for a caller — zero after an inline refactor is dead code whose tests assert a dead path. | Blocker | Restore/remove call or add definition; delete dead helpers and retarget their tests at the live caller. |
| 2.19 | New subprocess/LLM/network call site with a hardcoded `context.Background()`/`context.TODO()` | If the enclosing function has a live cancellation context available (a `context.Context` field on a received struct, or a wrapper embedding one), the literal breaks SIGINT/SIGTERM propagation to in-flight work. | Blocker | Forward the available app/request context; a nil-guard in the callee makes forwarding safe. |
| 2.19a | Added Struct/Record/interface/Go field | Grep tests for direct concrete-value assertion on the new field. When the field is serialized via `.to_s`/equivalent, also include a nil/false/0 case — the zero-value path through a serialization boundary is the common production path and a `NoMethodError` there escapes happy-path specs. | Blocker | Add direct assertion; `respond_to?`/presence alone is insufficient; add the nil/zero-value serialization case. |
| 2.20 | Application code + CI pipeline | Extract net-new env reads; locate invoking pipeline steps; verify allowlist forwarding. Diff touches a compose `environment:` or plugin `env:` → full-path audit: grep every script+library in the container's runtime call graph (not just diff delta) for env reads, diff against the forwarding list, run a sibling-template consistency check. **Wholesale `env:` list replacement (e.g. a ported template) → diff the full new list against the `origin/$BASE` version of the same file**, not just the diff delta. | Blocker | Forward vars in native/container steps; exempt auto-injected prefixes only for native non-container steps. Surface any runtime read without a forwarding entry (incl. called libs); same-role siblings forward the same set. A var present in base but absent from a replaced list is a candidate dropped-forwarding regression → re-add or justify. A spec deleting a var and asserting the script's own default = intentional omission → `question`. |
| 2.19 | New/modified tests | Grep for self-referential equality (`expect(x).to eq(x.sort())`) and no-op `&& true` after `||`. | Blocker | Build independent expected values; propagate `false` in fail paths. |
| 2.21 | New numeric security-gating config | Trace consumer path; verify positive lower bound and hard ceiling before control gates. | Blocker | Add bounds/ceiling constants. |
| 2.22 | New structured-artifact plumbing | Detect `<collection>["key"]`/`.get(key)` feeding downstream calls. | Suggestion | Add integration test for the wire. |
| 2.23 | Seed/prepend before emptiness collapse | Trace whether decorative seed drives guard false. | Blocker | Add seed/decoration after substantive-content gate. |
| 2.24 | External command with expanded names | Grep commands like tar/rm/cp/mv/grep/chmod/git/curl for missing `--` before untrusted expanded args. | Blocker | Insert `--` before positional args. |
| 2.25 | New bash `trap` | Grep whole file for overlapping signal handlers. | Blocker | Combine traps or use append helper. |
| 2.26 | New command capture | For each `FOO=$(...)`, verify canonical promotion before downstream reads. | Blocker | Add `CANONICAL=$FOO` or limit capture to same-block guard. |
| 2.27 | Parallel guard/inference blocks | Build symmetry matrix for capture/guard/canonical assignment. | Blocker | Apply guard to all siblings or document intentional asymmetry. |
| 2.28 | CI trigger payload `commit` field | Verify it is not sourced from foreign-repo SHA envs (`REVIEW_`, `TARGET_`, `SOURCE_`). | Blocker | Use pipeline repo SHA. |
| 2.29 | `curl -s` response parsing | Grep for silent mode without `-S`. | Suggestion | Require `-sS` plus exit-status check. |
| 2.33 | Raw-presence parse fallback | Grep parse-with-fallback shapes. | Blocker | Parse first; fallback on parsed result; add invalid-primary test. |
| 2.34 | Spec/doc routing claim (which method a gate calls, which path bypasses a hook) | Grep the PR review thread for reviewer statements on the same routing. | Blocker | A reviewer who read the source is ground truth; resolve contradictions before asserting an inferred claim. |
| 2.35 | Diff changes a structured return-type requirement in one doc section | Grep the whole document for every field comment that stores that value; confirm shape and vocabulary match. | Blocker | Update lagging field comments; keep one canonical name per value across all sections. |
| 2.37 | Gate reorder moves a cheap guard before a deeper call | Reordering short-circuits a failure path earlier → calls it used to make become unreachable. Enumerate every now-unreachable call; check each `not_to receive` test covers all, not just the deepest. | Suggestion | Add the missing negative assertions; escalate to Blocker when a now-unreachable call was previously unstubbed and would hit the network/a real dependency. |
| 2.38 | New/renamed default-or-fallback constant | Grep all files for string literals describing the OLD default behavior — display-label and logging helpers often hard-code it, missed by a call-site-only sweep. | Blocker | Update each stale literal or justify; a logging path emitting the old name looks correct to operators. |
| 2.40 | Diff touches token scope, secret access, or privilege escalation | Verify the PR body carries `## Problem` (why the elevated scope), `## Approach` (why narrower alternatives were ruled out), and `## Testing` (how the permission was exercised). | Blocker | Any section absent on a security-sensitive diff is a finding; placeholder-only bodies fail checks. |
| 2.43 | New field beside an existing same-primitive-type field | Grep for a resolver/normalizer/sanitizer on the sibling (`resolve*`/`normalize*`/`sanitize*`); confirm the new field gets equivalent treatment. | Blocker | Apply the same normalizer. Blocker when the field feeds a security-sensitive consumer (paths, URLs, shell args, allow-dir lists) — a raw path/URL field is a traversal/SSRF vector. |
| 2.44 | Merge/rebase conflict resolved at a function call site | Compare both sides' arg counts against the current base-branch signature; base is authoritative for required params (a side missing one is stale, not caller-wins). Also diff both sides for safety primitives (`signal.Stop`, `context.Cancel*`, `sync.*`, `defer`, `close(`, `os.RemoveAll`, resource releases) present on either side but absent from the result — base is canonical, so a missing guard is a dropped contract. | Blocker | Take the side matching the base signature; flag the short call. Restore any base-side safety primitive absent from the result unless the incoming commit removed it with rationale; green tests don't prove it unneeded. |
| 2.47 | Bash fake/stub that branches on arg/URL content or writes output a real tool emits only under a flag | (a) A matched branch with no terminal `exit`/`return` before its `fi` falls through to the sibling's response — a test omitting that branch's params passes via the wrong path. (b) A stub writing output unconditionally, ignoring whether the gating flag (`--fail-with-body`, etc.) is in `$@`, makes a production regression away from that flag undetectable. | Blocker | End each branch with explicit `exit` returning its own fallback (`echo '[]'; exit 0`); gate conditional output on flag presence (`for a in "$@"; do [[ $a == --flag ]] && has=true; done`). Model both flag-present and flag-absent paths so the stub is a contract gate, not a shape-mimicker. |
| 2.48 | Finding or identity/dedup key relies on an LLM round-trip preserving a field verbatim | Grep the prompt/skill builder for an explicit verbatim-echo instruction for that exact field — absence confirms the stability is an unenforced bet, not a guarantee. If test mocks return the field verbatim, the rephrase path is uncovered. | Blocker | Pin the field in the prompt (fix at source) over a downstream key workaround; add a rephrasing-mock regression test. |
| 2.55 | Log/output parse pipeline or multi-branch diagnostic guard | (a) A regex narrowed to fix overreach (e.g. `[^ ]+\.json` from `.+\.json`) silently drops inputs with spaces/Unicode — enumerate the full input space before accepting; prefer `sed -n 's/.*anchor//p'` (tail-of-line, all chars) over a character-class exclusion when the value format is unconstrained. (b) A message branch keyed on a proxy variable (e.g. stderr emptiness) instead of the actual discriminant (parse result vs file existence) fires the wrong message on orthogonal failures. | Blocker | (a) Use a space-safe extraction; (b) give each distinct failure mode its own condition and message — never branch on a proxy when the discriminant is available directly. |

Lower-frequency and shape-specific sweeps (2.18, 2.30, 2.31, 2.32, 2.36, 2.39,
2.41, 2.42, 2.45, 2.46, 2.49, 2.50, 2.51, 2.52, 2.53, 2.54) live in
[`references/sweep-catalog-extended.md`](references/sweep-catalog-extended.md);
apply each under the same unconditional rule when its trigger matches.

## Step 3: Fresh Adversarial Subagent

After sweeps, dispatch a fresh subagent with no prior session context. Pipe `git diff "$BASE...HEAD"` directly plus the PR title/body purpose section; never hand-transcribe; verify hunk boundaries if excerpting.

Subagent must be adversarial, objective, naming-aware, and diff-sensitive, plus the stances below:

- **Coverage-aware:** test-only commits → enumerate code paths, flag unexercised paths.
- **Refactor-aware:** demand removed-line audit; every removed line is relocated or intentionally dropped.
- **Relocation-aware:** downgrade inherited pre-existing issues carried unchanged by a pure move.
- **Introduction-claim-aware:** before calling a behavior newly introduced, grep the `-` lines of the same hunk.
- **Runtime-behavior-cautious:** any claim about tool behavior under failure (exit codes, signal handling, `--write-out`/buffering, subshell/pipe semantics) is at most `question` with a repro request — never `blocker` from first principles; verify in the playground (Step 5).
- **Absence-claim-cautious:** a finding that a "safe no-op" or missing error-path write is a defect must cite a concrete failure scenario. Absence of defensive code is not itself a defect — writing a default (e.g. `{}`) on read failure can clobber legitimate local-only state. Cap at `question` without a repro.
- **Intent-aware:** weigh the PR title/body purpose (piped in above). A change the PR explicitly documents as intentional, test-only, or throwaway (e.g. a CI gate removed to force a step to run) is stated context — do not flag documented-intentional design as a `blocker`. The guard still holds on production branches, where the pattern is unflagged.

### Categories to Hunt

`category:` (Step 4) is one of, sweep catalog holds the detail: **Logic / arithmetic** (off-by-one, pagination edges); **Type coercion** (`"0"` vs `0` vs `false`, `[]` vs `{}`); **State / ordering / concurrency** (use-before-init, use-after-close, async interleave, races, lock asymmetry); **Contract / cross-system** (signature widening, producer≠consumer layout, cleanup-before-verify); **Refactor-removed** (validation, recursion, error handling silently dropped); **Test quality** (tautology, missing assertions/failure path, asymmetric coverage); **Security / data loss** (injection, secret leakage, traversal, unprotected writes, missing rollback); **Error handling** (swallowed errors, generic catches, wrong error class); **Runtime / performance** (runtime-matrix gaps, quadratic scans, repeated I/O).

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
- Mutation-test each new test: flip a conditional, hardcode a return, swap args, remove an assertion → green = fake test.
- App cannot boot → use standalone playground. Fetch pinned upstream source, replicate method signatures, cite SHA/tag:

  ```bash
  gh api "repos/{owner}/{repo}/contents/{path}?ref={tag-or-sha}" --jq '.content' | base64 -d
  ```

- **Runtime-behavior claims stay `question` until reproduced** (Contract item 8; Step 3 runtime-behavior-cautious) — never `blocker` from deduction.

### Runtime matrix

Run every interpreter the diff exercises, not whatever is first on `PATH`; flag
missing runtimes for CI. Per-language version sources (bash 3.2 + modern,
`requires-python`, `engines.node`/`.nvmrc`, `.ruby-version`, Docker base images):
[`references/playground-specialized-checks.md`](references/playground-specialized-checks.md).

### Specialized & doc-diff checks

When the diff shape matches a specialized case (producer→consumer layout, cluster
promotion/dedup, interface contract change, allowlist/privilege add, cross-step
file persistence), or every changed file is docs/prose/fixture data, apply the matching block from
[`references/playground-specialized-checks.md`](references/playground-specialized-checks.md).

## Step 6: Verdict and Records

Deduplicate by `(file, line, category)`, then return one verdict.

- **Clear:** zero blockers and zero unverified high-confidence runtime claims. Print commit range, HEAD SHA, finding counts. Write `.review-playground/.cleared-{HEAD_SHA}.json` (SHA, base, timestamp, counts, verdict).
- **Blocked:** print every blocker with file:line, category, fix sketch. Refuse to clear; caller fixes and re-invokes.
- **Suggestions only:** print suggestions; offer A/B/C: fix all in-line, clear with TODO, or defer to tracked work. Auto mode defaults to A when every fix-sketch is <10 lines, else B.

### Bot Reviewer Handling

Bot reviewers exist (`*[bot]`) → append:

- Post-push thread count may shrink; bots retract and repost replacement threads. Caller must re-fetch after push and match by `(path, line, body_excerpt)`, not REST comment ID.
- Emit `session_resolved_classes` keyed by `(path_prefix, concern_class)` so callers mark bot echoes as already-addressed.

## Step 7: Fix Loop and Hand Back

On blocked verdict:

1. Caller fixes each blocker via `wk-commit` (one atomic conventional commit per fix).
2. Fix every structurally-parallel sibling in the same round. For a value/message/constant-reporting defect, grep the **entire changed file** (not just the flagged line) for every site of the same shape (e.g. `grep "timed out after %v" <file>`) — a refactor that extracts a helper clones the defect onto a different line; treat each match as the same fix unless divergence is justified.
3. Re-invoke this skill.
4. Loop until clear, max 3 cycles.
5. After 3 cycles, stop and surface to user; recurrence means diagnosis/design is off.

PR-body-only blocker (sweep 2.8/2.10 body drift, no code change) → fix via `gh pr edit`, no new commit; re-verify against the same HEAD SHA. The `.cleared-{HEAD_SHA}.json` stays valid (code unchanged); a no-op commit pollutes history.

Do not autosquash post-rebase artifact fixes mid-chain — commit standalone, then re-review. Print the verdict line to the caller (Contract item 10: gate, not actor).

## Requirements

- `gh` CLI authenticated.
- Repo with base branch resolvable via `gh pr view` or `git symbolic-ref refs/remotes/origin/HEAD`.
- Write access to `.review-playground/` (gitignored).
- Runtime matrix installed via `mise` or equivalent when matrix checks run.

## Post-Completion

Invoke `wk-learn adversarial-review`.
