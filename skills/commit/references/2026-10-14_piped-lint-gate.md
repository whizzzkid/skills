---
class: principle
---

# Never pipe a validation gate before `&& git commit`

**Rule**

- Redirect a gate's output to a file and branch on its captured exit status, or `set -o pipefail`; never place a pipe
  between the gate and `&& git commit`.

**Why**

- `<linter> files | tail -1 && git commit ... && git push` committed and pushed a lint offense: without `pipefail` a
  pipeline's status is the last stage's, and `tail` always exits 0. Truncating output for brevity discarded the
  verdict.
- Re-violation of the fail-fast chain rule in `staging-discipline.md`; escalated one rung by surfacing it as an
  `Important` bullet in `SKILL.md`.

**Where**

`skills/commit/SKILL.md` → Hook and verify rules.
