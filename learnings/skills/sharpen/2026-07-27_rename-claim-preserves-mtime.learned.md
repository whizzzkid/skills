---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

An mtime-based ownership test cannot see a peer that claims inbox items by renaming them.

**What happened:** A batch run opened with the prescribed ownership check on an
inbox of ~20 unprocessed learnings. Both currently-prescribed signals cleared
every item as owned and safe to fold: each file's mtime predated the run's
start by hours-to-days, and commit recency was cold (newest commit several days
old, `.git/index` likewise stale). Roughly one minute later, a second scan of
the same directory returned zero unprocessed files — a concurrent run of the
same skill had renamed all of them to `.learned.md` in the interval. Had the
run trusted the first check, it would have folded items another run had already
claimed, double-editing a shared `SKILL.md` and entangling a shared index.

**Root cause:** `mv` preserves mtime and updates only ctime, and the skill's
processed-state marker *is* a rename. So the one action that transfers
ownership is invisible to the signal used to test ownership — the claim leaves
mtime exactly as the unclaimed file had it. Commit recency does not compensate:
a peer mid-fold has not committed yet by definition, so a cold log is the
expected reading during precisely the window when collision risk is highest.
Both prescribed signals are structurally blind in the same direction, so their
agreement carries no information.

**Suggested fix:** Do not treat a single mtime + commit-recency reading as
resolving ownership. Corroborate with signals that a rename actually moves:

- Compare ctime against the run's start, not only mtime — a ctime that
  postdates run start on an inbox file means someone touched its directory
  entry, which for this inbox means a claim.
- Re-scan the inbox listing immediately before folding each item and diff it
  against the opening listing; a shrinking unprocessed set proves a live
  concurrent writer regardless of what any timestamp says.
- Treat cold commit recency as no evidence rather than as evidence of
  exclusivity, since an uncommitted peer fold is the collision case.
- Terminal state stays "processed N, M unclaimed arrivals" — a set that
  emptied underneath the run was claimed, never drained by it.
