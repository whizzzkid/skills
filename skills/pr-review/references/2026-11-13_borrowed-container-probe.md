---
class: principle
---

# Generated-file sizing, time-boxed dispatches, borrowed-container probes

- **Rule** — Phase 1 counts generated files separately and leads the size note and stack call with hand-written
  lines. The time box never drops a phase-owned dispatch: over budget → dispatch anyway and report the overrun. A
  probe with no container of its own may borrow another worktree's running container only when the code under test
  takes injectable fakes; copy PR-head files to a scratch path, require every other loaded file to match PR head,
  record the probe's scope with its PASS/FAIL, delete the copies afterward.
- **Why** — Generated stubs dominated a large PR's line count, so the raw size overstated review surface. A medium
  run skipped the mandatory adversarial and arch dispatches to fit the time box and disclosed the skip; the installed
  mandatory-dispatch rule (shipped before the report) already forbade that, so the time-box bullet now says so
  explicitly at `**Important:**` (escalation rung 2). A borrowed container runs the sibling checkout's code
  everywhere the copied files are not, so faithfulness depends on the loaded files matching PR head; writing over
  the sibling's tracked files would corrupt another session's tree.
- **Rejected** — the suggested "skip the dispatches and disclose it" alternative: it relaxes an installed guard, and
  disclosure is not coverage.
- **Where** — Phase 1 "Collect" sub-bullet; Review Modes "Time box" sub-bullet; Phase 3 sub-bullet under the
  logic-bearing empirical-proof HARD RULE.
