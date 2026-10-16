---
class: principle
---

# A denied canary falls back to the owning hook, never to silence

**Rule** — when the auto-mode classifier denies the Step 3 in-memory canary, run `.githooks/check-prohibited.sh`
against the staged fold as the proving gate and record "canary denied; hook-proven". Never treat an unproven rc=1 as
clean, and never write the canary to a file to get around the denial.

**Why** — the subject scan returned rc=1, then the canary (`printf '<expanded term>' | command grep -f`) was denied,
leaving the zero unproven with no named next step. Root cause is inferred, not verified: the classifier likely reads a
prohibited term piped into grep as a denylist bypass. The canary is not always denied — a later run executed it
cleanly — so the fallback is a fallback, not a replacement.

**Where** — `SKILL.md` → Step 3 → prohibited-subject gate HARD RULE.
