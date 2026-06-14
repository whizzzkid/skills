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
  version: '2026.06.14-095327'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Sharpen

Improve and de-bloat skills based on field reports or incident retrospectives.
Extracts the **principle** behind a failure and updates the skill to prevent the
behavior, not just the specific instance.

## When to Use

- Another agent ran a skill and hit an error or gap
- A field report describes what went wrong during skill execution
- A retrospective identifies a behavioral pattern worth preventing
- You're about to edit a skill based on a specific incident
- A skill needs simplification or bloat reduction without losing critical rules

### HARD RULE: invocation routing — `wk-learn` vs `wk-sharpen`

`wk-sharpen` rewrites `SKILL.md` files. `wk-learn` only writes to
`learnings/`. Direct skill edits without explicit user consent are out of scope.

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

**Anti-pattern:**

```markdown
### Validate line numbers

Lines 232 and 60 in trust-boundaries.md and model.md must be checked
against the diff. If the PB3 anchor is broken, skip the comment.
```

**Correct pattern:**

```markdown
### Validate line numbers

Every inline comment must target a line that exists in the diff. Lines
not in the diff will cause a 422 error from the GitHub API.
```

- Remove specific file names, line numbers, project context, and reviewer / commit names.
- Keep error codes, API behavior, and structural patterns.

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

- Determine which skill needs updating. If ambiguous, ask the user.
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
- Remove specifics; keep mechanisms.

### HARD RULE: full-read before `already-covered`

- Mark a learning `already-covered` only after reading the full file and matching every rule / bullet.
- Match at the rule level, not the topic level.
- If any rule is missing, classify as `partial` and distill the missing part.
- Cite exact existing lines that prove coverage.

### HARD RULE: re-violation escalation — `already-covered` is NOT "done"

- A fresh learning that repeats an existing rule proves the rule is not steering.
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
- Remove dead labels left by earlier edits.
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
- When the user calls out an overfit, audit the whole cohort for the same pattern.

## Step 6: Present for Review

- Show the user:
  1. Distilled principle
  2. Edit location
  3. Proposed diff
  4. Cleanup found during audit
- Wait for approval before editing.

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

- Update `skills/{skill-name}/README.md` when a step, phase, trigger, or argument shape changed.
- Update any Mermaid diagram to match the new flow.
- Bump the README version to the same CalVer as `metadata.version`.
- When first adding the Version line to an existing README, pre-convert bare `wk-*` mentions to relative links.
- Update both index files when the one-line description changes.
- Invoke `wk-docs` when the edit changes cross-skill behavior or documented workflow.
- Stage doc edits with the SKILL.md change.

### Drift check

- Frontmatter `description` still matches the behavior.
- `argument-hint` matches the current argument shape.
- `allowed-tools` lists every tool the new edits reference.
- Quick-reference table, Trigger table, and Step list match the body.
- Cross-references still resolve.
- Examples reflect the post-edit behavior.
- Fix every drift item in the same pass.

## Step 7.5: De-bloat Pass (concision gate)

- Search for simplification opportunities before and after the functional edit.
- Convert dense paragraphs to structured nested bullets when the rule remains complete and actionable.
- Remove redundancy, dead labels, and explanatory filler.
- Preserve every rule, failure mode, and command.
- Reject edits that drop a HARD RULE, error code, or failure-mode explanation.
- Re-run the Drift check after de-bloat edits land.
- Keep the final `SKILL.md` as short as possible without losing coverage.

## Step 8: Verify and Commit (terminal gate)

Do not return control until all four checks pass:

1. **Install:** `npx skills add . -g -y -a=claude 2>&1 | tail -5` from the repo root — must print `Done!`.
2. **Commit:** every dirty file in a commit. Use `wk-commit` conventional format with classifier emojis.
   - Re-check the index after any hook-blocked commit.
   - When authoring a new sibling `README.md`, write every `wk-*` mention as a relative link.
   - Stage a `.learned.md` rename by adding only the new `.learned.md` path.
3. **Push once:** after all commits exist, push a single time.
4. **Clean tree:** `git status --short` must be empty.

Report: one line per skill updated, then confirm tree clean, installed, pushed.

## Anti-Patterns to Avoid

| Anti-pattern | Correct approach |
|---|---|
| Embedding specific file names | Describe the type of file or the check |
| Referencing specific line numbers | Describe the line's role or position |
| Copying error descriptions verbatim | Extract the error code and failure mode |
| Adding "if file is X, do Y" | Add a general rule that covers all repos |

## Example: Good vs Bad

### Bad (overfitted)

```markdown
## Phase 5: Review Comments

Check lines 232 and 60 in trust-boundaries.md and model.md. If the
PB3 anchor is broken, skip commenting on those lines.
```

### Good (principle-focused)

```markdown
## Phase 5: Review Comments

### Validate comment positions

Parse the diff to confirm each proposed comment's target line exists
in a hunk. Lines not in the diff will cause a 422 error from the API.
If a line is missing, move the comment to a nearby valid line or the
review body.
```

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

When invoked without a specific incident, sharpen enters batch mode.

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
- For each unprocessed learning:
  1. Read the file.
  2. Run the normal sharpen workflow using the learning as input.
  3. Rename to `.learned.md`.
- Process every unprocessed learning.
- Order by severity.
- Walk learnings one-by-one.
- Confirm the distilled principle is encoded before renaming.

### Source 3: Global memory files

- Scan `$HOME/.claude/memory/` for memory files that contain skill-applicable feedback or corrections.
- Only process memories of type `feedback`.
- Read each file's frontmatter.
- Determine which skill the feedback applies to.
- Materialize each matched memory as a learning via `wk-learn`.
- Distill that new learning through the Source 2 path.
- Log the memory file as `distilled`.
- Only process `user` or `project` type memories if they contain explicit instructions about how a skill should behave.

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

Use `/wk-sharpen improve [scope]` for suite-level cleanup, not incident-specific fixes.

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

---

## Requirements

- Read access to the skill file being improved
- Edit access to `skills/{skill-name}/SKILL.md`
- Read access to `$HOME/.claude/memory/` (for batch mode)
- Read/write/delete access to `$HOME/.claude/skills/learnings/`
- Read/write access to `$WK_SKILLS_HOME/learnings/`
- Read/write access to `$WK_SKILLS_HOME/.distilled-memories`
- Read/write access to `$WK_SKILLS_HOME/learnings/retrospect`

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn sharpen`).