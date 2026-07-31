---
name: wk-sharpen
description: >-
  Improve and de-bloat skills based on field reports or incident retrospectives.
  Extracts generalizable principles from specific failures without overfitting on
  examples, then condenses prose into crisp, nested instructions. Use when
  updating skills after agent runs surfaced gaps, errors, behavioral issues, or
  simplification opportunities. Prevents embedding specific file names, line
  numbers, or project details into skill instructions.
argument-hint: '[skill-name] [incident-file] | loop <N>mins | improve [scope]'
allowed-tools:
  - Agent
  - ScheduleWakeup
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - Bash
  - Skill
  - AskUserQuestion
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: workflows
env-vars:
  - WK_SKILLS_HOME
  - GITHUB_ORG
  - EMPLOYER
metadata:
  author: whizzzkid
  version: "2026.07.31-024537"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Sharpen

Extract the **principle** behind a failure → update the skill to prevent the
behavior, not just the specific instance.

## When to Use

- A field report, retro, or skill run surfaced an error, gap, or behavioral pattern worth preventing.
- A skill needs simplification or bloat reduction without losing critical rules.

### HARD RULE: invocation routing — `wk-learn` vs `wk-sharpen`

- `wk-sharpen` rewrites `SKILL.md` files; `wk-learn` only writes to `learnings/`.
- Direct skill edits without explicit user consent are out of scope.
- Route to `wk-learn` (capture only, no skill edits): "make a learning", "capture this", "note this for later", "log what happened".
- Route to `wk-sharpen` (apply edits to `SKILL.md`): "sharpen the skill", "apply this to the skill", "update the skill now", explicit `/wk-sharpen`.
- Ambiguous phrasing ("learn from this and sharpen") defaults to `wk-learn`. Ask before promoting to `wk-sharpen`.

## Style Rules for Every Edit

- **Bullets over prose; imperative voice; one rule per bullet.** Split chained instructions.
- **Instructional, not explanatory** — the "why" goes in one trailing parenthetical, concrete commands in fenced blocks.
- Crispness, no-essays, and section-splitting rules: [`references/style-rules.md`](references/style-rules.md).

## Core Rule: Extract Principles, Not Examples

- Remove specific file names, line numbers, project context, and reviewer / commit names — a rule reading "lines 232/60 in model.md" is overfit.
- Keep error codes, API behavior, and structural patterns — e.g. "a line not in the diff causes a 422 from the GitHub API" generalizes.

## Cross-Cutting Rules — each binds its operation, not its step

- **A control is dead unless its target can produce a hit under the operation's own invocation form** — source scans, drift probes, a gate this fold just wrote. Assert the **trigger's own input count is non-zero** before reading a gate's verdict: [`references/harness-defect-triage.md`](references/harness-defect-triage.md).
- **Important — any grep whose zero over a resolved path is load-bearing:** `command grep`, one quoted path per invocation, rc 0/1/≥2 = hit/clean/error; never let `||` or a banner supply a verdict.

## IMPORTANT — high-severity learnings are not optional

- Read the frontmatter and extract `severity`.
- If `severity: high` (or higher), treat the item as **MUST-FOLD**:
  - Land the lesson in `SKILL.md` as a new rule, HARD RULE, or sub-step.
  - Reference-file-only routing is forbidden.
  - The processed-state record must show full distillation.
  - Rename to `.learned.md` only after the edit and version bump land.
- **Ownership resolves before thoroughness; severity never grants it.** MUST-FOLD sets how thoroughly to fold an item this run *owns* — never whether it owns it. An unowned or concurrently-claimed arrival stays unclaimed backlog for the dispatcher, at priority. A blocked commit gate defers by *target-path* state, not gate state: a path already carrying an uncommitted fold → extend it and advance its single version bump, never open a competing one; a clean unclaimed path → defer as blocked backlog. Fold only where it adds no entanglement the path did not already carry.
- When in doubt, ask before renaming.

## Step 1: Read the Incident Report

- Read the file path if given; otherwise internalize the verbal description.
- Extract: intended behavior, what went wrong, which artifacts failed, and the root cause — a claim to verify, never a fact.

### HARD RULE: the report is a hypothesis — verify against the owning source

- Treat a report's "Root cause"/"Suggested fix" as hypotheses. A successful workaround is not evidence; it may use
  another mechanism. Verify claims in source; delete disproved causes. A reproduction that disproves or sharpens the
  mechanism voids the draft → re-derive from source semantics, preferring a demonstrable formulation. A dispatcher's
  claim about tree state is also a hypothesis and loses to contradicting tree evidence.
