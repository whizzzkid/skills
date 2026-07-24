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
  version: '2026.07.24-230812'
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

- Another agent ran a skill and hit an error or gap
- A field report describes what went wrong during skill execution
- A retrospective identifies a behavioral pattern worth preventing
- You're about to edit a skill based on a specific incident
- A skill needs simplification or bloat reduction without losing critical rules

### HARD RULE: invocation routing — `wk-learn` vs `wk-sharpen`

- `wk-sharpen` rewrites `SKILL.md` files; `wk-learn` only writes to `learnings/`.
- Direct skill edits without explicit user consent are out of scope.
- Route to `wk-learn` (capture only, no skill edits):
  - "make a learning"
  - "capture this"
  - "note this for later"
  - "log what happened"
- Route to `wk-sharpen` (apply edits to `SKILL.md`):
  - "sharpen the skill"
  - "apply this to the skill"
  - "update the skill now"
  - explicit `/wk-sharpen` invocation
- Ambiguous phrasing ("learn from this and sharpen") defaults to `wk-learn`. Ask before promoting to `wk-sharpen`.

## Style Rules for Every Edit

- **Bullets over prose.** Use paragraphs only when a rule cannot be split without loss.
- **Imperative voice.** Start bullets with verbs like "Run", "Verify", "Reject", "Skip", "Re-fetch".
- **One rule per bullet.** Split chained instructions.
- **Crisp.** Strip hedging and state the failure mode in one clause.
- **Instructional, not explanatory.** Put the "why" in one trailing sub-bullet or parenthetical.
- **Concrete commands** belong in fenced code blocks.
- **No essays.** Split any section that grows past four bullets.

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
- Treat unrecognized log actions as `unverified` and re-audit.
- When in doubt, ask before renaming.

## Step 1: Read the Incident Report

- Read the file path if given; otherwise internalize the verbal description.
- Extract:
  - What the agent was supposed to do
  - What went wrong
  - Which artifacts failed
  - Root cause — a claim to verify, never a fact

### HARD RULE: the report is a hypothesis — verify against the owning source

- Treat the report's "Root cause" and "Suggested fix" as non-authoritative; the reporter saw a symptom and inferred a mechanism. A workaround that works is not evidence for that mechanism — it can succeed by another. Confirm a claimed cause exists in the source before documenting it; delete a documented cause the source disproves.
- Learning names a deterministic artifact (hook, script, CI check) → read that artifact's source, and reproduce the failure where cheap, before drafting. A red result from your own verification tooling is not a verdict either: a newly added case failing while every pre-existing case passes indicts the harness first — drive the artifact directly with the same input, and fix the harness in the same pass as audit cleanup when the two disagree.
- Reject any fold that would *relax* a guard or check → hunt the correctness bug instead. A guard honoring caller-supplied scope is weaker than one deriving scope from the environment, and forfeits the property that makes the guard un-rationalizable.
- Record the rejected suggestion and the rationale in the reference file so it is not re-proposed.

## Step 2: Read the Full Skill

- Determine which skill needs updating. Grep the learning's core subject across all of `skills/`; the defect's text may live in a skill other than the one filed — fold the principle into the API-mechanics home AND correct every over-general instance elsewhere in the same pass. If ambiguous, ask the user.
- **Resolve the on-disk skill dir by listing, never by transforming the display name.** Dir naming is not invariant with `name:` — most drop a leading `wk-`, some keep it, so both a blind strip and a blind reuse mis-resolve. Glob once, reuse the result: `d=$(ls -d skills/*"${n#wk-}" | head -1)`.
- Treat a zero-match grep whose emptiness is load-bearing as **unverified until the path is confirmed to exist** — a mis-resolved path reads identical to a genuine gap and inverts the `already-covered` call. Never trust a missing-path warning; grep tools vary in emitting one.
- Read the entire `SKILL.md`, not just the target section.
- Build a mental map of:
  - Hard rules
  - Phase / step coverage
  - Recurring themes
  - Tool usage patterns
