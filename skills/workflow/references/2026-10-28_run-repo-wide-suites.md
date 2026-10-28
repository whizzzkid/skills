---
class: principle
escalation: baseline → Important (rung 2)
source: learnings/skills/workflow/2026-10-28_run-repo-wide-suites.learned.md
---

# Feature-scoped suite runs are narrow checks — re-violation escalation

**Rule** — a suite selector's run scoped to the changed feature is a narrow check, the same class as a pre-commit
subset. Repo-wide scanners (style, lint-like, localization tests) cover every source file, so they gate every change.
Run the full gate before pushing.

**Why** — the agent added user-visible strings, ran only the feature's suite, and pushed; CI failed a repo-wide test
that scans every file for visible-text style rules. The selector made the narrow run feel authoritative. The baseline
rule "A fast/narrow check is never the authoritative gate" (installed 2026-07-02) already required the full gate, so
this is a re-violation: escalated one rung, baseline → `Important`, with the suite-selector case named explicitly.

**Rejected** — the learning's "feature suite plus repo-wide suites, or the full gate when affordable" alternative. It
relaxes the installed full-gate rule; installed wins. "New user-visible strings trigger style suites" is subsumed by
the full gate and was not added as a separate trigger.

**Where** — `SKILL.md` Phase 3 Test → "Important — a fast/narrow check is never the authoritative gate" bullet.
