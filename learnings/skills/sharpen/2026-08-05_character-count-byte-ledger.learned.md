---
skill: wk-sharpen
date: 2026-08-05
type: correction
severity: medium
verified-against-source: yes
---

Price every skill-body ledger with byte counts, including pre-draft fragments.

**What happened:** A pre-draft ledger used shell string lengths for text containing multibyte punctuation. The exact
staged parser later found a different body size.

**Root cause:** Character counts were treated as byte counts even though the skill ceiling and owning hook measure
bytes under `LC_ALL=C`.

**Suggested fix:** Measure every draft and replacement fragment with a byte-counting command under `LC_ALL=C`; never
use locale-sensitive shell string length in byte-ledger arithmetic.