- Learning names a deterministic artifact (hook, script, CI check) → read its source, reproduce the failure where cheap, before drafting. A red result from your own tooling indicts the tooling before the artifact; never swap the prescribed primitive over a red result. Triage rows — needle/control sourcing, length guards, canary rebuild, staging a payload past a guard: [`references/harness-defect-triage.md`](references/harness-defect-triage.md). Reproduction proves the mechanism only in the configuration it ran → enumerate what the fixtures held constant and vary them, or name it in the rule's trigger.
- Reject any fold that would *relax* a guard or check → hunt the correctness bug instead. A guard honoring caller-supplied scope is weaker than one deriving scope from the environment, and forfeits the property that makes the guard un-rationalizable.
- Record the rejected suggestion and its rationale in the reference file so it is not re-proposed.
- Adopting a design covered by a "Rejected" / "Deliberately not promoted" note → execute its named shape before and
  after; verdicts must match. Suite green without that case → land a pinned test. Rewrite the note to its current
  grounds after a compensating rule.

## Step 2: Read the Full Skill

- Determine which skill needs updating. Grep the learning's core subject across all of `skills/`; the defect's text may live in a skill other than the one filed — fold the principle into the API-mechanics home AND correct every over-general instance elsewhere in the same pass. If ambiguous, ask the user.
- **Resolve the on-disk skill dir by listing, never by transforming the display name.** Glob once, reuse the result: `d=$(ls -d skills/*"${n#wk-}" | head -1)`. Rationale: [`references/skill-dir-resolution.md`](references/skill-dir-resolution.md).
- Read the entire `SKILL.md`, not just the target section — map its hard rules, step coverage, recurring themes, and tool-usage patterns.
- Partial reads do not satisfy the edit guard; a refused or content-less read → narrow ranged re-read. **Slice every exact-match anchor from the file's bytes, never a rendering** — silent word-drops stay grammatical, so the anchor misses or edits the wrong span.

## Step 3: Distill the Lesson

- Transform the incident into a generalizable principle.
- Ask: what behavior must change, what check was missing, what failure mode to anticipate.

### HARD RULE: prohibited-subject gate — scan subject before drafting

- `command grep` the source learning/memory's core subject term through `.skillprohibit` and shape-matching hooks (`check-relative-paths`) at distill time, before byte-budget or draft.
- **Denylist = pattern file, never haystack** — subject on stdin, patterns via `-f`; inverted → fails **open**. Strip its comment/blank lines, as the owning hooks do — `-f` reads them as patterns: false **dirty**, hidden by `-q`.
- **Prove this gate's zero with a canary**: [`references/staged-path-scan.md`](references/staged-path-scan.md).
- A lesson *about* an internal/prohibited tool or hook-blocked path shape can only produce edit text carrying it — the collision is knowable now, not at the Step 5 staged scan.
- On match: the lesson cannot land in the public repo. Route it to the user's private `CLAUDE.md`, mark the source distilled, skip the fold (no byte-budget, no draft).
- When recording a skipped or private-routed fold, name the subject by **category only** in the commit-message body — the `commit-msg` hook scans the message with the same term list as files, so a named token there fails the commit and forces a re-author cycle.

### HARD RULE: full-read before `already-covered`

- Mark a learning `already-covered` only after reading the body **plus every linked reference** and matching every rule / bullet.
- Match at the rule level, not the topic level.
- If any rule is missing, classify as `partial` and distill the missing part.
- Cite exact existing lines that prove coverage, each with its file; one resolving only to an *unlinked* per-learning record → `partial`.

### HARD RULE: re-violation escalation — `already-covered` is NOT "done"

- A fresh learning that repeats an existing rule proves the rule failed → escalate.
- **Exception — positive-steering evidence blocks escalation:** before escalating an `already-covered` repeat, check for same-session evidence the rule fired correctly (a retro "What worked" bullet, or the learning conceding the existing behavior was right). If present, the rule worked: classify `already-covered`, cite the proving lines, do NOT escalate.
- **Escalate only against text installed *before the report*.** A rule living only in an uncommitted worktree fold, or landing after it, never steered the failing run → `already-covered (unshipped)`, no notch, even when installed and worktree agree. Date from history, never inference: `git log -S '<needle>' -- <file>`; severity-ordered backlog makes report-older-than-rule normal. Repeat tracing to the rule's *shape* → the framing fix is load-bearing; the notch only records it. Escalation evidence only — a *landing* check reads **worktree** bytes, not installed or a rendering.
  - **Needle from the learning's own subject; a supplied slug→line map is an unverified hint.** Every line in a rewritten span is new → novelty proves no *particular* lesson landed. Print each match beside its slug.
