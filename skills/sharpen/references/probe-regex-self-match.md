---
class: principle
---

**Rule** — When verifying that a `grep -iEf .skillprohibit` scan actually fires, do
not echo a raw `.skillprohibit` line back as the probe input. The lines are regexes;
a pattern containing `[]?*+` will not match itself as a literal string. Prefer a real
hit in the staged-file scan as the functional proof, or feed a plain-literal pattern
line / a literal expanded from a pattern (`a[-_]?b` → `a-b`).

**Why** — Feeding a regex pattern back as grep input tests literal-string equality
against the regex. Metacharacters in the pattern are literal in the input, so the
probe returns NONE even though grep is working — a false "grep broken" signal that
wastes a debugging cycle. The folded "source the probe from `.skillprohibit` itself"
rule silently assumed every pattern line doubles as known-positive sample text, which
holds only for plain-literal lines.

**Where** — Step 5, Mechanical overfit scan: the NONE-result verification bullet.

**Superseded (2026-07-24):** the probe class is retired for hook-covered scans — Step 5
executes `.githooks/*.sh` against the staged index instead of reimplementing the matcher.
