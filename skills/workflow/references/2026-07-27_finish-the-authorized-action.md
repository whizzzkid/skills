---
class: principle
date: 2026-07-27
severity: medium
---

# Neither fresh feedback nor further analysis cancels an authorized action

**Rule** — Two Autonomy Rules rows and two stop conditions:

- Defect diagnosed and the owning file identified → **edit that file now**, do not
  re-state the tradeoffs again.
- Feedback lands mid-action → **finish the authorized action, then adjust**; do not
  acknowledge and stop with the action undone.
- A turn producing no new *facts* (no new file read, no new command output) must end in
  a write, not more prose.
- Volunteered feedback is not a stop signal, unlike a question the agent itself asked.

**Why** — Two learnings from the same session share one root cause, so they are folded as
one rule rather than two.

- The Autonomy Rules table enumerated only *permission* cases ("shall I commit?"). It had
  no row for the **analysis** case: the defect and its owning file are already known and
  further reasoning adds no information. Restating tradeoffs feels like diligence, so
  nothing in the skill stopped it — the user read it as going in circles ("why are you
  going around in circles?").
- Nor for the **feedback** case: after a process correction unrelated to the in-flight
  step, the agent acknowledged and stopped, leaving an already-approved action (posting a
  prepared pending review) undone until the user asked why it stopped. Correcting *how*
  the agent works does not revoke *what* it was told to do.

## Sited to defuse an adjacent contradiction

The new bullets sit immediately above the existing "when soliciting feedback, block on it
→ end the turn after asking" rule, and name the distinction explicitly ("unlike a question
you asked, below"). Placed anywhere else, the two would read as opposed advice about the
word "feedback" with nothing in the text to arbitrate — the agent asking a question must
block; the user volunteering a correction must not cause a block.

## Same-pass reclaim

Headroom was 92 B against a 568 B addition, so the trigger fired and net-non-positive was
owed. Reclaimed 601 B: the advisor bullet's inline restatement was cut against its
**linked** `advisor-tool.md`, which states every qualifier in full (235 B), and the
`Existing-gate preservation` bullet was relocated to the linked
`code-standards-extended.md` with its topic added to the pointer's list (394 B gross, 28 B
back). The addition was then tightened by 112 B rather than widening the hunt toward
load-bearing content. Net **−33 B** (24484 → 24451).

**Where** — `SKILL.md` → Autonomy Rules table (2 rows) and the feedback bullet above
"When soliciting feedback, block on it".
