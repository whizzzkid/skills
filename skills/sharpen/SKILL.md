---
name: wk:sharpen
description: >-
  Improve a skill based on field reports or incident retrospectives. Extracts
  generalizable principles from specific failures without overfitting on
  examples. Use when updating skills after agent runs surfaced gaps, errors, or
  behavioral issues. Prevents embedding specific file names, line numbers, or
  project details into skill instructions.
argument-hint: '[skill-name] [incident-file or description]'
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - "Bash(mkdir -p:*)"
model: opus
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.1.0'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Sharpen

Improve a skill based on field reports without overfitting on specific examples.
Extracts the **principle** behind a failure and updates the skill to prevent the
behavior, not just the specific instance.

## When to Use

- Another agent ran a skill and encountered errors or gaps
- A field report describes what went wrong during skill execution
- A retrospective identifies a behavioral pattern worth preventing
- You're about to edit a skill based on a specific incident

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

The anti-pattern embeds the incident's specific files and line numbers. The
correct pattern teaches the **mechanism** and **failure mode** without
naming the specific occurrence.

## Step 1: Read the Incident Report

If given a file path, read it. If given a verbal description, internalize it.

Extract:
- What the agent was supposed to do
- What went wrong (error, unexpected behavior, user correction)
- What specific artifacts failed (file names, line numbers, API responses)
- Root cause (why it failed)

## Step 2: Read the Full Skill

Determine which skill needs updating. If ambiguous, ask the user.

**Read the entire skill file** — not just the section you plan to edit.
You need the full picture to avoid introducing overlaps or contradictions.

```bash
cat skills/{skill-name}/SKILL.md
```

As you read, build a mental map of:
- Every hard rule and where it's stated
- Every phase/step and what it covers
- Recurring themes or instructions that appear in multiple places
- Tool usage patterns (API calls, CLI commands, query formats)

This map is essential for Step 4 (drafting) and Step 5 (audit).

## Step 3: Distill the Lesson

Transform the incident into a **generalizable principle**.

Ask:
- What **behavior** needs to change?
- What **check** or **mechanism** was missing?
- What **failure mode** should the agent anticipate going forward?

Remove:
- Specific file names (e.g., `trust-boundaries.md` → "the file")
- Specific line numbers (e.g., `line 232` → "the target line")
- Project-specific context (e.g., `PB3 anchor` → "the referenced anchor")
- Names of reviewers, PRs, or commits

Keep:
- Error codes and messages (e.g., `422 "Line could not be resolved"`)
- API behavior (e.g., "REST API rejects PENDING")
- Structural patterns (e.g., "lines not in the diff")

## Step 4: Draft the Skill Update

Locate where in the skill the lesson belongs:
- **New step?** Add a new heading in the relevant phase.
- **Missing check?** Insert a validation step before the problematic action.
- **Wrong instruction?** Edit the existing text to correct the behavior.
- **New rule?** Add a "HARD RULE:" block if it's a must-never-break constraint.

**Format the update as instructions, not narrative:**

```markdown
### [Step name]

[What to do, in imperative voice]

[Why this matters — the failure mode it prevents]

[How to do it — concrete commands or checks]
```

## Step 5: Audit the Full Skill

**Before presenting changes**, re-read the entire skill with your
proposed edit mentally applied. Check for:

**Overlapping instructions:** Two sections that teach the same behavior
in different words. Merge them — keep the clearer version, delete the
other. If they're in different phases, keep the one closest to where the
agent needs it.

**Contradictory rules:** An edit in one section that conflicts with an
existing rule elsewhere. Resolve the conflict — update or remove the
stale instruction.

**Redundant tool usage:** The same API call or CLI command shown in
multiple places with slightly different flags or jq filters. Consolidate
to one canonical form, or extract to a shared pattern referenced by name.

**Bloated sections:** Steps that have grown beyond what the executing
agent needs. If a section has more than 3-4 paragraphs of prose for a
single action, tighten it. Instructions should be imperative and
scannable — not essays.

**Stale references:** Sections that reference steps, phases, or
variables that have been renamed or removed in prior edits.

If the audit surfaces cleanup beyond your original edit, bundle the
cleanup into the same change. Do not leave known debt for a future pass.

## Step 6: Present for Review

Show the user:
1. The distilled principle (what you learned)
2. The specific edit location (which phase/section)
3. The proposed diff
4. **Any cleanup found during audit** — list what you consolidated,
   removed, or tightened and why

Wait for approval before editing the skill file.

## Step 7: Apply the Update

After approval:
- Edit the skill file — both the new content and any audit cleanup
- Re-read the final file to confirm coherence
- Bump the `metadata.version` (patch for fixes, minor for new steps)
- Commit with a message describing the improvement

## Anti-Patterns to Avoid

| Anti-pattern | Why it's wrong | Correct approach |
|--------------|----------------|------------------|
| Embedding specific file names | Teaches one case, not the pattern | Describe the type of file or the check |
| Referencing specific line numbers | Meaningless to future users | Describe the line's role or position |
| Copying error descriptions verbatim | May include incident-specific context | Extract the error code and failure mode |
| Adding "if file is X, do Y" | Overfits on one repo | Add a general rule that covers all repos |

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

The good version teaches **what to check** and **why** without naming the
specific incident.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk:sharpen pr-review incident.md` | Read incident, distill lesson, audit full skill, propose update |
| `/wk:sharpen commit "agent skipped signing"` | Distill verbal report, audit, propose skill improvement |

**Steps:** Read report → Read full skill → Distill lesson → Draft edit →
Audit full skill for overlap/bloat → Present with cleanup → Apply

## Requirements

- Read access to the skill file being improved
- Edit access to `skills/{skill-name}/SKILL.md`

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/sharpen"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/sharpen/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:sharpen
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `sharpen/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
