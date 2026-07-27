---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A drift-check recount that extracts a section by range can over-count while its
known-member control still passes — liveness proves the probe fires, never that
it stayed inside the intended section.

**What happened:** The Step 7 drift check recounted a skill's documented agent
roster ("Launch 5 agents in parallel") with a range probe anchored on the stage
heading. It returned 17 against a documented 5. The prescribed control passed:
the probe visibly fired on known-present members (the first roster entries
printed correctly), so the "prove it fires on a known member" tripwire was
satisfied while the number was still wrong. The heading occurs twice in the file
(the same stage name under two sub-commands), so the range restarted at the
second occurrence and ran past the intended section, sweeping in bullets from
unrelated blocks. A re-scoped probe that selected the Nth occurrence explicitly
returned the correct 5 and 7.

**Root cause:** The existing recount rule guards *shape* and *liveness* — the
probe must match the source markup and be shown to fire — and its stated failure
signal is a zero ("mismatch → 0 = phantom drift"). Both guards are one-directional.
A live, correctly-shaped probe whose **range** is unbounded over-reports, and no
part of the rule bounds the extent of what the probe consumed. Worse, the control
actively reassures: a member printed from inside the intended section is
indistinguishable from one printed by a probe that also spans three sections
after it. Verified against source by driving both probe forms over the file.

**Suggested fix:** Extend the recount rule so a range-based probe must have its
anchor proven **unique** before the count is trusted — count the anchor's
occurrences first, and select an occurrence explicitly when it repeats. Add the
missing direction to the tripwire: an over-count is as much a probe defect as a
zero, and a passing member control cannot distinguish the two. Where cheap,
prefer printing the matched members and confirming each belongs to the intended
section over trusting a bare count, since a count discards exactly the evidence
that would expose the over-run.
