---
name: wk-sharpen
description: >-
  Improve and de-bloat skills based on field reports or incident retrospectives.
  Extracts generalizable principles from specific failures without overfitting on
  examples, then condenses prose into crisp, nested instructions. Use when
  updating skills after agent runs surfaced gaps, errors, behavioral issues, or
  simplification opportunities. Prevents embedding specific file names, line
  numbers, or project details into skill instructions.
argument-hint: '[skill-name] [incident-file or description]'
allowed-tools:
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
  version: '2026.07.27-175524'
  model:
    openai: o3
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

- Treat the report's "Root cause" and "Suggested fix" as non-authoritative; the reporter saw a symptom and inferred a mechanism. A workaround that works is not evidence for that mechanism — it can succeed by another. Confirm a claimed cause exists in the source before documenting it; delete a documented cause the source disproves. A reproduction that disproves or sharpens the reported mechanism voids the draft → re-derive the fold from the source's semantics instead of patching wording, and prefer the formulation the source can be driven to demonstrate. A dispatching agent's claim about tree state — "no peer is mid-fold", "skip the collision check" — is a hypothesis under this same rule and loses to contradicting evidence from the tree.
- Learning names a deterministic artifact (hook, script, CI check) → read its source, reproduce the failure where cheap, before drafting. A red result from your own tooling is never a verdict — it indicts the tooling before the artifact: a new case failing while all pre-existing pass indicts the harness; a failed positive control indicts the control — needle from the changed span, control from an untouched one; length-guard both — len 0 is a defect, not a short needle. Drive it directly with the same input, rebuild a canary as a literal the pattern matches, a red result never justifies swapping the prescribed primitive, fix the harness in the same pass as audit cleanup when the two disagree.
  - Guard gates the agent's own tool calls → stage each test payload with the file-write tool and feed it to the hook by redirect; the same shape composed inline in a Bash call is itself the blocked call. Never reach for the guard's opt-out to run the test — it voids the result.
- Reject any fold that would *relax* a guard or check → hunt the correctness bug instead. A guard honoring caller-supplied scope is weaker than one deriving scope from the environment, and forfeits the property that makes the guard un-rationalizable.
- Record the rejected suggestion and its rationale in the reference file so it is not re-proposed.
- A `Rejected` / `Deliberately not promoted` note covering a design you are now adopting is a coverage gap to **execute**, not prose to re-read. Drive the shape it names against the artifact before *and* after; verdicts must match. Suite green without that case → missing coverage, not safety; land it as a pinned test this pass. Adopted with a compensating rule → rewrite the note to what now holds (a stale blanket rejection gets wrongly obeyed or wrongly ignored).

## Step 2: Read the Full Skill

- Determine which skill needs updating. Grep the learning's core subject across all of `skills/`; the defect's text may live in a skill other than the one filed — fold the principle into the API-mechanics home AND correct every over-general instance elsewhere in the same pass. If ambiguous, ask the user.
- **Resolve the on-disk skill dir by listing, never by transforming the display name.** Glob once, reuse the result: `d=$(ls -d skills/*"${n#wk-}" | head -1)`. Rationale: [`references/skill-dir-resolution.md`](references/skill-dir-resolution.md).
  - Empty listing → treat `skill:` as the reporter's *guess* at ownership, not a resolved target (learnings dirs are created on demand and never prefixed, so an unresolvable value is expected input): route by the subject grep to the skill whose body owns the mechanics. Never retry the path or file it as a gap; the zero-match rule below governs a resolved dir, not an empty listing.
- Treat a zero-match grep whose emptiness is load-bearing as **unverified until the path is confirmed to exist**.
- Read the entire `SKILL.md`, not just the target section — map its hard rules, step coverage, recurring themes, and tool-usage patterns.
- Partial reads do not satisfy the edit guard. Re-read narrow ranges when needed.

## Step 3: Distill the Lesson

- Transform the incident into a generalizable principle.
- Ask: what behavior must change, what check was missing, what failure mode to anticipate.

### HARD RULE: prohibited-subject gate — scan subject before drafting

