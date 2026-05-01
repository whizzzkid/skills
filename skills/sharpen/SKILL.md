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
  version: '2026.05.01-073751'
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

### Mechanical overfit scan (HARD RULE)

Before Step 6 presents the diff, run a checklist-driven grep
against the **proposed edit text** — not against memory or intent.
"Does this look overfitted?" answered by the same brain that just
wrote the overfit defaults to "looks fine to me." A categorical
scan converts the audit from vibes-level to code-level.

For every category below, grep the proposed addition. Each match
must either be replaced with a generic mechanism / placeholder
**or** explicitly justified inline.

| Category | Patterns / signals | Replace with |
|----------|--------------------|--------------|
| Reviewer / bot logins | `[bot]`, `@[a-z0-9_-]+`, named automation, "bots like X" | `{reviewer}`, "review-automation bots that <mechanism>" |
| Organization prefixes | known org tokens, `<org>-managed`, `<org>-*-default` runner names | "an organization-managed runner group", "an org allowlist" |
| Specific ticket IDs | `[A-Z]+-\d+` outside placeholder examples | `[BOARD-NUM]` or remove |
| Specific repo / file / package names | concrete project names that don't generalize | "the file", "the repo", "the package" |
| Line numbers / SHAs / PR numbers | `:\d+`, short SHAs, `#\d+` outside template slots | "the target line", "the commit", "the PR" |
| Specific tool versions | exact versions cited when the failure pattern is version-agnostic | "a version that introduces <change>" |
| Concrete person names | reviewer / committer names | "the reviewer", "the author" |

For each grep match in the proposed text:

- **Replace** with the generic mechanism / placeholder — describe
  the *behavior* (what makes the case match the rule) instead of
  the *identity* (what the case is called).
- **Justify inline** only when the literal token is required —
  stable API names like `PRRT_*`, verbatim error messages from an
  API (`422 "Line could not be resolved"`), framework-defined env
  vars (`CLAUDE_PROJECT_DIR`), or explicitly placeholder strings
  in `{like-this}` or `<like-this>` form.

**Cohort check.** When the user calls out an overfit on a recent
edit, treat it as a signal that other recent edits likely carry
the same class of overfit. Audit every sharpen edit made in the
current session (and the last few in `.distilled-sources.log`)
for the same pattern before considering the issue closed —
overfits travel in cohorts because the source learnings often
cite the same incident's tokens.

The category list lives in this skill and grows as new categories
surface. When a new overfit type bites, add a row.

## Step 6: Present for Review

Show the user:
1. The distilled principle (what you learned)
2. The specific edit location (which phase/section)
3. The proposed diff
4. **Any cleanup found during audit** — list what you consolidated,
   removed, or tightened and why

Wait for approval before editing the skill file.

## Step 7: Apply the Update

After approval, edit the files:

1. Edit the skill file — both the new content and any audit cleanup
2. Re-read the final file to confirm coherence
3. Bump the `metadata.version` (patch for fixes, minor for new steps)

Step 7 is **edits only**. Committing happens in Step 8 — do not commit
inside Step 7 and call the run done.

## Step 8: Verify and Commit (terminal gate)

The run is not complete until this step finishes. Do not return control
to the user with a dirty working tree, an uninstalled skill, or an
unpushed commit.

### Run the install verifier

The repo's post-change hook is hand-run, not automated. Confirm it
succeeded before declaring victory:

```bash
test -d ./skills || cd "$(git rev-parse --show-toplevel)"
npx skills add . -g -y -a=claude 2>&1 | tail -5
```

Read the output. `Done!` means the install succeeded. `No skills found`
or any non-zero exit means the cwd was wrong or the install failed —
re-run from the repo root and do not proceed until you see `Done!`.
Treat silent success patterns as a hard failure that requires retry.

### Commit and push

```bash
git status --short
```

Every dirty file must end up in a commit before the run completes. In
batch mode, group by logical change (one commit per skill updated, plus
one chore commit for `.learned.md` renames + `.distilled-sources.log`
update). Use `wk:commit`'s conventional format with classifier emojis
(🦾 agentic-tool strengthening, 🛡️ guardrails, 🔧 config tuning) where
applicable.

