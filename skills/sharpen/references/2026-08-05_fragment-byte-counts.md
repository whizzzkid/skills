---
class: principle
---

# Byte ledgers use byte-counted fragments

**Rule** — Price every draft and replacement fragment with `LC_ALL=C wc -c`; never use shell character length.

**Why** — Multibyte punctuation makes character counts diverge from the byte counts used by the size ceiling and hook.

**Where** — Step 7.5 running byte ledger.
