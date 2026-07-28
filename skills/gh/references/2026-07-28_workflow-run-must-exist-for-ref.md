---
class: principle
---

# A CI job proves nothing until a run exists for the ref

**Rule** — when a diff adds or edits a CI job, confirm the workflow's `on:` triggers fire
for the current ref *and* that a run exists for it before treating the job as working. A
trigger block naming only the default branch plus `pull_request` runs on neither a pre-PR
feature-branch push nor any ref without an open PR. Empty `gh run list --branch <ref>`
output is the tell. Never mark the job complete, document it as green, or add it to
required status checks until a run for that ref exists.

**Why** — jobs added, reviewed, documented as complete, and even made required while the
branch was still pre-PR had never executed once; their first run (on PR creation) surfaced
three genuine defects at once — a runtime dependency the runner lacked, output the runner
quoted differently than a local shell, and runner-only startup noise a parser read as an
error. Confirmed by reading the workflow's own trigger block: nothing about those jobs had
ever been verified. A gate that has never executed is not a gate.

**Distinct from the rollup rules** — the rollup bullets govern *reading* a rollup whose
entry is ambiguous ("passed" vs "never ran / skipped / soft-failed"). This rule fires one
step earlier: a workflow that never started produces no entry at all, so there is nothing
to read and no ambiguity to resolve. Classified `partial` against those bullets — the
existing rule's trigger (consuming a rollup) never fires in the failing sequence, so the
gap was additive, not a re-violation, and no escalation notch was taken.

**Where** — `wk-gh` → *A CI job proves nothing until a run exists for the ref*; README
Noteworthy bullet.
