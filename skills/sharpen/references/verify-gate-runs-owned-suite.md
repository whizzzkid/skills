---
class: principle
---

# Step 8 must run the suite for shipped executable artifacts

**Rule** — When a fold edits an executable artifact a skill *ships* (hook script,
resolver binary, helper) rather than only `SKILL.md` / `README.md` / `references/`,
locate and run that skill's own test suite before the commit gate. A shipped-code
edit must never reach commit unrun. Treat a red result under the Step 1
harness-defect rule: drive the artifact directly with the same input first, since a
newly added case failing while every pre-existing case passes indicts the harness.

**Why** — Step 8's terminal gates were written for the common case, where a fold is
documentation-only and "verified" legitimately means "installs and commits cleanly".
Nothing in the gate list executed tests, so whether a suite ran depended on the
agent's own initiative instead of the skill. Some skills ship runnable code with a
sibling suite in the skill directory; a behavior-changing fold to one of those could
ship without the suite ever running.

**Where** — `SKILL.md` Step 8, as a numbered terminal gate positioned before the
commit gate (so the suite is a precondition of committing, not a post-hoc check).

**Rejected suggestion** — none. The field report's diagnosis was verified against the
source before folding: Step 8 listed only install / commit / push / clean-tree, and no
other skill in the suite carried a "run the skill's own suite before commit" rule, so
this is a genuine gap rather than a cross-skill duplication.
