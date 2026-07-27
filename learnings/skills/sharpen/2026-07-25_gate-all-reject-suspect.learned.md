---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

Source 3's parse-as-memory gate has no all-reject sanity check, so a broken gate reads as a clean drain.

**What happened:** A batch run's parse-as-memory gate rejected all nine files in the memory
directory — zero classified as memories. The matcher was at fault, not the files (a PCRE escape
unsupported by the matcher). Had the run trusted it, Source 3 would have reported "no memories to
process" and the queue would have looked drained. The failure is worse than a false backlog: it is
a false *empty*, which produces no visible work and therefore no prompt to investigate.

**Root cause:** The reference already warns that an all-un-distilled result at the **marker diff**
is a probable format mismatch rather than real backlog. The parse gate was added later, ahead of
that diff, and inherited no equivalent check. The two stages have symmetric failure modes with
only one of them guarded — and they fail in opposite directions, so the existing warning does not
generalize by analogy: all-un-distilled over-reports work, all-reject under-reports it.

**Suggested fix:** Extend the all-or-nothing sanity check to both stages and both directions in the
Source 3 guidance:

- Gate rejects *every* candidate → suspect the matcher, not the files. Confirm by driving it against
  one input known to parse before believing the zero.
- Diff shows *every* item un-distilled → suspect a path-format mismatch (already covered).

State the general form: at any stage of Source 3, a unanimous verdict in either direction indicts
the tooling first. Require a positive control before a zero from a hand-rolled filter is allowed to
close out a source — an unverified zero is indistinguishable from a real drain.
