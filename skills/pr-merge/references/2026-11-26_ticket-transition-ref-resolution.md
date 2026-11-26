---
class: one-off
---

# Step 7 ticket-transition reference reported missing

**Scenario** — On an already-merged PR the run jumped to Step 7 and tried to read the ticket-transition reference the
step links to; the read returned file-not-found, so the transition followed the Jira skill's rules instead.

**Symptom** — The report concluded the reference was never shipped, moved, or renamed.

**Fix** — None to the skill. Verified against source: the reference is tracked, has shipped since mid-2026, and is
present in every installed runtime copy. The probable cause is resolving the skill-relative link against the session's
working directory (the target repo) instead of the skill's base directory. Resolve every `references/` link in a skill
body against the skill's base directory.

**Why not promoted** — The file exists, so the reported root cause is disproved. The suggested "check every referenced
path resolves" is rejected as a new gate: forward-link and reference-orphan hooks already cover the repo, and the
failure was a runtime path-base slip that no single skill's text owns. Promote to a cross-skill rule if the same
CWD-relative miss recurs.