Push immediately after each commit unless the user has said otherwise.

### Final clean-tree check

```bash
git status --short
```

The output must be empty. If anything remains uncommitted, decide
whether to commit it or stash it — do not leave debt for "later." A
non-empty `git status` at the end of a sharpen run is a violation of
this gate.

### Report

Tell the user, in one line per skill: which skill was updated, the
new version, and the principle distilled. Then confirm: tree clean,
skills installed, commits pushed. Silence after edits is a violation
of this gate.

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
| `/wk:sharpen` (no args) | Batch mode — scan learnings + memories, distill all |
| `/wk:sharpen --scan --force` | Batch mode — reprocess everything, ignore log |
| `/wk:sharpen improve [scope]` | Improve mode — refactor and prune accumulated entropy |

**Single mode:** Read report → Read full skill → Distill → Draft →
Audit for overlap/bloat → Present with cleanup → Apply → Verify & commit

**Batch mode:** Scan learnings + memories → Filter by log → Process each
via single mode → Rename learnings to `.learned.md` → Update log

**Improve mode:** Inventory scope → Parallel audit → Consolidate findings →
Phased proposal (user approval per phase) → Apply → Verify & commit

## Batch Mode: Scan Learnings and Memories

When invoked without a specific incident (e.g., `/wk:sharpen` with no
arguments, or `/wk:sharpen --scan`), sharpen enters batch mode — scanning
two sources for distillable material.

### Source 1: Learnings directory

Scan `$WK_SKILLS_HOME/learnings/skills/` for unprocessed files:

```bash
find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" \
  ! -name "*.learned.md" -type f 2>/dev/null
```

For each unprocessed learning:
1. Read the file — extract skill name, type, severity, suggested fix
2. Run the normal sharpen workflow (Steps 2-7) using the learning as input
3. After the skill is updated, rename to `.learned.md`:
   ```bash
   mv "$file" "${file%.md}.learned.md"
   ```

Process highest-severity learnings first. If more than 5 exist, process
5 and report the rest for the next run.

### Source 2: Global memory files

Scan `~/.claude/memory/` for memory files that contain skill-applicable
feedback or corrections:

```bash
find ~/.claude/memory -name "*.md" -type f 2>/dev/null
```

**Only process memories of type `feedback`.** Read each file's frontmatter
— if `type: feedback`, the memory likely contains a behavioral correction
or confirmed approach that could improve a skill.

For each feedback memory:
1. Check if it's already been processed (see tracking below)
2. Read the content — extract the rule, the "Why" line, and the
   "How to apply" line
3. Determine which skill (if any) the feedback applies to — match by
   topic, tool name, or workflow phase mentioned
4. If a matching skill is found, run the normal sharpen workflow to
   distill the feedback into the skill
5. If no skill matches (the feedback is about general behavior, not a
   specific skill), skip it — global memory already covers general rules

