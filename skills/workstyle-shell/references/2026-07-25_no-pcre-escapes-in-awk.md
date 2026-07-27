---
class: principle
---

**Rule** — Never use PCRE shorthand escapes (`\S`, `\s`, `\d`, `\w`, `\b`) in an `awk` or
POSIX-ERE pattern. Use bracket expressions instead — `[^[:space:]]`, `[[:space:]]`,
`[0-9]`, `[A-Za-z0-9_]` — or switch to `grep -E` / `perl` when genuine PCRE semantics are
required.

**Why** — POSIX ERE has no shorthand classes. Rather than erroring on the unknown escape,
`awk` treats it as the escaped *literal* character, so `type:[[:space:]]*\S` quietly
becomes "`type:`, whitespace, then a literal `S`". The pattern stays syntactically valid,
writes nothing to stderr, and exits 0 — it simply matches nothing. The failure is
therefore indistinguishable from a real, correct zero.

**Verified against source** — Driving `awk` directly: a fixture whose `type:` value is
`feedback` scores 0 with `\S` and 1 with `[^[:space:]]`; an input of `type: Sam` *does*
match the `\S` pattern, proving the escape degrades to a literal `S` rather than being
rejected.

**Corollary** — Because the failure is silent and status-0, never accept a filter's
zero/all-reject result without a positive control: feed one input known to match and
confirm the count moves.

**Where** — wk-workstyle-shell → Rules, adjacent to the `sed -i` and capability-probe
portability traps.
