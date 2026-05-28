---
name: wk-sharpen
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
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.05.28-213801'
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

### HARD RULE: invocation routing — `wk-learn` vs `wk-sharpen`

`wk-sharpen` rewrites `SKILL.md` files. `wk-learn` only writes to
`learnings/`. Direct skill edits without explicit user consent are
out of scope — the skills repo is effectively read-only unless the
user explicitly authorizes a sharpen pass.

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
- Ambiguous phrasing ("learn from this and sharpen") defaults to
  `wk-learn`. Ask before promoting to `wk-sharpen`.

## Style Rules for Every Edit

Every edit you write into a target skill must follow these rules. They apply
to new content **and** to any cleanup of existing prose touched during audit.

- **Bullets over prose.** Default to bulleted lists. Use a paragraph only
  when the rule cannot be split into discrete imperatives without loss.
- **Imperative voice.** Each bullet starts with a verb: "Run", "Verify",
  "Reject", "Skip", "Re-fetch". No "you should" / "we recommend" / "it is
  important to".
- **One rule per bullet.** Do not chain "and / and / and". Split into
  separate bullets.
- **Crisp.** Strip hedging ("typically", "usually", "may want to"). State
  the rule. State the failure mode in one clause.
- **Instructional, not explanatory.** Tell the agent what to **do**, not
  what the rule is **about**. The "why" sits in a single trailing
  sub-bullet or parenthetical, not a paragraph.
- **Concrete commands** belong in fenced code blocks. Do not paraphrase a
  command in prose when the command itself is shorter.
- **No essays.** A section that runs past four bullets either splits into
  named sub-sections or trims to the load-bearing rules.

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

## IMPORTANT — high-severity learnings are not optional

**You keep forgetting this.** A learning with `severity: high` (or higher)
MUST land in the target skill before the source file is renamed to
`.learned.md`. Renaming without folding the rule into `SKILL.md` orphans
the lesson — the original incident recurs and the agent re-discovers the
same fix from scratch.

For every learning surfaced this run, before doing anything else:

- Read the frontmatter and extract `severity`.
- If `severity: high` (or higher), treat as a **MUST-FOLD** item:
  - The lesson lands in SKILL.md as a new rule, HARD RULE, or new
    sub-step. Reference-file-only routing is forbidden for high-
    severity items (one-off classification does not apply at this
    severity — if it is high enough to flag, it is high enough to
    encode).
  - The `.distilled-sources.log` entry must record `distilled` (never
    `partial`, never `already-covered` without citing the existing
    SKILL.md line numbers that prove full coverage).
  - The rename to `.learned.md` happens only after the SKILL.md edit is
    written and the version bumped.
- If a high-severity learning is classified `already-covered`, the
  classification must cite specific existing SKILL.md line numbers
  that prove every rule in the learning is encoded — per the
  "full-read before `already-covered`" HARD RULE.
- Treat unrecognized log actions (anything not in
  `distilled | partial | already-covered | skipped`) as `unverified` and
  re-audit.

When in doubt on a high-severity item, escalate — ask the user before
renaming. Silent rename without coverage is the failure mode this
annotation exists to prevent.

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

### HARD RULE: full-read before `already-covered`

Mark a learning `already-covered` only after reading the full
learning file and matching every rule/bullet in it against an
existing rule/bullet in the target skill.

- Match at the rule/bullet level, not the topic level. Two
  surface overlaps do not prove full coverage.
- If any line teaches something the skill does not yet encode,
  classify as `partial` and distill the missing parts.
- Cite the specific existing lines that already encode each
  bullet — "topic exists in the skill" is not a coverage proof.

### Classify: principle vs one-off

**HARD RULE:** Before drafting any SKILL.md edit, classify the distilled
lesson as `principle` or `one-off`. Routing is different for each —
SKILL.md grows unbounded if every one-off lands inline.

- `principle` — the failure mode generalizes; the rule applies on
  most invocations of the skill or to a recurring class of input.
  Route: fold into SKILL.md (proceed to Step 4) AND write a
  reference file recording provenance.
- `one-off` — the scenario is narrow, repo-specific, tool-version-
  specific, or unlikely to recur; the rule does not generalize
  cleanly to most agent runs.
  Route: write a reference file ONLY (see Step 7 reference rules).
  Do NOT edit SKILL.md. Do NOT bump `metadata.version`.

