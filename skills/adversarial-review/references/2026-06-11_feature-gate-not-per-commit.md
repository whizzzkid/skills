---
class: principle
---

- **Rule** — Run the gate once on the complete feature before the publishing
  push; on later pushes scope sweeps to the diff since the cleared SHA, not
  the full branch surface.
- **Why** — Reviewing each partial commit of a multi-site change turns one
  pass into a slow commit→review→fix loop that rediscovers the next
  unimplemented site every round; re-sweeping already-cleared code is waste.
- **Where** — Mandatory Activation: "per-feature gate, not per-commit" + "Scope
  a re-review to the new diff" (uses the existing `.cleared-{SHA}.json` record).
- **Source** — distilled from a high-severity workflow learning (adversarial
  review ran 3× across 5 commits for one logical change).
