---
class: one-off
---

# Blocked local test environment — substitute, never fake

**Scenario**

- Phase 3 verification, but the local test environment is unusable (e.g. local DB
  down, toolchain broken) and the project's specs cannot run locally.

**Symptom**

- Temptation to declare tests green without having run them, or to silently skip
  verification.

**Fix**

- Never claim local specs passed when they did not run. State the block and its
  cause explicitly.
- Substitute the authoritative CI suite plus manual/browser-driven validation of
  the changed surface, and report which substitute was used.

**Why not promoted**

- The honesty core (report outcomes faithfully; never claim an un-run step passed)
  is already enforced by Phase 3 and the global reporting rule. The substitution
  mechanic only fires under the rare config of an unusable local environment, so
  it stays a reference rather than a SKILL.md rule in an at-ceiling skill.