- Partial reads do not satisfy the edit guard. Re-read narrow ranges when needed.

## Step 3: Distill the Lesson

- Transform the incident into a generalizable principle.
- Ask:
  - What behavior needs to change?
  - What check or mechanism was missing?
  - What failure mode should the agent anticipate?

### HARD RULE: prohibited-subject gate — scan subject before drafting

- Grep the source learning/memory's core subject term against `.skillprohibit` and shape-matching hooks (`check-relative-paths`) at distill time, before byte-budget or draft.
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
- Escalate by exactly one notch:
  1. baseline prose rule
  2. `**Important:**`
  3. `**Very important:**`
  4. `**CRITICAL:**`
  5. `**HIGH-PRIORITY:**`
  6. `**HIGHER-PRIORITY:**`
  7. `**VERY-HIGH-PRIORITY:**`
  8. restructure the section so the rule is structurally impossible to skip
- Record the bump in the reference file.
- Treat an escalation as a principle edit and bump `metadata.version`.

### Classify: principle vs one-off

- `principle` — the failure mode generalizes. Route to `SKILL.md` plus a reference file.
- `one-off` — the scenario is narrow, repo-specific, or unlikely to recur. Route to a reference file only.
- Enumerated tests for either class (consult when the class is not obvious): [`references/classify-criteria.md`](references/classify-criteria.md).
- Record the classification in the run report and in the reference file frontmatter.
- When ambiguous, ask once.

## Step 4: Draft the Skill Update

- Skip Step 4 for `one-off` lessons.
- Locate the edit target:
  - New step
  - Missing check
  - Wrong instruction
  - New HARD RULE
- Format the update as instructions, not narrative — heading, then what to do (imperative), why it matters, how (commands or checks).

## Step 5: Audit the Full Skill

- Re-read the entire skill with the proposed edit mentally applied.
- Check for:
  - Overlap
  - Contradiction
  - Redundant tool usage
  - Bloated sections
  - Stale references
  - Orphaned label artifacts
- Merge overlapping instructions.
- Resolve contradictions.
- Consolidate repeated API calls or CLI commands.
- Remove dead labels; revert any uncommitted edit to the target not made this run that doesn't address the lesson (prior partial fold may encode a wrong model).
- Bundle cleanup into the same change.

### Mechanical overfit scan

- Before presenting the diff, grep the proposed edit text against these categories:
  - Reviewer / bot logins
  - Organization prefixes
  - Employer / internal project names
  - Specific ticket IDs
  - Specific repo / file / package names
  - Line numbers / SHAs / PR numbers
  - Specific tool versions
  - Concrete person names
  - Hardcoded branch names
- Replace each match with a generic mechanism or placeholder.
- Parameterize real paths instead of dropping them.
- Justify inline only when the literal token is required.
- Apply replacement maps longest-first.
- Reject ticket-shaped example tokens. Grep case-sensitive (never `-i` — it widens to `Word-Number` noise (`Step-5`)) against `[A-Z][A-Z0-9]+-\d+`; any match — even an invented placeholder — trips the `check-ticket-refs` hook, which matches shape, not provenance. Replace with `<child-key>`/`<KEY>` or the repo's `BOARD-NUM` form.
- When the user calls out an overfit, audit the whole cohort for the same pattern.
- **CRITICAL — run the owning hook scripts against the staged index; never reimplement their matcher.** A hook's pattern file is not portable across matchers: it carries `#` comments and matcher-specific constructs (PCRE `(?i)` inline flags) that a hand-rolled `grep -iEf` turns into false noise (`#` matches every markdown heading) or a false-clean. Run every hook after staging → real gate semantics, no synthetic probe:

  ```bash
  for h in .githooks/check-*.sh .githooks/scrub-staged.sh; do "$h" || echo "FAIL: $h"; done
  ```

