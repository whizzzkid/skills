---
class: one-off
---

# Record the copy button's transient label before clicking

**Scenario** — Stage 5 standup copy verification clicked the button, then read its label in a separate evaluate call.

**Symptom** — the label read `Copy`; `Copied ✓` and the payload could not be confirmed, so the check was unverified.

**Fix** — install a `MutationObserver` on the button and call-through clipboard spies in an evaluate call before the
click, then read the recorded states and payload afterwards (`references/standup-copy-block.md` → check 3).

**Why not promoted** — the 1.5 s reset is specific to this handler; the gate lives wholly in the reference file.