- Escalate exactly one notch up the 8-rung ladder: [`references/escalation-ladder.md`](references/escalation-ladder.md).
- Treat an escalation as a principle edit.

### Classify: principle vs one-off

- `principle` — the failure mode generalizes. Route to `SKILL.md` plus a reference file.
- `one-off` — the scenario is narrow, repo-specific, or unlikely to recur. Route to a reference file only.
- Enumerated tests for either class (consult when the class is not obvious): [`references/classify-criteria.md`](references/classify-criteria.md).
- Record the classification in the run report and in the reference file frontmatter.
- When ambiguous, ask once.

## Step 4: Draft the Skill Update

- Skip Step 4 for `one-off` lessons.
- Locate the edit target: a new step, a missing check, a wrong instruction, or a new HARD RULE.
- **Check the report's prescribed remedy against the target's installed HARD RULEs and tool-selection rules before drafting** — a remedy naming a command, endpoint, or path the target already constrains is incidental to the lesson. Installed rule wins → re-express in the sanctioned tooling, keep only what survives translation (post-draft, the conflict reads as a second valid option, not a defect).
- **Edit target is a gate governing this fold's own landing → apply the stricter of its pre-edit and post-edit text**, and record which in the run report; a loosened rule takes effect next run, once installed.
- Format the update as instructions, not narrative — heading, then what to do (imperative), why it matters, how (commands or checks).

## Step 5: Audit the Full Skill

- Re-read the entire skill with the proposed edit mentally applied.
- Merge overlapping instructions; resolve contradictions; consolidate redundant tool usage and repeated API/CLI calls.
- Bulletize bloated sections; refresh stale references; remove dead labels and orphaned label artifacts.
- Revert any uncommitted edit to the target not made this run that doesn't address the lesson (prior partial fold may encode a wrong model).
- Bundle cleanup into the same change.

### Mechanical overfit scan

- Before presenting the diff, grep the edit text against the overfit categories: [`references/overfit-categories.md`](references/overfit-categories.md).
- Replace each match with a generic mechanism or placeholder.
- Parameterize real paths instead of dropping them.
- Justify inline only when the literal token is required.
- Apply replacement maps longest-first.
- Reject ticket-shaped example tokens: case-sensitive grep (never `-i`) for `[A-Z][A-Z0-9]+-\d+`, replace with `<KEY>` or the repo's `BOARD-NUM` form — [`references/ticket-shaped-example-tokens.md`](references/ticket-shaped-example-tokens.md).
- When the user calls out an overfit, audit the whole cohort for the same pattern.
- **HIGH-PRIORITY — run the owning hook scripts against the staged index; never reimplement their matcher.** A hand-rolled verdict binds in **neither** direction — reconcile it against the owning hook's: [`references/staged-path-scan.md`](references/staged-path-scan.md). Run every hook after staging → real gate semantics, no synthetic probe:

  ```bash
  for h in .githooks/check-*.sh .githooks/scrub-staged.sh; do "$h" || echo "FAIL: $h"; done
  ```

  - **Index already holds another run's fold → never `git add` yours into it.** Throwaway-index procedure: [`references/byte-budget.md`](references/byte-budget.md).
- Hand-roll only what no hook covers: **staged path strings** and the category scan above. Anonymize every hit; both take the load-bearing-zero rule above.

## Step 6: Present for Review

- Show the user: distilled principle, edit location, proposed diff, cleanup found during audit.
- A direct `/wk-sharpen` invocation (and auto mode) IS the approval — apply/commit/push without re-asking; the show-list is a report, not a gate. Ask explicitly only for ambiguous `wk-learn`-vs-`wk-sharpen` routing or a destructive/irreversible action.

## Step 7: Apply the Update

- Edit `skills/{skill-name}/SKILL.md` and every audit cleanup item.
- Verify each new or edited section follows the style rules.
- Bump `metadata.version` to a fresh CalVer.
- Re-read the final file end-to-end.
- Write one short reference file per learning (create the dir if missing); frontmatter `class:` and per-class body fields: [`references/reference-file-template.md`](references/reference-file-template.md).
- Never link a per-learning reference from `SKILL.md` — they are the distillation record, not runtime pointers. Run the overfit scan on both.

### Sync skill README, diagrams, and repo-level docs