- Hand-roll only what no hook covers: **staged path strings** — content hooks grep the diff and commit msg, never filenames, so a slug/filename term ships clean. Scan per-file, never a bare multi-line list (a stricter `grep` alias false-cleans one bad path; a `No such file` warning is a scan failure, not clean):

  ```bash
  git diff --cached --name-only | grep -iEf .skillprohibit
  ```

  Anonymize every hit. Pick a generic slug for a prohibited-subject lesson up front; never derive it from the subject. Scrub staged `.learned.md`/retro archives too — a rename commits them publicly, and a term-handling learning's example IS the term.
- Treat a hand-rolled NONE as **unverified**: prove the grep fires with a literal expanded from a real **non-comment, non-blank** denylist line (`a[-_]?b` → `a-b`), never a guess or a comment line — a comment line is itself a valid regex matching its own text, so the probe "fires" while proving nothing.

## Step 6: Present for Review

- Show the user: distilled principle, edit location, proposed diff, cleanup found during audit.
- A direct `/wk-sharpen` invocation (and auto mode) IS the approval — apply/commit/push without re-asking; the show-list is a report, not a gate. Ask explicitly only for ambiguous `wk-learn`-vs-`wk-sharpen` routing or a destructive/irreversible action.

## Step 7: Apply the Update

- Edit `skills/{skill-name}/SKILL.md` and every audit cleanup item.
- Verify each new or edited section follows the style rules.
- Bump `metadata.version` to a fresh CalVer.
- Re-read the final file end-to-end.

### Write distilled references to `skills/{name}/references/`

- Create the directory if missing.
- Write one short reference file per learning.
- Frontmatter:
  - `class: principle` or `class: one-off`
- `principle` files:
  - **Rule**
  - **Why**
  - **Where**
- `one-off` files:
  - **Scenario**
  - **Symptom**
  - **Fix**
  - **Why not promoted**
- Do not link references from `SKILL.md`.
- Run the overfit scan on reference files too.

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
- README counts of any set whose size changed — recount from source, never increment.
- Cross-references still resolve.
- Examples reflect the post-edit behavior.
- Fix every drift item in the same pass.

## Step 7.5: De-bloat Pass (concision gate)

### HARD RULE: de-bloat every run — never let prose accrete

- Run on **every** sharpening, not only when a learning prompts it. Bloat is the cumulative default of additive edits.
- **Bulletize, do not compress prose.** One rule per line, imperative voice, `→` for causality, drop articles/connectives in procedural text.
- Remove redundancy, dead labels, explanatory filler. State a rule once; cross-reference instead of restating.
- **Preserve every rule, failure mode, and command.** Reject any edit that drops a HARD RULE, error code, or failure-mode explanation.
- Re-run the Drift check after de-bloat edits land.

### HARD RULE: hard size ceilings per `SKILL.md`

- `.githooks/check-skill-size.sh` blocks commits over any of (each env-tunable):
  - **Body** (everything after the front-matter) ≤ **24576 bytes** (`SKILL_SIZE_MAX_BYTES`)
  - **Front-matter** block ≤ **8192 bytes** (`SKILL_FRONTMATTER_MAX_BYTES`)
  - **`description:`** field ≤ **1024 bytes** (`SKILL_DESC_MAX_BYTES`)
  - **`allowed-tools:`** ≤ **36 lines** (`SKILL_TOOLS_MAX_LINES`)