Classify as `principle` when **any** of:

- The same pattern appears in ≥ 2 prior learnings, memories, or
  `.distilled-sources.log` entries for this skill.
- The failure mode would surface on every invocation that touches
  the affected step (not gated on uncommon inputs).
- The fix is a check or rule expressible in one bullet without
  naming specific tools, versions, or repos.

Classify as `one-off` when **any** of:

- The fix requires a verbatim recipe that only works for one tool
  version, runtime, or repo layout.
- The failure mode only fires under a configuration the agent
  rarely encounters.
- The user described it explicitly as a corner case or a one-time
  workaround.
- Distilling the principle leaves nothing actionable that is not
  already covered by existing rules in the skill.

Record the classification in the run report and in the reference
file's frontmatter (`class: principle` or `class: one-off`). When
ambiguous, ask the user once before proceeding.

## Step 4: Draft the Skill Update

**Skip Step 4 entirely for `one-off`-class lessons.** Jump to Step 7
and write the reference file only — no SKILL.md edit, no version bump.
For `principle`-class lessons, continue here.

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

**Orphaned label artifacts:** When removing a tool, permission, or
config line, scan for the adjacent label comment that introduced it
(e.g., a `# Learning capture` header above an `allowed-tools` entry,
a section heading above a removed code block). A label with no
following content is dead text — remove it in the same edit.

If the audit surfaces cleanup beyond your original edit, bundle the
cleanup into the same change. Do not leave known debt for a future pass.

### Mechanical overfit scan

**HARD RULE:** Before Step 6 presents the diff, run a checklist-driven grep
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
| Employer / internal project names | `$EMPLOYER`, `$GITHUB_ORG`, or any literal employer name, internal repo name, or internal service name (e.g., the actual company name or monorepo name as a string) | `{owner}/{repo}`, `{service}`, "the repo", "the project" — use `$EMPLOYER`/`$GITHUB_ORG` only when referencing the env var itself, never the resolved value |
| Specific ticket IDs | `[A-Z]+-\d+` outside placeholder examples | `[BOARD-NUM]` or remove |
| Specific repo / file / package names | concrete project names that don't generalize | "the file", "the repo", "the package" |
| Line numbers / SHAs / PR numbers | `:\d+`, short SHAs, `#\d+` outside template slots | "the target line", "the commit", "the PR" |
| Specific tool versions | exact versions cited when the failure pattern is version-agnostic | "a version that introduces <change>" |
| Concrete person names | reviewer / committer names | "the reviewer", "the author" |
| Hardcoded branch names | `main`, `master`, `develop` literal in `git diff/log/merge-base/rebase` commands or prose | `<base>` placeholder + dynamic resolution (e.g., `gh pr view --json baseRefName --jq .baseRefName`) — stacked PRs have non-default bases |

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

- Edit `skills/{skill-name}/SKILL.md` with the new content **and** every
  audit cleanup item — do not defer cleanup to a follow-up pass.
- Verify each new or edited section follows the **Style Rules** above
  (bullets, imperative voice, one rule per bullet, no essays).
- Write distilled context to `skills/{skill-name}/references/` (see below).
- Bump `metadata.version` to a fresh CalVer (`YYYY.MM.DD-HHMMSS`, UTC) —
  patch for fixes, minor for new steps. Never reuse a version string.
- Re-read the final file end-to-end to confirm coherence and absence of
  drift (see "Drift check" below).

Step 7 is **edits only**. Committing happens in Step 8.

### Write distilled references to `skills/{name}/references/`

The target skill's prose teaches the agent **what to do**. The
`references/` directory teaches the agent **what was learned and why**,
without bloating the SKILL.md itself.

- Create the directory if missing:

  ```bash
  mkdir -p skills/{skill-name}/references
  ```