- `command grep` the source learning/memory's core subject term against `.skillprohibit` and shape-matching hooks (`check-relative-paths`) at distill time, before byte-budget or draft (every load-bearing zero in this skill takes the `command` prefix).
- **Prove this gate's zero with a canary** — expand a denylist pattern to a literal it matches: [`references/staged-path-scan.md`](references/staged-path-scan.md).
- A lesson *about* an internal/prohibited tool or hook-blocked path shape can only produce edit text carrying it — the collision is knowable now, not at the Step 5 staged scan.
- On match: the lesson cannot land in the public repo. Route it to the user's private `CLAUDE.md`, mark the source distilled, skip the fold (no byte-budget, no draft).
- When recording a skipped or private-routed fold, name the subject by **category only** in the commit-message body — the `commit-msg` hook scans the message with the same term list as files, so a named token there fails the commit and forces a re-author cycle.

### HARD RULE: full-read before `already-covered`

- Mark a learning `already-covered` only after reading the full file and matching every rule / bullet.
- Match at the rule level, not the topic level.
- If any rule is missing, classify as `partial` and distill the missing part.
- Cite exact existing lines that prove coverage.

### HARD RULE: re-violation escalation — `already-covered` is NOT "done"

- A fresh learning that repeats an existing rule proves the rule failed → escalate.
- **Exception — positive-steering evidence blocks escalation:** before escalating an `already-covered` repeat, check for same-session evidence the rule fired correctly (a retro "What worked" bullet, or the learning conceding the existing behavior was right). If present, the rule worked: classify `already-covered`, cite the proving lines, do NOT escalate.
- **Escalate only against *installed* text.** A rule strengthened only in an uncommitted worktree fold never steered the failing run — installed diverges from worktree → classify `already-covered (unshipped)` and spend no notch. Repeat tracing to the rule's *shape* → the framing fix is load-bearing; the notch only records it. Escalation evidence only — a *landing* check reads **worktree** bytes, never installed or a tool's rendering.
  - **Needle from the learning's own subject; a supplied slug→line map is an unverified hint.** Every line in a rewritten span is new → novelty proves no *particular* lesson landed. Print each match beside its slug.
- Escalate exactly one notch up the 8-rung ladder: [`references/escalation-ladder.md`](references/escalation-ladder.md).
- Record the bump in the reference file.
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
- Reject ticket-shaped example tokens. Grep case-sensitive (never `-i` — it widens to `Word-Number` noise (`Step-5`)) against `[A-Z][A-Z0-9]+-\d+`; any match — even an invented placeholder — trips the `check-ticket-refs` hook, which matches shape, not provenance. Replace with `<child-key>`/`<KEY>` or the repo's `BOARD-NUM` form.
- When the user calls out an overfit, audit the whole cohort for the same pattern.
- **CRITICAL — run the owning hook scripts against the staged index; never reimplement their matcher.** Same flags ≠ same engine; a pattern file is the script's private config — often gitignored, so comment style and matcher constructs (PCRE `(?i)`) vary per checkout. A hand-rolled `grep -iEf` can return a silent NONE — rc=1, no stderr — on a term the hook flags. Never audit comment style to license a hand-roll; the governing risk is the false-*clean*. Run every hook after staging → real gate semantics, no synthetic probe:

  ```bash
  for h in .githooks/check-*.sh .githooks/scrub-staged.sh; do "$h" || echo "FAIL: $h"; done
  ```

  - **Index already holds another run's fold → never `git add` yours into it.** Stage-then-`git reset` is no repair: reset cannot restore which paths were staged. Copy the index, stage and run there; the same copy serves the Step 7.5 measure, keeping `measure()` verbatim.

    ```bash
    P="${TMPDIR:-/tmp}/probe-index"; cp .git/index "$P"; export GIT_INDEX_FILE="$P"
    git add <paths>; for h in .githooks/check-*.sh; do "$h" || echo "FAIL: $h"; done
    unset GIT_INDEX_FILE   # else every later git call silently uses the copy
    ```

- Hand-roll only what no hook covers: **staged path strings**. Anonymize every hit. Scan mechanics: [`references/staged-path-scan.md`](references/staged-path-scan.md).

## Step 6: Present for Review

- Show the user: distilled principle, edit location, proposed diff, cleanup found during audit.
- A direct `/wk-sharpen` invocation (and auto mode) IS the approval — apply/commit/push without re-asking; the show-list is a report, not a gate. Ask explicitly only for ambiguous `wk-learn`-vs-`wk-sharpen` routing or a destructive/irreversible action.

## Step 7: Apply the Update