- Keep skills under the ceilings proactively — never rely on the hook as the only guard. When a skill exceeds (or the edit would push it over) a ceiling, before finishing: bulletize/refactor for concision, split content into `references/` or a sub-skill, tighten the description, or narrow the tool list.
- **Prefer content-removing structural moves over prose-mangling to reclaim bytes** (zero coverage risk): relocate narrow, tool-specific catalog rows to a `references/` file and update the pointer's ID list — route a **new** such row straight there (ID only inline), never place-inline-then-reclaim; delete scaffolding or a provably-duplicated rule outright.
- **Measure the staged body BEFORE drafting any content-adding fold** — unconditional, not gated on "looks tight"; the at-ceiling state is invisible until measured. Headroom under ~2× the edit → budget ≥2 reclaim targets up front whose *combined NET* exceeds the edit by ≥1.2×; net change must be non-positive on the first pass.
  - **CRITICAL — state the budget as arithmetic before applying any edit:** byte-measure the addition and each reclaim's NET; write the numbers down.
  - **Very important — stage addition + reclaim cuts together, then measure exactly once**, running the hook's `measure()` verbatim after `git add` — never the working tree. A second measure-and-trim cycle is the re-violation signal → re-plan with one decisive structural cut. Mechanics: [`references/byte-budget.md`](references/byte-budget.md).

## Step 8: Verify and Commit (terminal gate)

Do not return control until all five pass:

1. **Install:** `cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -5` — success = `Done!` or `Installed <N> skills` (accept either marker). Prefix the explicit `cd`; the Bash cwd persists across calls, so a `cd` from an earlier step can leave a `.`-relative install in the wrong dir ("No valid skills found").
2. **Suite:** fold edited an executable artifact the skill ships (hook, script, binary — not `SKILL.md`/`README.md`/`references/`) → locate and run that skill's own test suite before committing; a shipped-code edit must never reach the commit gate unrun. Red result → apply the Step 1 harness-defect rule.
3. **Commit:** stage only the paths this run touched — edited `SKILL.md`/`README.md`/`references/`, version bumps, and the specific learning/retro files this run processed and renamed to `.learned.md`. Use `wk-commit` conventional format with classifier emojis.
   - Never blanket `git add -A` — the working tree routinely carries *unprocessed* inbox files (`learnings/`, `retrospect/`) from other sessions, and `-A` bundles them into this commit. Add processed paths explicitly. If `-A` is unavoidable, `git reset` every `learnings/`/`retrospect/` path this run did not process before committing.
   - Re-check the index after any hook-blocked commit.
   - **Untracked skill dir from another session blocks `check-readme-index`** — the hook scans the whole `skills/` tree on disk, not staged paths. Don't `git add` or index another session's incomplete skill: move it aside (`mv skills/<name> /tmp/agent/...`), land the scoped commit, push, then restore it untouched.
   - Rename `.learned.md` with `mv`, not `git mv` — a freshly materialized learning is untracked, so `git mv` aborts (`fatal: not under version control`). Then `git add` the new path.
   - On signing failure, stop — don't re-run install/scan or re-stage; ask the user for an interactive signer unlock. A listed agent key (`ssh-add -l` ok) ≠ signing capability; only a completed signed commit proves it. On the next run the staged fold is resumable, not done — retry the gate; never re-distill.
4. **Push once:** after all commits exist, push a single time.
5. **Clean tree:** no modified tracked path in `git status --short` — untracked *unprocessed* learnings/retros are expected state, never debris to delete.

Report: one line per skill updated, then confirm tree clean, installed, pushed.

## Quick Reference

| Trigger | Behavior |
|---|---|
| `/wk-sharpen pr-review incident.md` | Read incident, distill lesson, audit full skill, propose update |
| `/wk-sharpen commit "agent skipped signing"` | Distill verbal report, audit, propose skill improvement |
| `/wk-sharpen` (no args) | Batch mode — scan learnings + memories + retrospects, distill all |
| `/wk-sharpen --scan --force` | Batch mode — reprocess everything, ignore log |
| `/wk-sharpen improve [scope]` | Improve mode — refactor and prune accumulated entropy |

## Batch Mode: Scan Learnings, Memories, and Retrospects

Invoked without a specific incident → batch mode.

### Source 1: Global learnings inbox

