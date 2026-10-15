---
class: principle
---

# Quote observed traffic before a fail-closed step

**Rule**

- Before planning a step that rejects on a missing or invalid input, look up the existing fallback metric or log for
  that condition and quote its real-world rate per environment. High rate → make it safe now and file the upstream fix
  as a separate follow-up.

**Why**

- A handoff said to reject identities lacking a token claim because the spec made the claim mandatory. The rejection
  path already emitted a metric; querying it showed the claim missing on nearly every login in a deployed
  environment, so the step would have locked out all users. The history of an earlier fix explained why: the identity
  provider's client omitted the claim.

**Where**

`skills/plan/SKILL.md` → Step 0 → Is-a-fix-warranted gate → reject/fail-closed sub-bullet.
