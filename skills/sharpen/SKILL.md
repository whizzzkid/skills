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
  version: "2026.10.09-202501"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Sharpen

Extract the **principle** behind a failure → update the skill to prevent the behavior, not just the specific instance.

## HARD RULE: invocation routing — `wk-learn` vs `wk-sharpen`

- `wk-sharpen` rewrites `SKILL.md`; `wk-learn` only writes to `learnings/`. Skill edits without explicit user consent
  are out of scope.
- "make a learning" / "capture this" → `wk-learn`. "sharpen the skill" / "update the skill" / `/wk-sharpen` →
  `wk-sharpen`. Ambiguous → default to `wk-learn`; ask before promoting to `wk-sharpen`.

## Core Rules

- **Style:** bullets over prose; imperative voice; one rule per bullet; "why" in one trailing parenthetical. Details:
  [`references/style-rules.md`](references/style-rules.md).
- **Extract principles, not examples:** remove file names, line numbers, project context; keep error codes, API
  behavior, structural patterns.
- Assert trigger’s input count is non-zero before reading a gate’s verdict:
  [`references/harness-defect-triage.md`](references/harness-defect-triage.md).
- Load-bearing grep: `command grep`, one quoted path, rc 0/1/≥2 = hit/clean/error.
- **High-severity learnings:** `severity: high` → **MUST-FOLD** into `SKILL.md` as a new rule, HARD RULE, or sub-step
  (reference-file-only forbidden). Rename to `.learned.md` only after edit + version bump land. Ownership resolves
  before thoroughness — MUST-FOLD sets depth, not ownership. Blocked target path → extend existing fold, never open a
  competing one.

## Step 0: Eval freshness

```bash
STAMP="$WK_SKILLS_HOME/benchmarks/results/.last-eval"
[[ -n "$(find "$STAMP" -mtime -7 2>/dev/null)" ]] && cat "$STAMP" || echo "eval stale or never run"
```

- Stale or missing → propose `scripts/weekly-eval.sh` once per session (≈400 Claude Code calls); run it only on an
  explicit yes, then continue the fold either way. Fresh → continue silently.

## Step 1: Read the Incident Report

Extract: intended behavior, what went wrong, root cause (a hypothesis to verify).

- **HARD RULE: the report is a hypothesis — verify against the owning source.** Successful workaround is not evidence; a
  dispatcher's tree-state claim loses to tree evidence. Reproduce named artifacts before drafting; a red result from
  your own tooling indicts the tooling first. Triage:
  [`references/harness-defect-triage.md`](references/harness-defect-triage.md).
- Reject folds that relax a guard → hunt the correctness bug instead.
- Record rejected suggestions in the reference file.

## Step 2: Read the Full Skill

- Grep the learning’s subject across `skills/`; fold into the API-mechanics home AND correct every over-general
  instance.
- Resolve dirs by listing: `d=$(ls -d skills/*"${n#wk-}" | head -1)`. Details:
  [`references/skill-dir-resolution.md`](references/skill-dir-resolution.md).
- Read entire `SKILL.md` — partial reads do not satisfy the edit guard.

## Step 3: Distill the Lesson

Transform incident into a generalizable principle.

- **HARD RULE: prohibited-subject gate — scan subject before drafting.** `command grep` subject (stdin) against
  `.skillprohibit` as pattern file (`-f`, comment/blank lines stripped; inverted fails open). Prove the zero with a
  canary. Match → route to private `CLAUDE.md`, skip fold. Category-only naming in commits. Details:
  [`references/staged-path-scan.md`](references/staged-path-scan.md).
- **HARD RULE: full-read before `already-covered`.** Read body + every linked reference; match at rule level; cite
  proving lines with file. Missing rule → `partial`.
- **HARD RULE: re-violation escalation — `already-covered` is NOT "done".** Repeat of an existing rule proves it failed
  → escalate exactly one notch up [`references/escalation-ladder.md`](references/escalation-ladder.md). Exception:
  same-session evidence the rule fired correctly blocks escalation. Escalate only against text installed before the
  report (date via `git log -S`; unshipped → `already-covered (unshipped)`). Treat escalation as a principle edit.
- **Classify:** `principle` (generalizes → SKILL.md + reference) vs `one-off` (narrow → reference only). Tests:
  [`references/classify-criteria.md`](references/classify-criteria.md).

## Step 4: Draft the Skill Update