- Edit `skills/{skill-name}/SKILL.md` and every audit cleanup item.
- Verify each new or edited section follows the style rules.
- Bump `metadata.version` to a fresh CalVer.
- Re-read the final file end-to-end.
- Write one short reference file per learning (create the dir if missing); frontmatter `class:` and per-class body fields: [`references/reference-file-template.md`](references/reference-file-template.md).
- Never link a per-learning reference from `SKILL.md` — they are the distillation record, not runtime pointers. (Curated shared procedure references are linked; those are a different artifact.) Run the overfit scan on both.

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
- Recount any documented set from source, never increment; shape the probe to the source markup, prove it fires on a known member (mismatch → 0 = phantom drift).
- Cross-references still resolve.
- Examples reflect the post-edit behavior.
- Fix every drift item in the same pass.

## Step 7.5: De-bloat Pass (concision gate)

### HARD RULE: de-bloat every run — never let prose accrete

- Run on **every** sharpening, not only when a learning prompts it.
- **Bulletize, do not compress prose.** One rule per line, imperative voice, `→` for causality, drop articles/connectives in procedural text.
- State a rule once; cross-reference instead of restating; cut explanatory filler.
- **Merging duplicates → keep the occurrence a run reaches first, cross-reference forward.** Deleting a rule's earliest statement moves it later in reading order — the defect a reachability fold exists to fix.
- **Preserve every rule, failure mode, and command.** Reject any edit that drops a HARD RULE, error code, or failure-mode explanation.
- Re-run the Drift check after de-bloat edits land.

### HARD RULE: hard size ceilings per `SKILL.md`

- `.githooks/check-skill-size.sh` blocks a commit breaching any of four env-tunable ceilings — **body ≤ 24576 bytes** (`SKILL_SIZE_MAX_BYTES`), plus front-matter / `description:` / `allowed-tools:` limits: [`references/byte-budget.md`](references/byte-budget.md).
- Keep skills under the ceilings proactively — never rely on the hook as the only guard. The `description` and `allowed-tools` list are reclaim targets too.
- **Prefer content-removing structural moves over prose-mangling to reclaim bytes** (zero coverage risk): relocate narrow, tool-specific catalog rows to a `references/` file and update the pointer's ID list — route a **new** such row straight there (ID only inline), never place-inline-then-reclaim; delete scaffolding or a provably-duplicated rule outright.
  - **Search duplicates first, relocate last, prose-tighten only for the final margin.**
  - **Never reclaim a rule's earliest statement** — score duplicates by reading order; only the later occurrence is deletable.
  - **Grep `references/` for a recorded stay-inline / rejected-relocation note before proposing any relocation.**
- **Measure the staged body BEFORE drafting any content-adding fold.** Headroom under ~2× the edit → budget ≥2 reclaim targets up front whose *combined NET* exceeds the edit by ≥1.2×.
  - **Budget the fold PLUS an audit-cleanup allowance** (~25%/floor ~300 B) and size reclaim against that total. Run the Step 5 audit first → **measured** cleanup replaces that estimate, often **0 B**.
  - **Binding gate = net non-positive AND under every ceiling; the 1.2× ratio is the planning target.**
  - **Reclaim exhausted, net still positive → tighten the *addition*.**
  - **Never relocate a gate's enumerated pass/fail checks, or a verification checklist, behind a pointer** — the ceiling never outranks a load-bearing rule. Per-hook recovery rows are catalog, not gate — those move freely.
  - **CRITICAL — state the budget as arithmetic before any edit:** byte-measure each reclaim's NET and the addition as the *exact* old/new pair you will apply.
  - **Very important — stage addition + reclaim cuts together, then measure exactly once**, running the hook's `measure()` verbatim.

## Step 8: Verify and Commit (terminal gate)

Do not return control until all five pass:

