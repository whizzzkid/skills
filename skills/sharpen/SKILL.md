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
  version: '2026.07.23-193552'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Sharpen

Improve and de-bloat skills from field reports or incident retrospectives.
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
- If a high-severity learning is `already-covered`, cite the exact existing lines that
  prove full coverage and escalate the rule one notch.
- Treat unrecognized log actions as `unverified` and re-audit.
- When in doubt, ask before renaming.

## Step 1: Read the Incident Report

- Read the file path if given; otherwise internalize the verbal description.
- Extract:
  - What the agent was supposed to do
  - What went wrong
  - Which artifacts failed
  - Root cause

## Step 2: Read the Full Skill

- Determine which skill needs updating. Grep the learning's core subject across all of `skills/`; the defect's text may live in a skill other than the one filed — fold the principle into the API-mechanics home AND correct every over-general instance elsewhere in the same pass. If ambiguous, ask the user.
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
- Classify as `principle` when any of these are true:
  - The pattern appears in ≥ 2 prior learnings, memories, or `.learned.md` archives.
  - The failure mode would surface on every invocation that touches the affected step.
  - The fix is expressible in one bullet without naming specific tools, versions, or repos.
- Classify as `one-off` when any of these are true:
  - The fix requires a verbatim recipe that only works for one tool version or repo layout.
  - The failure mode only fires under a rare configuration.
  - The user described it as a corner case or one-time workaround.
  - Distilling the principle leaves nothing actionable that is not already covered.
- Record the classification in the run report and in the reference file frontmatter.
- When ambiguous, ask once.

## Step 4: Draft the Skill Update

- Skip Step 4 for `one-off` lessons.
- For `principle` lessons, continue.
- Locate the edit target:
  - New step
  - Missing check
  - Wrong instruction
  - New HARD RULE
- Format the update as instructions, not narrative:

