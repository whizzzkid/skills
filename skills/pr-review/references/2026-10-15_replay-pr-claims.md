---
class: principle
---

# Replay a PR description's empirical claims; never read them as true

**Rule**

- Treat every empirical claim in a description (mutation results, test counts, gating behavior, "fails without the
  fix") as Unverified until replayed in a detached scratch worktree.
- Check the merge state of every related PR the description calls pending or "lands first"; a merged sibling can turn
  a predicted follow-up into a required step.
- Tee full test output to a log file instead of keeping only the last line; rerun a bare FAIL before reporting it.

**Why**

- The skill already distrusted spec-doc claims but not the author's own evidence. A replay confirmed most claims and
  still surfaced a sibling PR that had merged since the description was written.
- A full-suite run printed a bare FAIL that vanished on rerun; a `tail -1` capture leaves nothing to diagnose it with.

**Where** — `SKILL.md` → Phase 1 → Claims bullet (sub-bullets).
