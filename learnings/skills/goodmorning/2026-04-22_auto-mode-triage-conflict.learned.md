---
skill: wk-goodmorning
date: 2026-04-22
type: gap
severity: medium
---

Skill's interactive triage conflicts with auto mode / minimize-interruptions directive.

**What happened:** Skill explicitly requires per-group interactive triage prompting (≤5 items per prompt, one group at a time). In auto mode, I bypassed triage entirely and applied auto-resolution + reasonable defaults directly in the written brief. This worked fine, but the skill has no guidance for auto/non-interactive runs.

**Root cause:** Skill was authored assuming an interactive-by-default workflow. There's no explicit section on how to degrade gracefully when the harness says "minimize interruptions" — the user ends up with zero control over triage decisions in that path.

**Suggested fix:** Add an "Auto / non-interactive mode" branch to Stage 2 triage. Proposed behavior: when auto mode is active, apply weekly rules + prior-day decisions as usual, then default all unresolved items to "(a) Will do" with an explicit note in the dashboard header (e.g., "Auto-triaged — N items defaulted to 'will do'; review and edit morning.md to override"). Still fire the weekly-memory candidate check, but write any new rules as "pending confirmation" rather than committed.