**Only process `user` or `project` type memories if they contain
explicit instructions about how a skill should behave** (e.g., "when
reviewing PRs, always check..." or "the morning brief should...").
Skip memories that are purely informational context.

### Tracking: `.distilled-sources.log`

Maintain a log at `$WK_SKILLS_HOME/.distilled-sources.log` to track
which sources have been processed. This prevents re-reading the same
memory files on every run.

**Format:** one line per processed source, tab-separated:

```
<date>\t<source-path>\t<action>\t<target-skill>
2026-04-21\t~/.claude/memory/feedback_testing.md\tdistilled\twk:workflow
2026-04-21\t~/.claude/memory/user_role.md\tskipped\t—
2026-04-21\tlearnings/skills/pr-review/2026-04-21_stale-diff.md\tdistilled\twk:pr-review
```

**Before processing any source**, check if its path appears in the log.
If it does AND the file's modification time is not newer than the log
entry date, skip it. If the file was modified after the log entry, it
has new content — reprocess it.

```bash
# Create log if it doesn't exist
touch "$WK_SKILLS_HOME/.distilled-sources.log"

# Check if a source was already processed
grep -qF "$source_path" "$WK_SKILLS_HOME/.distilled-sources.log"
```

**After processing**, append an entry to the log.

**Force reprocessing:** If the user explicitly asks to revisit memories
(e.g., `/wk:sharpen --scan --force` or "rescan all memories"), ignore
the log and process everything.

### Batch mode presentation

Present a summary before processing:

> "Scanning for distillable material...
>
> **Learnings:** {N} unprocessed files found
> **Memories:** {M} feedback memories found ({P} new, {Q} already processed)
>
> Processing {total} items..."

After processing, report results:

> "Batch distillation complete:
> - {count} skills updated
> - {count} learnings absorbed (.learned.md)
> - {count} memories distilled (logged)
> - {count} skipped (already processed / no matching skill)"

## Improve Mode: Refactor and Optimize

When invoked as `/wk:sharpen improve [scope]`, sharpen enters improve mode —
a cross-cutting refactor pass that prunes accumulated entropy from the skill
suite rather than processing new incident evidence.

`[scope]` is one of:
- omitted / `all` — every skill in `skills/`
- `<skill-name>` — deep-clean a single skill
- glob pattern (e.g., `pr-*`) — clean a named cluster

### Step 1: Inventory pass

Read every skill in scope. Build a per-skill map of: hard rules, phases/steps,
recurring sections, and any cross-skill references. This map drives the audit.

### Step 2: Parallel audit dispatch

Spawn cluster-grouped agents (typically 4–6 in parallel) to find:
- Duplicate or overlapping instructions (within and across skills)
- Overfit residue per the mechanical overfit categories in this skill
- Bloated sections (>3–4 paragraphs for a single action)
- Cross-skill duplication — boilerplate blocks (e.g., Post-Completion Learning
  Capture) or repeated patterns (shared API auth flows, GraphQL queries) that
  could be referenced once
- Stale or contradictory references
- Missing structure (where a table or HARD RULE would compress prose)

### Step 3: Optional external research

Dispatch one agent to search for best-practice patterns the suite hasn't
adopted (Anthropic skill docs, public skill repos, community discussions).
Filter to non-obvious, actionable insights that survive overfit scrutiny.

### Step 4: Consolidate findings

Merge all agent reports. Deduplicate findings cited by multiple agents. Group
by skill and by cross-cutting theme. Rank by leverage:
- **High** — clear win with no information loss
- **Low** — nitpick or style preference

### Step 5: Phased proposal to user

Present findings as a phased plan rather than a single mass diff:
- **Phase A** — extract shared boilerplate to referenced fragments
- **Phase B** — per-skill deduplication and bloat trimming
- **Phase C** — cross-skill consolidation
- **Phase D** — apply external best-practice insights that survived review

For each phase: list affected skills, the change shape, and the risk. **Wait
for explicit user approval per phase.** Even in auto mode, mass edits across
multiple skills are high blast-radius and require confirmation.

### Step 6: Apply approved phase

Run the Step 5 single-mode audit (overlap, contradiction, redundancy, bloat,
stale, overfit) on each per-skill edit before saving. Apply edits. Bump each
skill's `metadata.version` (CalVer).

### Step 7: Verify and commit

Same terminal gate as other modes: install (`npx skills add . -g -y -a=claude`),
group commits per skill or per phase, push, final clean-tree check.

### Hard rules for improve mode

- **No information loss.** Remove a rule only if (a) it is provably duplicated
  elsewhere with identical semantics, or (b) a stricter rule added later
  supersedes it. Otherwise the rule moves rather than disappears.
- **Phased approval required.** Auto mode does not short-circuit this —
  suite-scale refactoring is too risky to apply silently.
- **Cohort overfit scan applies.** Every proposed edit goes through the
  mechanical overfit scan before presentation.
- **Capture insights.** When external research surfaces a useful pattern, add
  it to the overfit-categories table or as a new rule in `wk:sharpen` so the
  next improve run has it as baseline.

---

## Requirements

- Read access to the skill file being improved
- Edit access to `skills/{skill-name}/SKILL.md`
- Read access to `~/.claude/memory/` (for batch mode)
- Read/write access to `$WK_SKILLS_HOME/learnings/` (for batch mode)
- Read/write access to `$WK_SKILLS_HOME/.distilled-sources.log`

---

## Post-Completion

Invoke `wk:learn` with this skill's short name as the argument (e.g., `wk:learn sharpen`).
