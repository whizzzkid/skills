---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

A Drift-check recount used a probe whose list shape did not match the source's, returning
zero and manufacturing phantom drift against a claim that was in fact correct.

**What happened:** The Drift check requires recounting any documented set whose size may
have changed. `SKILL.md` claimed an "8-rung" ladder. The recount probe counted
bullet-prefixed lines (`grep -c '^- '`) against the linked reference and returned **0** —
apparently contradicting the claim outright. The reference in fact lists the rungs as a
**numbered** list (`1.`–`8.`), which the bullet-shaped probe cannot match. Reading the
source showed the documented count was accurate and there was no drift at all.

**Root cause:** the existing rule states only where a count must come from — "recount from
source, never increment" — and says nothing about proving the counting probe can return a
non-zero against that source. A probe whose pattern shape does not match the source's
actual markup (numbered vs bulleted vs table rows vs headings) returns a confidently wrong
number, and that number is indistinguishable from a genuine drift finding. This is the same
failure the skill already guards elsewhere — a hand-rolled zero is unverified until the
probe is proven to fire — but that guard is scoped to the denylist and staged-path scans
and does not reach the Drift-check recount.

**Why it matters:** the failure is bidirectional and silent. A false zero invents drift and
invites an "correction" that edits a correct claim into an incorrect one; a probe that
matches the wrong construct can equally return a plausible-but-wrong count that hides real
drift. Either way the recount ships with the authority of a measurement.

**Suggested fix:** extend the Drift-check recount rule so a recount is only trusted once
the probe is shown to return a non-zero against the source — read the source's list markup
first and shape the probe to it, or prove the probe fires on a known-present item, before
treating any count (especially zero) as evidence of drift.
