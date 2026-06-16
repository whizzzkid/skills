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
  version: '2026.06.16-194053'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Adversarial Review

Pre-flight critique of the current branch → mechanical sweeps → fresh adversarial subagent → validate runtime claims → clear/blocked/suggestions-only verdict.

```
Resolve base -> Build surface map -> Mechanical sweeps
  -> Fresh adversarial subagent -> Playground validation
  -> Verdict -> Fix loop -> Re-review
```

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
| 2.1 | Any security/redaction/credential touch | Grep full diff for secret leakage to stderr, `curl -H "Authorization: Bearer $VAR"`, or credential flag values in source/docs/shell. | Blocker | Move credentials to `curl -u`, netrc, or a `chmod 600` header/credentials file. |
| 2.2 | Changed script/module/parallel pipeline | List directory siblings and whole-repo sibling toolchain invocations. | Blocker | Apply analogous fix to every sibling or explicitly justify absence. |
| 2.3 | New guard/null-check/defensive branch | Trace upstream transforms for reachability and sentinel completeness. | Blocker | Fix dead guards; handle jq falsy output such as `"null"` before downstream consumers. |
| 2.4 | Added/modified comments or docs claims | Check assertive claims (`always`, `never`, `must`, `works`) and intent phrases against implementation; flag new/changed doc comments whose one sentence chains independent reasons (`because`/`while`/`so that`). | Suggestion | Update/delete stale comments; add pinning tests for universal claims; split independent clauses (test: "does removing either change the other's meaning?"). |
| 2.5 | Base/branch references | Grep for hardcoded `main...HEAD`, `origin/main`, `master...HEAD`. | Blocker | Use dynamic base resolver. |
| 2.6 | Version pins | Grep Dockerfiles, tool manifests, package manifests, and GitHub Actions for `latest`, `stable`, `nightly`, unpinned tags, `^`, or `~`. | Blocker | Pin exact versions or official-action majors. |
| 2.7 | Signature/contract widening | Grep every caller/initializer for required params/fields; grep open merge/spread/update against structural containers; on a single-field-struct→plain-param collapse, check whether the field's zero-value (`""`/`0`/`false`/`nil`) reaches ≥2 callers for different semantic reasons. | Blocker | Update all call sites or add defaults; add allowlist/reserved-key/collision guards; for an overloaded zero-value (`question`) add a named const or per-call-site comment to preserve intent. |
| 2.8 | New/removed flags, symbols, errors, tests, docs terms | Sync docs, READMEs, specs, tests, PR body, in-code help, tables, and test counts. On a parameter/symbol rename, also grep the owning class/module docstring for the old name AND any behavioral phrase it qualified (e.g. "no findings" when the param narrowed to "blocking findings only") — prose claims don't match a symbol grep. | Blocker | Update all enumerations; include synonym/casing variants for removed terms; sync stale semantic phrasing in class docstrings in the same commit as the rename. |
| 2.9 | Design-pivot docs/specs | Verify plans, ADRs, specs, and inline comments match the new logical shape. | Blocker | Update dependent artifacts in the same branch. |
| 2.9.1 | Spec/interface with multi-mode type | Review structs/unions/records with ≥4 fields consumed by different modes. | Suggestion | Make compatibility explicit via consumer requirements or producer support matrix. |
| 2.10 | Existing PR | Fetch title/body; check behavior wording, test counts, file lists, remaining work, metadata, Jira suffix, rename/enum drift, rollout/ops section for prod-facing diffs. | Blocker | Record body drift as post-push TODO; fix before marking ready. |
| 2.11 | External API/CLI request shape | Require local reproduction of new payload/header/invocation or explicit user opt-out; verify error schema keys. | Blocker | Reproduce success/error responses; never assume API keys. |
| 2.12 | Prior self-review exists | Fetch threads; compare new rationale against stale approach comments. | Suggestion | Drop duplicates, cross-reference, or resolve superseded threads. |
| 2.13 | Direct comment API | Grep for `gh api .../pulls/<id>/comments`. | Blocker | Remove raw comment posting; verdict output only. |
| 2.14 | Pre-push hook config | Inspect `.lefthook.yml`, `.husky/pre-push`, `.git/hooks/pre-push`, `bin/ci`; enumerate every gate and multi-phase anchor. | Blocker | Run every gate locally; fix missing hook-phase wiring. |
| 2.15 | Source diff | Invoke `wk-workstyle check <path>` report-only on every source file; on test dedup into `shared_examples`/parameterized factories, audit dropped caller-specific coverage. | Suggestion | Surface magic values, nested ternaries, missing public docs, sad-path gaps, branch/test mismatches, async timing, stale comments, empty catches, duplicated test helpers, bugfix-without-regression-test; restore per-caller log-label assertions, entry-point integration coverage, and caller env-var-fallback tests the shared block hides. |
| 2.16 | Plugin/skill diff | Scan `SKILL.md` / plugin manifest for authoring-repo-relative paths. | Blocker | Use `${CLAUDE_PLUGIN_ROOT}/`, inline fallback, or pinned upstream fetch. |
| 2.17 | Dynamic-language diff | For each call kept/added, grep module/imported namespace for matching definition. | Blocker | Restore/remove call or add definition. |
| 2.18 | Removed named constant | Grep post-rebase diff for the literal value. | Suggestion | Restore constant or extract helper when literal appears at ≥2 non-comment sites. |
| 2.19a | Added Struct/Record/interface/Go field | Grep tests for direct concrete-value assertion on the new field. | Blocker | Add direct assertion; `respond_to?`/presence alone is insufficient. |
| 2.20 | Application code + CI pipeline | Extract net-new env reads; locate invoking pipeline steps; verify env allowlist forwarding. When the diff touches a compose `environment:` block or plugin `env:` array, escalate to a full-path audit: grep every script AND library in the container's runtime call graph (not just the diff delta) for env reads and diff that whole set against the forwarding list; run a sibling-template consistency check. | Blocker | Forward vars in native/container steps; exempt auto-injected prefixes only for native non-container steps. Surface any runtime read without a forwarding entry, including pre-existing reads in called libraries; siblings serving the same role must forward the same logical set. |
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
| 2.30 | Source fix with committed artifact | Detect `.wasm`, generated code, `go:generate`, `go:embed`, whitelisted build output. | Blocker | Rebuild and re-commit artifact before clear. |
| 2.31 | Added jq `else .` | Grep jq type-dispatch fallbacks. | Suggestion | Use `else empty` or prove all unlisted types render acceptably. |
| 2.32 | Go type widening | Run `goimports -l` on changed Go files when repo has `go.mod` and CI runs goimports. | Blocker | Run goimports before clear. |
| 2.33 | Raw-presence parse fallback | Grep parse-with-fallback shapes. | Blocker | Parse first; fallback on parsed result; add invalid-primary test. |
| 2.34 | Spec/doc claim about implementation routing (which method a gate calls, which path bypasses a hook) | Grep the PR review thread for reviewer statements describing the same routing. | Blocker | A reviewer who read the source is ground truth; resolve any contradiction before asserting an inferred claim. |
| 2.35 | Diff changes a structured return-type requirement in one doc section | Grep the whole document for every field comment that stores that value; confirm shape and vocabulary match. | Blocker | Update lagging field comments; keep one canonical name per value across all sections. |
| 2.36 | Named returns + deferred cleanup that reads a named return | Grep the function for `return <zero-literal>, ...` after the defer is established. An explicit return sets the named returns to those values *before* deferred funcs run, so the cleanup sees the zero value (e.g. `os.RemoveAll("")` → silent no-op, leaked resource). | Blocker | Assign then bare-return (`err = ...; return`) so the named var keeps its real value for the deferred cleanup; verify any comment claiming the defer cleans up "on any error path". |
| 2.37 | Gate reorder moves a cheap guard before a deeper call | Reordering short-circuits a failure path earlier, so calls it used to make become unreachable. Enumerate every now-unreachable call and check each `not_to receive` test covers all of them, not just the deepest (the diff usually touches only the deepest assertion). | Suggestion | Add the missing negative assertions; escalate to Blocker when a now-unreachable call was previously unstubbed and would hit the network/a real dependency. |
| 2.38 | New/renamed default-or-fallback constant | Grep all files for string literals describing the OLD default behavior (e.g. the prior default's name, "no model", "default") — display-label and logging helpers often hard-code the old representation and are missed by a call-site-only sweep. | Blocker | Update each stale literal or justify keeping it; a logging path emitting the old name reads as correct to operators at runtime. |
| 2.39 | Ruby diff with new/modified comment lines | When `.rubocop.yml` enables `Style/AsciiComments`, grep new `+` comment lines for non-ASCII (`[^\x00-\x7F]` — em-dash, curly quotes, arrows). | Blocker | Replace with ASCII; the cop fails CI with `Style/AsciiComments`. |

## Step 3: Fresh Adversarial Subagent

After sweeps, dispatch a fresh subagent with no prior context. Pipe `git diff "$BASE...HEAD"` directly; never hand-transcribe the diff. If excerpts are necessary, verify hunk boundaries first.

Subagent must be adversarial, unbiased, critical, objective, naming-aware, diff-sensitive, coverage-aware, refactor-aware, relocation-aware, introduction-claim-aware:

- **Coverage-aware:** test-only commits → enumerate code paths, flag unexercised paths.
- **Refactor-aware:** demand removed-line audit; every removed line is relocated or intentionally dropped.
- **Relocation-aware:** downgrade inherited pre-existing issues carried unchanged by a pure move.
- **Introduction-claim-aware:** before calling a behavior newly introduced, grep the `-` lines of the same hunk.

### Categories to Hunt

| Category | Failure modes |
|---|---|
| Logic / arithmetic | Off-by-one, first/last/one-past-end, pagination edges |
| Type coercion | `"0"` vs `0` vs `false`, `[]` vs `{}`, semantic-violation values |
| State / ordering | Use-before-init, use-after-close, double-init, async interleaving |
| Concurrency | Races, lock asymmetry, shared-state parallel callers |
| Contract changes | Signature widening, consumer sweep, old/new shape mismatch |
| Cross-system flow | Producer layout ≠ consumer scan, recursion mismatch, destructive cleanup before verify |
| Runtime portability | Shell/runtime matrix gaps |
| Refactor-removed behavior | Validation, recursion, error handling silently dropped |
| Test quality | Tautology, missing assertions, missing failure path, asymmetric field coverage |
| Security | Injection, secret leakage, redaction gaps, traversal |
| Data loss | Unprotected writes, race-prone cleanup, missing rollback |
| Error handling | Swallowed errors, generic catches, wrong error class |
| Performance | Quadratic scans, missing indexes, repeated I/O |

## Step 4: Findings Format and Severity

Each finding uses:

```
severity:   blocker | suggestion | question
file:       path
line:       N (must exist in the diff's commentable set)
category:   one of the hunt categories
finding:    one sentence
rationale:  one to three sentences, citing exact diff lines
fix-sketch: concrete code or command, not narrative
```

- `blocker`: correctness, security, data loss, HARD RULE violations.
- `suggestion`: naming/style/readability unless tied to a hard rule.
- `question`: genuine uncertainty.
- Omit hedging, filler, praise, diff restatement.

## Step 5: Playground Validation

Create `.review-playground/` only if needed; never commit a `.gitignore` entry for it. Confine writes to that directory.

- One script per runtime-behavior finding; drive each with the production runtime.
- Mutation-test each new test: flip a conditional, hardcode a return, swap args, remove an assertion → green = fake test.
- App cannot boot → use standalone playground. Fetch pinned upstream source, replicate method signatures, cite SHA/tag:

  ```bash
  gh api "repos/{owner}/{repo}/contents/{path}?ref={tag-or-sha}" --jq '.content' | base64 -d
  ```

- Downgrade unreproduced runtime claims from `blocker` to `question`.

### Runtime matrix

Run every interpreter the diff exercises, not whatever is first on `PATH`; flag any missing runtime for CI rather than silently skipping.

| Diff includes | Run under |
|---|---|
| `*.sh`, `*.bash`, `Brewfile`, shebanged shell | macOS bash 3.2 and modern bash; flag bash 4+ idioms. |
| `*.py` | each Python version in `requires-python` or CI. |
| `*.js`, `*.ts`, `package.json` engines change | each Node version in `engines.node`, `.nvmrc`, or CI. |
| `*.rb`, `Gemfile.lock` | each Ruby version in `.ruby-version` or CI. |
| `Dockerfile`, GH Actions matrix | each `runs-on` / base image listed. |

### Specialized checks (apply when the diff shape matches)

- **Producer→consumer layout:** populate staging dir with real producer layout; run consumer end-to-end. Verify path/key match, recursion depth, fixture placement, cleanup-after-consume ordering.
- **Cluster promotion/dedup:** test guard checks the chosen representative, not just the iteration anchor; iterate in reverse and non-sequential order.
- **Interface contract change:** run old shapes through new code and new shapes through old consumers.
- **Allowlist/privilege add:** compare new entry against existing siblings, not an empty list; note when strictly less privileged than a present entry.
- **Cross-step file persistence:** before flagging that a file written in one CI step won't reach a later step, grep the pipeline templates for `artifact_upload`/`artifact_download` (or `artifacts: upload`/`download`) matching that path. Confirmed upload+download resolves the concern → do not surface it. Script-level I/O crossing step boundaries always has a pipeline artifact contract; read the orchestration layer, not just the source.

### Documentation / prose / compression diffs — read-based analysis

When every changed file is docs, prompt/rule text, or non-executable fixture data, skip scratch scripts; substitute a read-based adversarial pass under `.review-playground/`:

- Cover ambiguity, contradictions, missing cases, edge-case prompts.
- Cross-check every numeric count in tables/enumerated claims against the actual items.
- **Compression/debloat diffs:** verify rule survival by *substance*, not by counting `HARD RULE` (or similar) labels — labels are trimmed first even when the rule they tagged is preserved, so label-count deltas are noise in either direction. Enumerate each gate the commit claims to preserve and content-grep it against the new file. With `grep -E`, write alternation as `a|b`; `\|` matches a literal pipe and silently returns zero (a false "missing gate").
- **Relocations:** flag org-specific tooling names, command aliases, internal script names, tracker IDs, short-link prefixes, or source-only paths absent from the destination repo; fix back-references to un-imported files.
- Flag committed absolute/home/worktree paths, local-only branches, or personal artifacts stated as permanent facts.
- Doc names a live code file as authoritative → read that file, verify stated constraints against the current branch.

## Step 6: Verdict and Records

Deduplicate by `(file, line, category)`, then return one verdict.

- **Clear:** zero blockers and zero unverified high-confidence runtime claims. Print commit range, HEAD SHA, finding counts. Write `.review-playground/.cleared-{HEAD_SHA}.json` with HEAD SHA, base, timestamp, finding counts, verdict.
- **Blocked:** print every blocker with file:line, category, fix sketch. Refuse to clear; caller fixes and re-invokes.
- **Suggestions only:** print suggestions and offer A/B/C: fix all in-line, clear with TODO/follow-up, or defer to tracked work. Default to A in auto mode when every fix-sketch is under 10 lines; otherwise B.

### Bot Reviewer Handling

Bot reviewers exist (`*[bot]`) → append:

- Post-push thread count may shrink; bots may retract and repost replacement threads.
- Caller must re-fetch threads after push and match by `(path, line, body_excerpt)`, not REST comment ID.
- Emit `session_resolved_classes` keyed by `(path_prefix, concern_class)` so callers mark bot echoes as already-addressed.

## Step 7: Fix Loop and Hand Back

On blocked verdict:

1. Caller fixes each blocker via `wk-commit` (one atomic conventional commit per fix).
2. Fix every structurally-parallel sibling in the same round.
3. Re-invoke this skill.
4. Loop until clear, max 3 cycles.
5. After 3 cycles, stop and surface to user; repeated recurrence means diagnosis/design is off.

Do not autosquash post-rebase artifact fixes mid-chain. Commit as a standalone conventional commit, then re-review.

Print the verdict line to the caller. Do not push, edit the PR, or post comments.

## Requirements

- `gh` CLI authenticated.
- Repo with base branch resolvable via `gh pr view` or `git symbolic-ref refs/remotes/origin/HEAD`.
- Write access to `.review-playground/` (gitignored).
- Runtime matrix installed via `mise` or equivalent when matrix checks are required.

## Post-Completion

Invoke `wk-learn adversarial-review`.
