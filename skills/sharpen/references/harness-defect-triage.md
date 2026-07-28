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

## A control for a staged-diff-triggered gate needs a real diff

Applies to any gate whose trigger is a staged **difference** — the common shape is a
guard clause of the form `[[ -z "$(git diff --cached --name-only …)" ]] && exit 0`.

- **Staging is not the trigger; a staged difference is.** `git add` of a blob whose content
  already matches the index produces no staged diff, so the gate exits at its guard without
  evaluating anything. The dead run is **byte-identical** to a real pass: rc 0, no output.
- So the obvious construction — "stage the inputs and run the gate" — is precisely what
  disarms the control. The natural build is the broken one.
- **Assert the trigger's own count before reading the verdict:**
  `git diff --cached --name-only | wc -l` must be non-zero against an expected population.
  A gate's exit code can never separate "evaluated and clean" from "never ran".
- **Introduce a semantically-null real difference** so the trigger fires while the property
  under test is untouched — append one trailing newline to each blob and stage that:

  ```bash
  for f in <paths>; do
    b=$(git hash-object -w --stdin < <(git show ":$f"; printf '\n'))
    git update-index --cacheinfo 100644,"$b","$f"
  done
  ```

  Do this in a throwaway index copy (`GIT_INDEX_FILE`), never the real one.
- **A control family is not verified by its members agreeing.** Where single-case arms are
  each built by mutating a blob and one repo-wide arm is built by staging unchanged files,
  the defect hits only the arm whose construction differs — so the agreeing majority is no
  evidence. Verify each arm's trigger count independently.

## Scope of any green

- Reproduction proves the mechanism only in the configuration it ran (restated inline).
- Enumerate what the fixtures held constant, then vary them — or name the held-constant
  configuration in the rule's trigger.
