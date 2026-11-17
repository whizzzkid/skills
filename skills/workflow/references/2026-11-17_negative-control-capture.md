---
class: principle
---

- **Rule** — A negative control that stays green (a test that passes with the fix defeated) is a self-caught error:
  invoke live capture in the response where the control fails to fail.
- **Why** — A vacuous regression spec was rewritten on the spot, but the learning surfaced only at the retro scan. The
  trigger list named corrections and verifier refutations; a control that "fails to fail" read as routine test
  iteration rather than an "I was wrong" moment.
- **Where** — `SKILL.md` Mandatory Activation, live learning capture HARD RULE (self-caught error examples). Reported
  against `wk-learn`; the trigger list it names lives here.