- For each distilled learning, write one short reference file:
  `references/{YYYY-MM-DD}_{slug}.md`. Both classes get a reference;
  the file shape differs by class.
  - One learning per file. Do not concatenate multiple incidents.
  - Frontmatter: `class: principle` or `class: one-off` (mandatory).
  - File body: 5–15 lines for `principle`; up to 30 lines for
    `one-off` (it carries the full context since SKILL.md does not).
    Bullets only.
  - **`principle` required sections:** **Rule** (one line), **Why**
    (one line, the failure mode), **Where** (one line, which Step /
    HARD RULE in SKILL.md it landed in).
  - **`one-off` required sections:** **Scenario** (one line, the
    narrow condition), **Symptom** (one line, what fails), **Fix**
    (concrete recipe — verbatim commands allowed since SKILL.md will
    not carry them), **Why not promoted** (one line citing the
    one-off classification criterion that matched).
  - No incident-specific tokens that the SKILL.md edit already
    stripped (filenames, line numbers, reviewer logins, SHAs) —
    exception: `one-off` files may keep tokens that the recipe
    requires verbatim, since they are not generalizing.
- Do not link references from SKILL.md prose. They are an index for
  future sharpen runs and audits, not runtime documentation.
- The mechanical overfit scan (Step 5) applies to reference files too —
  they are part of the proposed edit set.

### Drift check

Before exiting Step 7, scan the full SKILL.md for drift between
iterations. Multi-edit runs accumulate stale content fast.

- Frontmatter `description` still matches what the skill actually does
  after every edit in this run.
- `argument-hint` matches the current argument shape.
- `allowed-tools` lists every tool the new edits reference (and no
  orphaned entries).
- Quick-reference table, Trigger table, and Step list at the top match
  the section headings in the body — no renamed Steps left referenced
  by the old name.
- Cross-references between Steps (`see Step N`, `per the rule above`)
  still resolve to the correct targets.
- Examples in SKILL.md that demonstrate the fixed behavior (good vs
  bad) reflect the **post-edit** behavior, not the pre-edit one.

Fix every drift item in the same edit pass.

## Step 7.5: Refactor Pass (concision gate)

Once every learning queued for the run has been folded into the target
skill, run a refactor pass on the **edited file** before committing. Do
not skip even when each individual edit looked tight in isolation —
multi-edit runs accumulate redundancy across sections that no single
edit can see.

- Invoke `wk-refactor` against the edited SKILL.md and any new
  `references/` files:

  ```
  Skill(wk-refactor, args="skills/{skill-name}/SKILL.md")
  ```

- Apply only refactor suggestions that **preserve every rule** —
  consolidating duplicates, collapsing nested prose into bullets,
  removing dead labels left by earlier edits.
- Reject any suggestion that drops a HARD RULE, an error code, or a
  failure-mode explanation. Concision must not cost coverage.
- After refactor edits land, re-run the **Drift check** in Step 7 — a
  refactor that renames a Step or merges sections can re-introduce
  drift the prior pass cleared.

The goal is: the final SKILL.md contains exactly what the executing
agent needs, no more.

## Step 8: Verify and Commit (terminal gate)

Do not return control to the user until all four checks pass:

1. **Install:** `npx skills add . -g -y -a=claude 2>&1 | tail -5` from the repo root — must print `Done!`. Re-run from repo root if it prints `No skills found` or exits non-zero.
2. **Commit:** every dirty file in a commit. In batch/multi-phase runs, group by logical change (one commit per skill updated, including its `references/` additions; one chore commit for `.learned.md` renames + `.distilled-sources.log`); use `wk-commit` conventional format with classifier emojis (🦾 🛡️ 🔧). Commit as each change lands — do not pause between commits or phases.
3. **Push once:** after all commits exist, push a single time. Single-skill runs may push immediately after their lone commit.
4. **Clean tree:** `git status --short` must be empty — if anything remains, commit or stash it.

Report: one line per skill updated (name, new version, principle distilled), then confirm tree clean, installed, pushed. Silence after edits is a violation of this gate.

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
| `/wk-sharpen pr-review incident.md` | Read incident, distill lesson, audit full skill, propose update |
| `/wk-sharpen commit "agent skipped signing"` | Distill verbal report, audit, propose skill improvement |
| `/wk-sharpen` (no args) | Batch mode — scan learnings + memories, distill all |
| `/wk-sharpen --scan --force` | Batch mode — reprocess everything, ignore log |
| `/wk-sharpen improve [scope]` | Improve mode — refactor and prune accumulated entropy |

**Single mode:** Read report → Read full skill → Distill → Classify
(`principle` vs `one-off`) → Draft (skip for `one-off`) → Audit for
overlap/bloat → Present with cleanup → Apply → Verify & commit

