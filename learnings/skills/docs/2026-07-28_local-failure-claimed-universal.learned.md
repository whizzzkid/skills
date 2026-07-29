---
skill: wk-docs
date: 2026-07-28
type: correction
severity: medium
verified-against-source: n/a
---

A plan doc recorded a locally-reproduced check failure as "known broken", and the claim was false everywhere else.

**What happened:** One check failed on the developer's machine due to a local browser/tooling version pairing. The plan doc was updated to declare the check broken and it was excluded from required status checks. The check then passed on its first CI run, so the doc, the acceptance criteria, and the protection config all had to be corrected — and a first correction pass left stale phrasing ("advisory only", "cannot pass") behind in two other spots.

**Root cause:** A single-environment observation was written in the declarative universal voice. Nothing in the doc flow requires stating *where* a failure was observed, so an environment-specific symptom got recorded as a property of the check itself.

**Suggested fix:** Require any recorded failure claim to name the environment it was observed in ("fails on this machine with X; unverified in CI") until at least two environments agree. When correcting such a claim, grep the whole document for every phrase the old verdict justified — the verdict sentence is rarely the only place it leaked.