- Mirror unprocessed learnings from `$HOME/.claude/skills/learnings/` into the repo tree before distilling.
- Skip the source if the directory does not exist.
- For each `*.md` under the inbox:
  - Resolve destination as `$WK_SKILLS_HOME/learnings/skills/<relative-path>`.
  - Skip if the destination already exists.
  - Copy the file, then delete the inbox original.
- Fall through to Source 2.

### Source 2: Repo learnings directory

- Scan `$WK_SKILLS_HOME/learnings/skills/` for unprocessed files.
- Process every unprocessed learning one-by-one, severity-ordered: read it, run the sharpen workflow, confirm the distilled principle landed, then rename to `.learned.md`.
- Re-scan after each fold-commit, not only at start — concurrent sessions write the tree continuously. Treat "inbox drained" as a terminal check run after the last commit, never a fact set up-front.

### Source 3: Global memory files

- Scan `$HOME/.claude/memory/` for memory files.
- Process `feedback` memories; process `user` / `project` only when they carry explicit instructions on how a skill should behave.
- Determine which skill the feedback applies to.
- Materialize each matched memory as a learning via `wk-learn`, then distill it through the Source 2 path.
- **Gate the listing by parse-as-memory BEFORE diffing the marker.** Require a frontmatter block with a `type:` key — match it at column 0 *or* nested under `metadata:`; a bare `^type:` grep silently drops memories that nest it. Non-memory residents (a hand-maintained index, another skill's append-only archive) are out-of-scope-by-rule, never backlog.
- **Never add a marker entry for a file this run did not process.** The marker records distillation, not suppression — mixing them destroys any way to tell a real completion from a silenced non-memory.
- **Normalize both sides before diffing against the marker.** `comm` does exact string matching; the directory listing and `.distilled-memories` must share one path form. Collapse repeated slashes (`sed 's#//#/#g'`) and `sort -u` both sides first — a trailing-slash glob yields `dir//file.md` and silently mismatches every entry. Treat a result where *every* memory shows un-distilled as a probable format mismatch, not a real backlog — sanity-check before processing. A refused invocation → drop only the blocked element (stage both lists in-repo, or feed a here-string); never swap the comparison primitive, or the substitute's tooling difference reads as real backlog.

### Source 4: Session retrospects

- Scan `$WK_SKILLS_HOME/learnings/retrospect` for unprocessed retrospect files.
- Read each "What could've been better" and any "What worked" bullet that asserts a reusable practice.
- Match each lesson to a skill by name/tool/phase.
- Materialize each matched lesson as a learning via `wk-learn`.
- Distill it through the Source 2 path and rename it to `.learned.md`.
- After every lesson in the file is distilled, rename the retrospect file itself.
- A lesson whose slug already exists is already distilled.

### Tracking processed sources

- **Learnings (Source 1 & 2):** processed state is the `.learned.md` rename.
- **Retrospects (Source 4):** same as learnings.
- **Memories (Source 3):** tracked by a gitignored marker at `$WK_SKILLS_HOME/.distilled-memories`.
- Reprocess on change.

### Batch mode presentation

- Before processing, present counts: learnings, memories, retrospects, processing.
- After processing, report: skills updated, learnings absorbed, memories distilled, skipped items.

## Improve Mode: Refactor and Optimize

`/wk-sharpen improve [scope]` → suite-level cleanup, not incident-specific fixes. Scope is omitted / `all`, `<skill-name>`, or a glob. Procedure — inventory, audit targets, leverage ranking, Phase A–D proposals, apply: [`references/improve-mode.md`](references/improve-mode.md).

### Hard rules for improve mode

- **No information loss.** Remove a rule only if it is provably duplicated elsewhere or superseded by a stricter rule.
- **Phased approval required.** Auto mode does not short-circuit this.
- **Capture insights.** External research surfacing a useful pattern → add it to the overfit-categories table or as a new `wk-sharpen` rule.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn sharpen`).