```markdown
### [Step name]

[What to do, in imperative voice]

[Why this matters — the failure mode it prevents]

[How to do it — concrete commands or checks]
```

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
- Tighten sections that run past four bullets.
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
- **Important — scrub staged `.learned.md`/retro archives too** (they trip `scrub-staged.sh`'s employer/org denylist, a hook SEPARATE from `check-prohibited` — run it too) — a rename commits them publicly. A term-handling learning's example IS the term; scrub it.
- Grep every staged file against the repo's authoritative term lists. Scan file **contents AND staged path strings** — `check-prohibited` greps content + commit msg, never filenames, so a slug/filename term ships clean. Scan per-file (NUL-delimited), never a bare multi-line `$files` — a stricter `grep` alias false-cleans one bad path; a `No such file` warning is a scan failure, not clean:

  ```bash
  git diff --cached --name-only -z | xargs -0 grep -iEnHf .skillprohibit
  git diff --cached --name-only | grep -iEf .skillprohibit
  ```

  Anonymize every hit. Pick a generic slug for a prohibited-subject lesson up front; never derive it from the subject.
- Treat a NONE result as **unverified, not proof-of-clean**. A real hit in the staged scan IS the proof — skip the synthetic probe when the scan already matched. For a genuine NONE, prove grep fires with a token copied from a real `.skillprohibit` line (expand a regex: `a[-_]?b` → `a-b`), never a guess — a guess misses the local list. The `check-prohibited` hook is the backstop — relying on it costs a failed-commit cycle.

## Step 6: Present for Review

- Show the user: distilled principle, edit location, proposed diff, cleanup found during audit.
- A direct `/wk-sharpen` invocation (and auto mode) IS the approval — apply/commit/push without re-asking; the show-list is a report, not a gate. Ask explicitly only for ambiguous `wk-learn`-vs-`wk-sharpen` routing or a destructive/irreversible action.

## Step 7: Apply the Update

- Edit `skills/{skill-name}/SKILL.md` and every audit cleanup item.
- Verify each new or edited section follows the style rules.
- Write distilled context to `skills/{skill-name}/references/`.
- Bump `metadata.version` to a fresh CalVer.
- Re-read the final file end-to-end.
- Commit happens in Step 8.

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
- **Prefer content-removing structural moves over prose-mangling to reclaim bytes** (zero coverage risk): (1) relocate narrow, language/tool-specific catalog rows to a `references/` extended file and update the inline pointer's ID list — and route a **new** such row straight there (add only its ID inline, ~6 B), never place-inline-then-reclaim; (2) delete scaffolding, blank lines, or a provably-duplicated rule — the latter outright with zero replacement (a cross-ref back re-spends the reclaim). Count reclaim NET: a prose-block relocation nets gross MINUS the stub it leaves (heading + pointer + sentence), which dominates a short block — prefer a LARGE block; a row/bullet merge nets ~3 B unless it drops the now-duplicated phrase. Reserve prose for the final margin.
- **Measure the staged body BEFORE drafting any content-adding fold** — unconditional, not gated on "looks tight"; the at-ceiling state is invisible until measured. Headroom under ~2× the edit → pick reclaim target(s) whose *combined NET* reclaim exceeds it with ≥1.2× margin — budget ≥2 reclaims up front (one undershoots a multi-clause rule); net change must be non-positive on the first pass.
  - **Very important — measure exactly once.** Stage the addition AND the reclaim cuts together, then measure ONCE — never eyeball either side (a `→` is 3 B; a prose reclaim misleads as much as an addition). A second measure-and-trim cycle is the re-violation signal — stop and re-plan with one decisive structural cut, not another prose nibble.
  - **Very important — run the hook's `measure()` verbatim; never `wc -c` or an abbreviated awk.** Dropping its `state="pre"` init counts front-matter as body → false, self-consistent over-ceiling headroom. Copy `measure()` from `.githooks/check-skill-size.sh`, `git add` first, run pre-draft and at commit; never the working tree.

## Step 8: Verify and Commit (terminal gate)

Do not return control until all four pass:

1. **Install:** `cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -5` — success = `Done!` or `Installed <N> skills` (accept either marker). Prefix the explicit `cd`; the Bash cwd persists across calls, so a `cd` from an earlier step can leave a `.`-relative install in the wrong dir ("No valid skills found").
2. **Commit:** stage only the paths this run touched — edited `SKILL.md`/`README.md`/`references/`, version bumps, and the specific learning/retro files this run processed and renamed to `.learned.md`. Use `wk-commit` conventional format with classifier emojis.
   - Never blanket `git add -A` — the working tree routinely carries *unprocessed* inbox files (`learnings/`, `retrospect/`) from other sessions, and `-A` bundles them into this commit. Add processed paths explicitly. If `-A` is unavoidable, `git reset` every `learnings/`/`retrospect/` path this run did not process before committing.
   - Re-check the index after any hook-blocked commit.
   - **Untracked skill dir from another session blocks `check-readme-index`** — the hook scans the whole `skills/` tree on disk, not staged paths. Don't `git add` or index another session's incomplete skill: move it aside (`mv skills/<name> /tmp/agent/...`), land the scoped commit, push, then restore it untouched.
   - Rename `.learned.md` with `mv`, not `git mv` — a freshly materialized learning is untracked, so `git mv` aborts (`fatal: not under version control`). Then `git add` the new path.
   - On signing failure, stop — don't re-run install/scan or re-stage; ask the user for an interactive signer unlock. A listed agent key (`ssh-add -l` ok) ≠ signing capability; only a completed signed commit proves it. On the next run the staged fold is resumable, not done — retry the gate; never re-distill.
3. **Push once:** after all commits exist, push a single time.
4. **Clean tree:** `git status --short` must be empty.

Report: one line per skill updated, then confirm tree clean, installed, pushed.

## Quick Reference

| Trigger | Behavior |
|---|---|
| `/wk-sharpen pr-review incident.md` | Read incident, distill lesson, audit full skill, propose update |
| `/wk-sharpen commit "agent skipped signing"` | Distill verbal report, audit, propose skill improvement |
| `/wk-sharpen` (no args) | Batch mode — scan learnings + memories + retrospects, distill all |
| `/wk-sharpen --scan --force` | Batch mode — reprocess everything, ignore log |
| `/wk-sharpen improve [scope]` | Improve mode — refactor and prune accumulated entropy |

**Single mode:** Read report → Read full skill → Distill → Classify → Draft → Audit → Present → Apply → Verify & commit

**Batch mode:** Scan learnings + memories + retrospects → Filter → Materialize each
memory/retro lesson as a learning via `wk-learn` → Process each via single mode →
Rename learnings **and retros** to `.learned.md` → Update the memory marker

**Improve mode:** Inventory scope → Parallel audit → Consolidate findings → Phased
proposal (user approval per phase) → Apply → Verify & commit

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
- Only process memories of type `feedback`.
- Read each file's frontmatter.
- Determine which skill the feedback applies to.
- Materialize each matched memory as a learning via `wk-learn`.
- Distill that new learning through the Source 2 path.
- Only process `user` or `project` type memories if they contain explicit instructions about how a skill should behave.
- **Normalize both sides before diffing against the marker.** `comm` does exact string matching; the directory listing and `.distilled-memories` must share one path form. Collapse repeated slashes (`sed 's#//#/#g'`) and `sort -u` both sides first — a trailing-slash glob yields `dir//file.md` and silently mismatches every entry. Treat a result where *every* memory shows un-distilled as a probable format mismatch, not a real backlog — sanity-check before processing.

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
- Force reprocessing on `/wk-sharpen --scan --force`.

### Batch mode presentation

- Present a summary before processing:
  - Learnings count
  - Memories count
  - Retrospects count
  - Processing count
- After processing, report:
  - Skills updated
  - Learnings absorbed
  - Memories distilled
  - Skipped items

## Improve Mode: Refactor and Optimize

`/wk-sharpen improve [scope]` → suite-level cleanup, not incident-specific fixes.

- Set `[scope]` to omitted / `all`, `<skill-name>`, or a glob pattern.
- Inventory every skill in scope.
- Build a per-skill map of hard rules, phases/steps, recurring sections, and cross-skill references.
- Audit for:
  - duplicate or overlapping instructions
  - overfit residue
  - bloated sections
  - cross-skill duplication
  - stale or contradictory references
  - missing structure
- Optionally research best-practice patterns that survive overfit scrutiny.
- Consolidate findings by skill and cross-cutting theme.
- Rank by leverage:
  - **High** — clear win with no information loss
  - **Low** — nitpick or style preference
- Present phased proposals for suite-scale changes.
  - **Phase A** — extract shared boilerplate to referenced fragments
  - **Phase B** — per-skill deduplication and bloat trimming
  - **Phase C** — cross-skill consolidation
  - **Phase D** — apply external best-practice insights that survived review
- Wait for explicit user approval per phase.
- Apply approved edits with the single-mode audit.
- Bump each skill's `metadata.version`.
- Commit per skill or phase, then push once at the end.

### Hard rules for improve mode

- **No information loss.** Remove a rule only if it is provably duplicated elsewhere or superseded by a stricter rule.
- **Phased approval required.** Auto mode does not short-circuit this.
- **Cohort overfit scan applies.** Every proposed edit goes through the mechanical overfit scan.
- **Capture insights.** When external research surfaces a useful pattern, add it to the
  overfit-categories table or as a new rule in `wk-sharpen`.

## Requirements

- Read the skill being improved; edit `skills/{skill-name}/SKILL.md`.
- Read `$HOME/.claude/memory/` (batch mode); read/write/delete `$HOME/.claude/skills/learnings/`.
- Read/write `$WK_SKILLS_HOME/{learnings,learnings/retrospect,.distilled-memories}`.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn sharpen`).