---
class: principle
---

# De-bloat preservation is verified mechanically, never self-reported

**Rule**

- After any de-bloat or compression pass, gate on the per-skill HARD RULE count across `SKILL.md` + `references/`
  (`.githooks/check-hard-rules.sh`), then phrase-audit each pre-edit rule — label and every clause — against the
  post-edit text.
- A sub-agent's "all rules preserved" report is a claim to verify, never evidence.
- A repeated section that invokes another skill (Post-Completion `wk-learn`) is a runtime trigger, not boilerplate.
  Delete it only when its replacement ships in the same commit.

**Why**

- Compression sub-agents reported every HARD RULE intact while labels fell to zero in several skills and some clauses
  vanished. A cross-cutting pass judged the Post-Completion trigger "boilerplate" by repetition and deleted it suite-wide,
  disabling learning capture.
- The count hook catches label loss only; a later compaction of this skill's own Post-Completion kept the trigger but
  dropped its loop-worker exception — a clause loss no count detects. Restored in the same fold.

**Where**

`skills/sharpen/SKILL.md` → Step 7.5 de-bloat HARD RULE; Post-Completion.