- Bump the sibling `README.md` `Version:` line to match `metadata.version` and stage it on **every** version change — unconditional, even when no step/diagram/narrative changed. `.githooks/check-readme-sync.sh` blocks any commit staging a `SKILL.md` without its sibling `README.md`.
- Update `skills/{skill-name}/README.md` narrative when a step, phase, trigger, or argument shape changed.
- Update any Mermaid diagram to match the new flow.
- Write every README `wk-*` mention as a relative link — on first `Version:` add and when authoring a new sibling.
- Update both index files when the one-line description changes.
- Invoke `wk-docs` when the edit changes cross-skill behavior or documented workflow.
- Stage doc edits with the SKILL.md change.

### Drift check

- Frontmatter `description` still matches the behavior.
- `argument-hint` matches the current argument shape.
- `allowed-tools` lists every tool the new edits reference.
- Quick-reference table, Trigger table, and Step list match the body.
- Recount any documented set from source, never increment; shape the probe to the source markup, prove it fires on a known member, and prove a range probe's anchor **unique** before trusting its count: [`references/recount-probe-bounds.md`](references/recount-probe-bounds.md).
- Cross-references resolve both ways — links land, and no `references/` pointer HEAD carried was dropped while its file survives (`.githooks/check-reference-orphans.sh`).
- Ordering, selection, or scope changes → grep the skill's own references for dispatch/spawn prompt templates and
  quoted self-instructions; synchronize every semantic copy (link checks cannot detect paraphrase drift).
- Examples reflect the post-edit behavior.
- Fix every drift item in the same pass.

## Step 7.5: De-bloat Pass (concision gate)

### HARD RULE: de-bloat every run — never let prose accrete

- Run on **every** sharpening, not only when a learning prompts it.
- **Bulletize, do not compress prose.** One rule per line, imperative voice, `→` for causality, drop articles/connectives in procedural text.
- State a rule once; cross-reference instead of restating; cut explanatory filler.
- **Merging duplicates → keep the occurrence a run reaches first, cross-reference forward.** Deleting a rule's earliest statement moves it later in reading order — the defect a reachability fold exists to fix. Relocation is exempt: write the pointer at the cut site and the rule stays reachable where it was.
- **Preserve every rule, failure mode, and command.** Reject any edit that drops a HARD RULE, error code, or failure-mode explanation.
- Re-run the Drift check after de-bloat edits land.

### HARD RULE: hard size ceilings per `SKILL.md`

- `.githooks/check-skill-size.sh` blocks a commit breaching any of four env-tunable ceilings — **body ≤ 24576 bytes** (`SKILL_SIZE_MAX_BYTES`), plus front-matter / `description:` / `allowed-tools:` limits: [`references/byte-budget.md`](references/byte-budget.md).
- Keep skills under the ceilings proactively — never rely on the hook as the only guard. The `description` and `allowed-tools` list are reclaim targets too.
- **Prefer content-removing structural moves over prose-mangling to reclaim bytes** (zero coverage risk): relocate narrow, tool-specific catalog rows to a `references/` file and update the pointer's ID list — route a **new** such row straight there (ID only inline), never place-inline-then-reclaim; delete scaffolding or a provably-duplicated rule outright.
  - **Search duplicates first, relocate last, prose-tighten only for the final margin.**
  - **Grep `references/` for a recorded stay-inline / rejected-relocation note before relocating — a hit vetoes only while its stated grounds still hold.**
  - Grounds unstated, aggregate, or scored before a now-reachable shape → re-test, never obey.
  - Clearing one ground is not clearance → re-check permanent protections; another ground upholds veto → amend note and supersede stale ground.
- **Measure the staged body AND price the reclaim pool BEFORE drafting any content-adding fold** — a pool priced after the draft judges a fixed number → trim cycle guaranteed. Headroom under ~2× the edit → budget ≥2 reclaim targets whose *combined NET* exceeds the edit by ≥1.2×. Draft under both inverted: `draft_max = max(headroom/2, pool_NET/1.2)`.
  - **Budget the fold PLUS an audit-cleanup allowance** (~25%/floor ~300 B) and size reclaim against that total. Run the Step 5 audit first → **measured** cleanup replaces that estimate, often **0 B**.
  - **Never relocate a gate's enumerated pass/fail checks or a verification checklist behind a pointer, and never cut a rule's verified-configuration qualifier** — the ceiling never outranks a load-bearing rule. Per-hook recovery rows are catalog, not gate — those move freely.
  - **CRITICAL — running byte ledger per touched `SKILL.md`:**
    - Measure each file at entry; debit every edit group before the next edit.
    - Record `baseline + additions - reclaims = projected body` and headroom.
    - No entry → unbudgeted.
    - Price each debit from exact applied old/new bytes; any change voids it → re-price.
    - Stage all edits; run the hook's `measure()` exactly once.

## Step 8: Verify and Commit (terminal gate)