1. **Install:** `cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -5` — success = `Done!` or `Installed <N> skills` (accept either marker). Prefix the explicit `cd`; the Bash cwd persists across calls, so a `cd` from an earlier step can leave a `.`-relative install in the wrong dir ("No valid skills found").
2. **Suite:** fold edited an executable artifact the skill ships (hook, script, binary — not `SKILL.md`/`README.md`/`references/`) → locate and run that skill's own test suite before committing; a shipped-code edit must never reach the commit gate unrun. Red result → apply the Step 1 harness-defect rule.
3. **Commit:** stage only the paths this run touched — edited `SKILL.md`/`README.md`/`references/`, version bumps, and the specific learning/retro files this run processed and renamed to `.learned.md`. Use `wk-commit` conventional format with classifier emojis.
   - Recovery for a blocked commit: [`references/commit-gate.md`](references/commit-gate.md).
   - On signing failure, stop — don't loop on commit, re-stage, or re-distill; ask the user for an interactive signer unlock. A listed agent key (`ssh-add -l` ok) ≠ signing capability; only a completed signed commit proves it. Anti-thrash ≠ gate discharge: an inherited fold's gates are **unrun** until the tree records otherwise — run the shipped-code suite and the owning hooks (Step 5 throwaway index), and leave the index partitioned as the prior run left it.
4. **Push once:** after all commits exist, push a single time.
5. **Clean tree:** no modified tracked path in `git status --short` — untracked *unprocessed* learnings/retros are expected state, never debris to delete.

Report: one line per skill updated, then confirm tree clean, installed, pushed.

## Batch Mode: Scan Learnings, Memories, and Retrospects

Invoked without a specific incident → batch mode.

- **A "source drained" verdict needs a control whose target can structurally produce a hit under the scan's own invocation form.** A traversal that skips a class of node (`find -type f` never descends a symlinked dir) returns zero for any content when rooted where those nodes live — dead, yet indistinguishable from a real drain. Plant an in-place canary in the scanned tree, re-run the identical form, and corroborate with a primitive lacking that blind spot (`ls -laR`, `find -L`).
  - **Two-stage-disagreement control must *reach* the compare, not just permit it.** Make the differing element order-flipping, on the arm-under-test side. Agreeing arms exercised nothing yet read as decorative; agreement is no zero, so the tripwire misses it.

### Sources 1 & 4 and processed-state tracking

- **Source 1** (mirror the global inbox into the repo tree) and **Source 4** (session retrospects) both feed the Source 2 path.
- Full mirror / scan / rename mechanics — read before draining either source: [`references/batch-mode-sources.md`](references/batch-mode-sources.md).

### Source 2: Repo learnings directory

- Scan `$WK_SKILLS_HOME/learnings/skills/` for unprocessed files.
- Process every unprocessed learning one-by-one, severity-ordered: read it, run the sharpen workflow, confirm the distilled principle landed, then rename to `.learned.md`.
- Re-list before folding each item and after each fold-commit — peers write continuously; "drained" is a terminal check after the last commit, never set up-front.
- **An arrival whose mtime postdates the run's start is unowned, not assigned.** Neither it nor commit recency sees a *claim* (the marker is a rename; `mv` keeps mtime) and no lock arbitrates, so re-list first: a vanished item, or either signal showing a peer → unclaimed backlog, do not fold. Terminal state is "processed N, M unclaimed, K distilled-not-landed" — never "drained". A fold applied under a blocked gate is distilled-not-landed: leave it unrenamed and name it in the report — never counted processed, never re-queued as backlog.

### Source 3: Global memory files

- Scan `$HOME/.claude/memory/` for memory files.
- Process `feedback` memories; process `user` / `project` only when they carry explicit instructions on how a skill should behave.
- Determine which skill the feedback applies to.
- Materialize each matched memory as a learning via `wk-learn`, then distill it through the Source 2 path.
- **Gate the listing by parse-as-memory BEFORE diffing the marker**, and never add a marker entry for a file this run did not process — the marker records distillation, not suppression.
- **Unanimity indicts the tooling — both stages, both directions; non-unanimity never exonerates it.** Match `type:` at column 0 **and** nested under `metadata:`; build one positive control **per shape**.
- **Normalize both sides, then pin `LC_ALL=C` on the `comm` itself — not just the sort.** Mechanics: [`references/memory-marker-diff.md`](references/memory-marker-diff.md).

### Batch mode presentation

- Before processing, present counts: learnings, memories, retrospects, processing.
- After processing, report: skills updated, learnings absorbed, memories distilled, skipped items.

## Improve Mode: Refactor and Optimize

`/wk-sharpen improve [scope]` → suite-level cleanup, not incident-specific fixes. Scope is omitted / `all`, `<skill-name>`, or a glob. Procedure and hard rules: [`references/improve-mode.md`](references/improve-mode.md). **Phased approval is required per phase; auto mode never short-circuits it.**

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn sharpen`).