Skip for `one-off`. Locate edit target (new step, missing check, wrong instruction, or new HARD RULE). Check remedy
against installed HARD RULEs and tool-selection rules — installed wins. Edit target is a self-governing gate → apply
stricter of pre/post text. Draft imperative instructions with heading, action, why, concrete checks.

## Step 5: Audit the Full Skill

Re-read with proposed edit applied. Merge overlapping instructions; resolve contradictions; bulletize bloated sections;
refresh stale references. Then run the mechanical overfit scan:

- Grep edit text against [`references/overfit-categories.md`](references/overfit-categories.md); replace matches with
  generic mechanisms. Ticket-shaped tokens → `<KEY>` per
  [`references/ticket-shaped-example-tokens.md`](references/ticket-shaped-example-tokens.md).
- Prove staged set matches intended paths before hooks. Run every owning hook:
  [`references/staged-path-scan.md`](references/staged-path-scan.md).
- Index holds another fold → throwaway-index per [`references/byte-budget.md`](references/byte-budget.md).

## Step 6: Present for Review

Show: principle, edit location, proposed diff, cleanup items. Direct `/wk-sharpen` and auto mode → apply/commit/push;
report diff.

## Step 7: Apply the Update

- Edit `SKILL.md` + cleanup items; bump `metadata.version` (CalVer); re-read end-to-end.
- Write reference file per learning; frontmatter per
  [`references/reference-file-template.md`](references/reference-file-template.md). Never link per-learning references
  from SKILL.md.
- Processed names: `YYYY-MM-DD_<kebab>.learned.md`.
- **Sync README + docs:** bump sibling `README.md` `Version:` on every version change (unconditional); update narrative,
  Mermaid diagrams, index files when behavior changes; invoke `wk-docs` for cross-skill changes; stage with SKILL.md
  change.
- **Drift check:** verify frontmatter description, argument-hint, allowed-tools, quick-reference table, step list,
  cross-references (both directions), examples — all match the post-edit body. Recount from source per
  [`references/recount-probe-bounds.md`](references/recount-probe-bounds.md). Fix all drift in same pass.

## Step 7.5: De-bloat Pass

**HARD RULE: de-bloat every run — never let prose accrete.** Run on every sharpening. Bulletize; state rules once;
cross-reference duplicates (keep earliest occurrence). Reject any edit that drops a HARD RULE, error code, or
failure-mode explanation. Re-run Drift check after.

**HARD RULE: hard size ceilings per `SKILL.md`.** Body ≤ 24576 bytes plus front-matter / `description:` /
`allowed-tools:` limits per `.githooks/check-skill-size.sh`; stay under proactively, never rely on the hook alone.
Details: [`references/byte-budget.md`](references/byte-budget.md).

- Prefer structural moves (relocate catalog rows, delete duplicates) over prose compression. Grep `references/` for
  stay-inline notes before relocating.
- **Measure staged body + price reclaim pool BEFORE drafting content-adding folds.** Never relocate gate checks or
  verification checklists behind a pointer, never cut a rule's verified-configuration qualifier — the ceiling never
  outranks a load-bearing rule.
- **Running byte ledger:** measure at entry, debit each edit group, record
  `baseline + additions - reclaims = projected`. Use `LC_ALL=C wc -c`.

## Step 8: Verify and Commit

All five must pass before returning:

1. **Install:** preflight + byte-compare per
   [`references/step8-install-cd-repo-root.md`](references/step8-install-cd-repo-root.md).
2. **Suite:** executable folds → run suite; red → Step 1 triage.
3. **Commit:** stage this fold’s files only; `wk-commit`. Blocked rename handling:
   [`references/commit-gate.md`](references/commit-gate.md).
4. **Push:** once after all commits.
5. **Clean tree:** no modified tracked paths.

## Modes

- **Batch:** without specific incident → scan `$WK_SKILLS_HOME/learnings/skills/` severity-first, oldest mtime first.
  Sources: [`references/batch-mode-sources.md`](references/batch-mode-sources.md). Re-list before and after each fold.
  Arrivals postdating run start are unowned. Terminal state: "processed N, M unclaimed, K distilled-not-landed."
- **Loop:** [`references/loop-mode.md`](references/loop-mode.md) — one machine-wide worker drains queue.
- **Improve:** `/wk-sharpen improve [scope]` — suite cleanup per
  [`references/improve-mode.md`](references/improve-mode.md). Phased approval required; auto mode never short-circuits.

## Post-Completion

Invoke `wk-learn sharpen`.
