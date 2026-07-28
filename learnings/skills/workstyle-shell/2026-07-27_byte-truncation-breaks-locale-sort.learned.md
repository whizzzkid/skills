---
skill: wk-sort
date: 2026-07-27
type: surprise
severity: medium
verified-against-source: yes
---

`sort: Illegal byte sequence` (rc 2) means an upstream stage cut a multi-byte character in half
— not that the input "contains UTF-8".

**What happened:** A diagnostic pipeline that ranks a file's lines by byte length aborted with
`sort: Illegal byte sequence` and produced no output. The producing stage was
`LC_ALL=C awk '{ printf "%5d %5d %s\n", NR, length($0)+1, substr($0,1,95) }'`, piped to a plain
`sort -k2 -rn`. The obvious reading — "the file has non-ASCII characters and `sort` dislikes
them" — is wrong.

**Root cause:** Verified by isolating the variable rather than by the workaround succeeding:

- Well-formed UTF-8 through an unpinned `sort` → rc 0. So UTF-8 presence is not the trigger.
- A deliberately truncated multi-byte sequence through the same `sort` → rc 2. That is the
  trigger.

`LC_ALL=C` makes `awk`'s `length()` and `substr()` operate on **bytes**, which is exactly why it
is pinned for byte-accurate measurement. But `substr($0,1,95)` then slices at byte 95, which can
land in the middle of a multi-byte character and emit a malformed prefix. The downstream `sort`
runs under the ambient UTF-8 locale, validates its input as characters, meets the orphaned
continuation byte, and hard-fails. The two stages disagree about what a "character" is, and the
truncation is where that disagreement becomes an invalid byte.

Pinning `LC_ALL=C` on `sort` resolves it because C-locale `sort` compares bytes and never
validates encoding — it does not repair the malformed output, it declines to inspect it.

**Suggested fix:** Read `Illegal byte sequence` as "some upstream stage emitted invalid encoding",
then look for a byte-oriented truncation, not for non-ASCII input. Two correct responses,
depending on intent:

- Comparison should be byte-wise anyway (ranking, diffing, `comm`/`join`/`uniq` against a
  C-sorted list) → pin `LC_ALL=C` on the consumer too, so the whole pipeline agrees on bytes.
- Output is meant to be read by a human → truncate on character boundaries instead of bytes, or
  do not pin the producer to `C` for the display field while keeping it pinned for the measured
  field.

Generalizes past `sort`: any locale-aware consumer (`grep`, `sed`, `tr`, `uniq`) can reject the
same malformed stream, and the diagnostic points at the consumer while the defect is in the
producer's slice width.
