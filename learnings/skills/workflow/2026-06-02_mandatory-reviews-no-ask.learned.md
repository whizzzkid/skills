---
skill: wk-workflow
date: 2026-06-02
type: correction
severity: high
---

Pre-flight review findings (adversarial-review, arch-review) are mandatory actions, not options.

**What happened:** The agent ran wk-arch-review and wk-adversarial-review as required
gates but then asked the user "should I incorporate these findings?" before acting. The
user clarified these are mandatory — findings are always incorporated without asking.

**Root cause:** The workflow treats pre-flight reviews as gates that produce findings,
but leaves the incorporation step as a user-gated decision. This is wrong: if the review
is mandatory, incorporating its output is also mandatory.

**Suggested fix:** In Phase 4 (adversarial review) and any arch-review pass:
- Blockers: fix immediately, commit via wk-commit, re-run the gate.
- Improvements/gaps: incorporate into the artifact (code or doc), commit.
- Design-ambiguous findings: present the specific design question once, wait for answer,
  then act.
Never frame the incorporation step as optional or user-gated. The only pause is for
a genuine design decision the user must make — not for "should I update this?".
