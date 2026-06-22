---
skill: wk-sharpen
date: 2026-06-19
type: gap
severity: low
---

The pre-commit overfit scan should grep staged archives against the actual `.skillprohibit` term list, not just ad-hoc ticket/org patterns.

**What happened:** The batch run's first commit was blocked by the `check-prohibited` hook because an internal tool name (`<internal-tool-name>`) survived in a retrospect `.learned.md` archive's "What worked" bullet. The Step 5 mechanical overfit scan had been run, but only against ticket-shaped tokens and a guessed internal-name (`<guessed-internal-name>`); it never consulted the repo's `.skillprohibit` list, so the tool name slipped through and the hook caught it instead.

**Root cause:** Step 5 mandates scrubbing learning/retrospect archives for internal tool/project/service/org names, but the agent's scan was an improvised grep of a few categories rather than a check against the authoritative `.skillprohibit` term file. The hook is the backstop, not the intended first line — relying on it costs a failed commit + amend cycle.

**Suggested fix:** In Step 5's mechanical overfit scan, add: before committing, grep every staged file (skill edits, references, AND renamed `.learned.md` archives) against the repo's `.skillprohibit` term list directly — `grep -iFf .skillprohibit <staged files>` — and anonymize every hit. This catches internal tool names the ad-hoc category grep misses, before the `check-prohibited` hook blocks the commit.
