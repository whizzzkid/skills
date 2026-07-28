---
class: principle
---

# Harness-defect triage: which artifact a red result indicts

Relocated from `SKILL.md` (Step 1) to hold the body under its size ceiling.
Content is unchanged — read this whenever a reproduction comes back red.

## Indict the tooling before the artifact

- A new case failing while every pre-existing case passes → indicts the **harness**, not the artifact.
- A failed positive control → indicts the **control**, not the artifact.
- Drive the artifact directly with the same input before believing either verdict.
- Fix the harness in the same pass as audit cleanup when the two disagree.

## Sourcing a needle and a control

- Needle from the **changed** span; control from an **untouched** one.
- Length-guard both — `len 0` is a defect, not a short needle.
- Rebuild a canary as a **literal the pattern matches** — expand metacharacters rather than
  trusting the pattern to fire.
- Never swap the prescribed primitive over a red result (restated inline; the swap hides the
  defect instead of locating it).

## Staging a payload past a guard that gates the agent's own tool calls

- Stage each test payload with the **file-write tool**, then feed it to the hook by redirect.
- The same shape composed inline in a shell call **is itself the blocked call** — it tests the
  guard against the wrong subject.
- Never reach for the guard's opt-out to run the test — it voids the result.

## Scope of any green

- Reproduction proves the mechanism only in the configuration it ran (restated inline).
- Enumerate what the fixtures held constant, then vary them — or name the held-constant
  configuration in the rule's trigger.