Do not return control until all five pass:

1. **Install:**
   - Preflight every replacement prerequisite before removing active copies; a miss must leave the current
     installation intact.
   - Run `cd "$WK_SKILLS_HOME" && scripts/install-skills.sh`; its targets must include the active runtime
     ([`references/step8-install-cd-repo-root.md`](references/step8-install-cd-repo-root.md)).
   - Byte-compare the runtime’s installed `SKILL.md` and every changed reference with repository source;
     generic success output or any mismatch fails the gate.
2. **Suite:** fold edited an executable artifact the skill ships (hook, script, binary — not `SKILL.md`/`README.md`/`references/`) → locate and run that skill's own test suite before committing. Red result → apply the Step 1 harness-defect rule.
3. **Commit:** stage only the paths this run touched — edited `SKILL.md`/`README.md`/`references/`, version bumps, and the specific learning/retro files this run processed and renamed to `.learned.md`. Use `wk-commit` conventional format with classifier emojis.
   - Recovery for a blocked commit, signing failure included: [`references/commit-gate.md`](references/commit-gate.md).
   - Anti-thrash ≠ gate discharge: an inherited fold's gates are **unrun** until the tree records otherwise — run the shipped-code suite and the owning hooks (Step 5 throwaway index), and leave the index partitioned as the prior run left it.
4. **Push once:** after all commits exist, push a single time. A signing failure at item 3 blocks this too — same agent, different error string.
5. **Clean tree:** no modified tracked path in `git status --short` — untracked *unprocessed* learnings/retros are expected state, never debris to delete.

Report: one line per skill updated, then confirm tree clean, installed, pushed.

## Batch Mode: Scan Learnings, Memories, and Retrospects

Invoked without a specific incident → batch mode.

- **A "source drained" verdict needs a live control** — sourced per [`references/batch-mode-sources.md`](references/batch-mode-sources.md). Drained = rc 0 **and** empty output, never a banner.
- **Source 1** (global inbox → repo tree) and **Source 4** (session retrospects) feed the Source 2 path; mirror / scan / rename / processed-state mechanics in the reference above — read before draining either.
- **Source 3** (global memory files) — `$HOME/.claude/memory/`: `feedback`, plus `user` / `project` only when they instruct how a skill behaves; materialize each via `wk-learn` into the Source 2 path. Parse-as-memory gate before the marker diff, marker-records-distillation-not-suppression, per-shape controls, and uniform `LC_ALL=C` pinning: [`references/memory-marker-diff.md`](references/memory-marker-diff.md).

### Source 2: Repo learnings directory

- Scan `$WK_SKILLS_HOME/learnings/skills/`; process every unprocessed learning one-by-one, **severity-ordered, oldest mtime first within a band** (one wide band is the normal shape, so the tie-break decides most picks; an invented one collides with a peer's and lets a hard item be skipped forever): read it, run the sharpen workflow, confirm the distilled principle landed, then `mv` (never `git mv` — it refuses an untracked path) to `.learned.md`, checking rc.
- Re-list before folding each item and after each fold-commit — peers write continuously; "drained" is a terminal check after the last commit, never set up-front.
- **An arrival whose mtime postdates the run's start is unowned, not assigned.** Neither it nor commit recency sees a *claim* (the marker is a rename; `mv` keeps mtime) and no lock arbitrates, so re-list first: a vanished item, or either signal showing a peer → unclaimed backlog, do not fold. Terminal state is "processed N, M unclaimed, K distilled-not-landed" — never "drained". A fold applied under a blocked gate is distilled-not-landed: leave it unrenamed and name it in the report — never counted processed, never re-queued as backlog.

## Loop Mode: `/wk-sharpen loop <N>mins`

Self-paced batch mode — one background subagent per cycle, zero inherited context, drains the **entire** queue before stopping; next cycle N minutes after this one *finishes*. Spawn / drain / schedule / stop mechanics: [`references/loop-mode.md`](references/loop-mode.md).

- **Exactly one agent in flight, machine-wide.** Concurrent folds contend over one queue and one `SKILL.md`: two runs claim one learning.
- **A cycle drains to empty, never one item** — fold, commit, re-list, repeat; one item per cycle loses to the arrival rate.

## Improve Mode: Refactor and Optimize

`/wk-sharpen improve [scope]` → suite-level cleanup, not incident-specific fixes. Scope is omitted / `all`, `<skill-name>`, or a glob. Procedure and hard rules: [`references/improve-mode.md`](references/improve-mode.md). **Phased approval is required per phase; auto mode never short-circuits it.**

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn sharpen`).
