---
class: principle
---

**Rule:** During playground validation, do not re-run the project's existing test
suite for general correctness — CI is the authoritative source for suite
pass/fail. Spend local effort adversarially driving the change's failure paths
(timeouts, exhausted retries, malformed/partial responses, degraded
dependencies, non-zero exits) and observing real behavior. Running one targeted
test to reproduce a specific suspected defect is fine.

**Why:** A green local suite duplicates what CI already runs and shows nothing the
author didn't see; a red local run is often environmental (wrong interpreter,
missing service), risking a misclassified "PR defect." The suite tests the
author's happy paths, not the failure modes the change introduces.

**Where:** Step 5 Playground Validation.
