---
class: principle
---

**Rule:** When a symptom's fix space splits into "add/produce/provision" vs
"disable/suppress" branches → surface the branch choice as a `[HUMAN-IN-LOOP]`
decision before implementing. The obvious make-it-work fix may violate the
component's role (a consumer-only service must never produce/create); confirm
which branch is legal before drafting.

**Why:** Diagnosing a log-error spike from unprovisioned topics, the first-draft
fix proposed provisioning/producing to them; the app is a pure consumer that
must never create or produce, so the whole approach had to be reshaped to
disabling the producing subsystem.

**Where:** wk-plan Step 0 ambiguity table ("Fix approach undetermined") +
"Fix-philosophy branch" note.
