---
class: principle
date: 2026-07-27
severity: medium
---

# `Illegal byte sequence` indicts the producer's slice width, not the input

**Rule** — Read `sort: Illegal byte sequence` as "some upstream stage emitted invalid
encoding", then look for a byte-oriented truncation — not for non-ASCII input. Fix by
intent: pin `LC_ALL=C` on the consumer when the comparison is byte-wise anyway, or slice
on character boundaries when the output is for a human.

**Why** — `LC_ALL=C` makes `awk`'s `length()` and `substr()` operate on **bytes**, which is
exactly why it is pinned for byte-accurate measurement. But `substr($0,1,N)` then cuts at
byte N, which can land mid-character and emit a malformed prefix. The consumer runs under
the ambient UTF-8 locale, validates its input as characters, and hard-fails on the
orphaned continuation byte. The two stages disagree about what a "character" is, and the
truncation is where the disagreement becomes an invalid byte. Pinning `LC_ALL=C` on the
consumer works because C-locale comparison is byte-wise and never validates encoding — it
does not repair the malformed output, it declines to inspect it.

## Reproduced, with the variable isolated

Not confirmed by the workaround succeeding — that can pass for the wrong reason. Three
arms over the same fixture (a line containing `→`, `LANG=en_US.UTF-8`):

- Well-formed UTF-8 → unpinned `sort`: **rc 0**. UTF-8 presence is not the trigger.
- `substr($0,1,5)` cutting the 3-byte sequence after 2 bytes → the *same* unpinned `sort`:
  **rc 2**, `Illegal byte sequence`. That is the trigger.
- The same truncated stream → `LC_ALL=C sort`: **rc 0**.

`od -c` confirmed the orphaned `342 206` in the truncated stream, so the failing arm was
provably malformed rather than empty.

## Report's generalization corrected

The report claimed "any locale-aware consumer (`grep`, `sed`, `tr`, `uniq`) can reject the
same malformed stream". **Partly disproven** on BSD/macOS userland: driving all five over
the identical truncated file, only `sort` (rc 2) and `tr` (rc 1) rejected it — `grep`,
`sed` and `uniq` returned rc 0 and passed the malformed bytes straight through. So the
inline rule names the two that fail, names their differing exit codes (a caller branching
on rc needs both), and states the sharper consequence the report missed: a clean run
through `grep`/`sed`/`uniq` is **no proof** the stream is well-formed — the corruption
merely moves downstream. The rule carries the `BSD/macOS` qualifier because that is the
only configuration the reproduction covers.

A first pass at this probe ran `awk` against a relative path from the wrong directory, so
every consumer read an empty file and all five returned rc 0 — a unanimous clean result
that proved nothing. Re-run with absolute paths and a non-empty assertion on the fixture.

## Routing and same-pass reclaim

Filed as `skill: wk-sort`; no such skill exists, so it was routed by subject to
`wk-workstyle-shell`, which owns shell text-pipeline mechanics and had **no** locale
coverage at all. Headroom was 72 B against a 641 B addition. Reclaimed 653 B: the
`ENVIRON[]` bullet's rationale and worked example were relocated behind a cut-site pointer
(483 B) — which also makes that reference *linked* for the first time, so it now proves
coverage — and the capability-probe rule's vendor-wording rationale was cut against the
already-linked bash-3.2 reference that states it (170 B). Both imperatives stay inline.
Net **−12 B** (24504 → 24492).

**Where** — `SKILL.md` → Rules, contiguous with the `awk` traps.
