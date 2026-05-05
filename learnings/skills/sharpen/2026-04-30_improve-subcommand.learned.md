---
skill: wk-sharpen
date: 2026-04-30
type: gap
severity: high
---

`wk-sharpen` only flows incident → principle → skill edit. It has no
mode for refactoring/optimizing existing skills as a whole — when
skills accrete bloat, duplication, overfit residue, or stale
references after many distillation cycles, there is no first-class
entry point to scrub them.

**What happened:** User invoked `/wk-sharpen` with a request to
audit the entire skill suite for duplicate suggestions, overfitting,
poor examples, long-winded instructions, and to incorporate external
best-practice ideas — without losing any instructions. The current
skill modes (single-incident, batch-distill) don't fit that shape:

- Single mode requires an incident report.
- Batch mode walks the learnings/memories queue and is skill-by-skill,
  not cross-cutting.

The work was orchestrated ad hoc: dispatch parallel audit agents,
consolidate findings, write a proposal, get approval, apply edits.
That's a useful pattern that should be a repeatable subcommand
rather than a one-off.

**Root cause:** The skill is framed around *producing* new rules
from new evidence. It has no symmetric mode for *pruning* or
*restructuring* the rules already accumulated. As the suite ages,
the entropy from many incremental edits exceeds what per-finding
audits (Step 5 of single mode) can clean up.

**Suggested fix:** Add a third mode: `/wk-sharpen improve [scope]`.

Modes summary table:

| Trigger | Mode |
|---------|------|
| `/wk-sharpen <skill> <incident>` | single (existing) |
| `/wk-sharpen` | batch-distill (existing) |
| `/wk-sharpen improve [scope]` | refactor/optimize (NEW) |

Where `[scope]` is one of:
- omitted / `all` — every skill in `skills/`
- `<skill-name>` — single skill deep-clean
- `<cluster-name>` (e.g., `pr-*`, `data-*`) — pattern-grouped

### Improve mode workflow

1. **Inventory pass.** Read every skill in scope. Build a
   per-skill map of: hard rules, phases/steps, recurring
   sections, cross-skill references.

2. **Parallel audit dispatch.** Spawn cluster-grouped agents
   (typically 4-6 in parallel) to find:
   - Duplicate / overlapping instructions (within and across
     skills)
   - Overfit residue per the existing overfit categories
   - Bloat (sections >3-4 paragraphs for a single action)
   - Cross-skill duplication (boilerplate Post-Completion
     Learning Capture blocks, repeated GraphQL queries,
     repeated MCP-auth flows)
   - Stale / contradictory references
   - Missing structure (places where a table or HARD RULE
     would compress prose)

3. **External research dispatch (optional).** One additional
   agent searches public sources (Anthropic skill docs, public
   skill repos, community discussions) for best-practice
   patterns the suite hasn't adopted. Filter to
   non-obvious / actionable insights.

4. **Consolidate findings.** Merge all agent reports.
   Deduplicate findings cited by multiple agents. Group by
   skill and by cross-cutting theme. Rank by leverage: high =
   clear win with no information loss; low = nitpick.

5. **Phased proposal to user.** Present consolidated findings
   as a phased plan rather than a single mass diff:
   - **Phase A** — extract shared boilerplate to a referenced
     fragment (e.g., the Post-Completion Learning Capture
     block).
   - **Phase B** — per-skill deduplication and bloat trimming.
   - **Phase C** — cross-skill consolidation (shared GraphQL,
     MCP auth patterns).
   - **Phase D** — apply external best-practice insights that
     survived discussion.

   For each phase: list affected skills, the change shape, and
   the risk. Wait for explicit user approval per phase — never
   apply mass edits autonomously, even in auto mode. Mass
   refactor across many skills is a high-blast-radius action
   that warrants confirmation.

6. **Apply approved phase.** Run the existing single-mode Step
   5 audit (overlap, contradiction, redundancy, bloat, stale,
   overfit) on each per-skill edit before saving. Apply edits.
   Bump the metadata version (CalVer).

7. **Verify and commit.** Same terminal gate as the other
   modes: install, group commits per skill or per phase, push,
   final clean-tree check.

### Hard rules for improve mode

- **No information loss.** Removing a rule requires either (a)
  the rule is provably duplicated elsewhere with identical
  semantics, or (b) the rule was overtaken by a stricter rule
  added later. Otherwise the rule moves rather than
  disappears.
- **Phased approval.** Mass edits across multiple skills
  require user approval per phase. Auto mode does not
  short-circuit this — refactoring at suite scale is too
  risky to apply silently.
- **Cohort overfit scan still applies.** Every proposed edit
  goes through the existing mechanical overfit scan before
  presentation.
- **Capture insight for the next pass.** When external
  research surfaces a useful pattern, add it as a row to the
  existing overfit-categories table (or as a new rule in
  `wk-sharpen` itself) so the next improve run has it as
  baseline.

### Why this fits in `wk-sharpen` rather than a new skill

Sharpen already owns the audit step (Step 5), the overfit
scan, the install-and-commit gate, and the learning-capture
hook. Improve mode is a different *entry point* into the same
machinery, not a different machine. A separate skill would
duplicate the audit checklist and the terminal gate.

### Minimum implementation

The improve mode can be added as a new "Mode 3" section near
the batch-mode section, with a Quick Reference row pointing
to it. The actual orchestration (parallel agent dispatch,
consolidation, phased proposal) is mostly prompt scaffolding
that points the agent at the existing Step 5 audit per
sub-edit.
