---
skill: wk-testing-skeleton
date: 2026-08-07
type: correction
severity: medium
verified-against-source: yes
---

Mutation verification must select the intended behavioral example by description, not a stale line number.

**What happened:** A mutation run targeted a nearby passing example, so the command succeeded without exercising the
mutated behavior.

**Root cause:** Location filters drift as tests are inserted or removed; the test runner confirmed it selected a
different example, but a bare green exit could have been mistaken for mutation evidence.

**Suggested fix:** Require mutation checks to verify the selected example name in runner output, and prefer exact
example-description filters over source line numbers.
