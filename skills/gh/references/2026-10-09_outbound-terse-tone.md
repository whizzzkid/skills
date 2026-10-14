---
class: principle
---

# Outbound comment bodies: state the point, add nothing else

**Rule**

- Every comment surface posted for the user (review bodies, inline comments, replies, conversation comments) leads
  with the point: verdict, answer, or action.
- No pointers to content GitHub already shows beside the body, no evaluative filler, no recap of what was checked.
- Top-level bodies default to one line; one short sentence more only per point with nowhere else to live.
- Calling skills inherit this; their templates may be stricter, never looser.

**Why**

- The canonical write surface and footer were defined here, but nothing governed length or tone, so each caller set
  its own verbosity and their templates leaned wordy. The user cut a verdict-plus-pointer-plus-praise body to the
  verdict alone.

**Scope decision**

- PR and issue descriptions are excluded: their owning skills carry structured templates (summary, test plan) that
  are not comment bodies.

**Where**

`skills/gh/SKILL.md` → Step 3 terse-body HARD RULE.