**Batch mode:** Scan learnings + memories → Filter by log → Process each
via single mode → Rename learnings to `.learned.md` → Update log

**Improve mode:** Inventory scope → Parallel audit → Consolidate findings →
Phased proposal (user approval per phase) → Apply → Verify & commit

## Batch Mode: Scan Learnings and Memories

When invoked without a specific incident (e.g., `/wk-sharpen` with no
arguments, or `/wk-sharpen --scan`), sharpen enters batch mode — scanning
three sources for distillable material.

### Source 1: Global learnings inbox

- Mirror unprocessed learnings from `~/.claude/skills/learnings/` into the
  repo's tracked tree before distilling. Global captures land outside the
  repo and must be version-controlled here to log as `.learned.md`.
- Skip the entire source if the directory does not exist.
- For each `*.md` (excluding `*.learned.md`) under the inbox:
  - Resolve destination as `$WK_SKILLS_HOME/learnings/skills/<relative-path>`
    preserving sub-directory structure.
  - Skip the copy if the destination already exists (already mirrored).
  - Copy the file, then delete the inbox original so the inbox stays
    drained:

    ```bash
    inbox=~/.claude/skills/learnings
    [ -d "$inbox" ] || exit 0
    find "$inbox" -name "*.md" ! -name "*.learned.md" -type f | while read -r src; do
      rel="${src#$inbox/}"
      dest="$WK_SKILLS_HOME/learnings/skills/$rel"
      [ -e "$dest" ] && continue
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest" && rm "$src"
    done
    ```

- After mirroring, fall through to Source 2 — the copied files are now
  unprocessed learnings in the repo tree and get distilled there.

### Source 2: Repo learnings directory

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

### Source 3: Global memory files

Scan `~/.claude/memory/` for memory files that contain skill-applicable
feedback or corrections:

```bash
find ~/.claude/memory -name "*.md" -type f 2>/dev/null
```

**Only process memories of type `feedback`.** Read each file's frontmatter
— if `type: feedback`, the memory likely contains a behavioral correction
or confirmed approach that could improve a skill.

**HARD RULE — never rename memory files.** The `.learned.md` suffix is a
**repo learnings** convention (Source 2 only). Memory files in
`~/.claude/memory/` always keep their original `.md` name; their
processed state is tracked exclusively by `.distilled-sources.log`.
Renaming a memory file breaks `MEMORY.md` index links and orphans the
content from cross-session recall.

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
2026-04-21\t~/.claude/memory/feedback_testing.md\tdistilled\twk-workflow
2026-04-21\t~/.claude/memory/user_role.md\tskipped\t—
2026-04-21\tlearnings/skills/pr-review/2026-04-21_stale-diff.md\tdistilled\twk-pr-review
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
(e.g., `/wk-sharpen --scan --force` or "rescan all memories"), ignore
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

When invoked as `/wk-sharpen improve [scope]`, sharpen enters improve mode —
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
Per-phase commits are not blocking gates — land each phase's commits
and proceed; push happens once at the end of the run, not between phases.

### Hard rules for improve mode

- **No information loss.** Remove a rule only if (a) it is provably duplicated
  elsewhere with identical semantics, or (b) a stricter rule added later
  supersedes it. Otherwise the rule moves rather than disappears.
- **Phased approval required.** Auto mode does not short-circuit this —
  suite-scale refactoring is too risky to apply silently.
- **Cohort overfit scan applies.** Every proposed edit goes through the
  mechanical overfit scan before presentation.
- **Capture insights.** When external research surfaces a useful pattern, add
  it to the overfit-categories table or as a new rule in `wk-sharpen` so the
  next improve run has it as baseline.

---

## Requirements

- Read access to the skill file being improved
- Edit access to `skills/{skill-name}/SKILL.md`
- Read access to `~/.claude/memory/` (for batch mode)
- Read/write/delete access to `~/.claude/skills/learnings/` (global learnings
  inbox — files are moved into the repo tree, then removed from the inbox)
- Read/write access to `$WK_SKILLS_HOME/learnings/` (for batch mode)
- Read/write access to `$WK_SKILLS_HOME/.distilled-sources.log`

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn sharpen`).
