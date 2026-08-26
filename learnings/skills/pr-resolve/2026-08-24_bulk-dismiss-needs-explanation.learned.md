---
skill: wk-pr-resolve
date: 2026-08-24
type: gap
severity: medium
verified-against-source: n/a
---

The all-Minor bulk-dismiss gate must show each finding's substance before offering the bulk choice, not just a count.

**What happened:** Three new Minor bot findings appeared after a push. The agent presented the bulk-dismiss gate as "(a) dismiss all (b) triage individually" without describing what any of the three findings actually were. The user rejected the shortcut: "they are minor, but what are those? aren't you supposed to triage those and validate what those mean?" The agent then gave full individual analysis (mechanism, why-fix, why-skip) for each finding before the user approved proceeding.

**Root cause:** The bulk-dismiss gate optimizes for skipping ceremony (per the prior learning that added it) but conflated "skip the per-item confirmation loop" with "skip explaining the findings." A count-only prompt reads as the agent not having actually looked at the findings.

**Suggested fix:** The bulk-dismiss gate prompt should always render each finding's one-line summary (what it flagged, file:line) before the (a)/(b) choice — even though the *decision* is still bulk. Never present a bare "N Minor findings, dismiss all?" with no substance.
