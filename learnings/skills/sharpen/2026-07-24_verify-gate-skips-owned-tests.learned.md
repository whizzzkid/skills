---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
---

The Step 8 verify gate never runs the test suite of an executable artifact the fold edited.

**What happened:** Step 8's four terminal gates are install, commit, push, and clean tree.
None of them runs tests. Some skills own executable artifacts — a hook script, a resolver
binary, a helper — with a sibling test suite in the skill directory. A fold that edits such
an artifact currently reaches commit without the suite ever running; whether it runs at all
depends on the agent's own initiative rather than on the skill.

This run only touched `SKILL.md`, `README.md`, and `references/`, so no suite applied and
nothing broke. The gap surfaced while distilling a learning that *originated* in a session
where a fold did edit a guard hook — that session ran the hook's suite and the suite's red
result is the entire subject of the lesson. The skill assumes a test run it never asks for.

**Root cause:** Step 8 was written for the common case where a fold is documentation-only,
so "verified" means "installs and commits cleanly". It has no conditional branch for a fold
that changes behavior of code the skill ships, and no instruction to locate a suite next to
the edited artifact.

**Suggested fix:** Add a conditional gate to Step 8: when the fold edits any executable
artifact the skill ships (not `SKILL.md` / `README.md` / `references/`), locate and run that
skill's test suite before committing, and treat a red result per the existing Step 1 rule —
drive the artifact directly with the same input first, since the harness may be the defect.
A fold that edits shipped code and runs no suite should not reach the commit gate.
