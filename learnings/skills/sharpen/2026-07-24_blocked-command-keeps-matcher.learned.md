---
skill: wk-sharpen
date: 2026-07-24
type: correction
severity: medium
verified-against-source: yes
---

When a guard blocks the prescribed comparison, drop only the blocked part — substituting a
different matcher silently inverted a correctness check.

**What happened:** The Source 3 memory diff is prescribed as normalize-both-sides plus `comm`,
staging each side in a temp file. Run once that way it reported every memory already distilled
— correct. On the terminal re-scan the same command shape was refused by the repo's
path-scope guard, because the single compound command combined a recursive search with
out-of-repo scratchpad paths. Rewriting it as a per-file `grep -qxF "$path" <(...)` loop to
avoid temp files reported **all seven** memories un-distilled. Direct inspection of the marker
disproved that: six of the seven paths were present verbatim, and the file had no trailing
whitespace or CR to explain a mismatch. The existing "every memory un-distilled means format
mismatch, not backlog" rule is what caught it; without that rule the run would have
re-distilled six already-folded memories.

**Root cause:** The skill prescribes the matcher (`comm` over normalized, sorted lists) but not
what to preserve when the invocation is refused. Facing a block, the substitution optimized for
"no temp files" and changed the matcher at the same time, so a tooling difference in the
replacement became indistinguishable from a real backlog. The prescribed method's temp-file
staging is also the part most likely to attract a block, since scratchpad paths sit outside the
repo the guard defends — so the refusal is a recurring condition, not a one-off.

**Suggested fix:** State that a blocked or refused command is rewritten by removing only the
blocked element, never by swapping the comparison primitive — re-derive with the prescribed
matcher reading from in-repo paths or a here-string. Add that when a hand-rolled substitute and
the prescribed method disagree, the substitute is wrong until proven otherwise, and that the
disagreement is resolved by inspecting the underlying data directly rather than by trusting
whichever ran most recently. Never resolve a guard refusal by disabling the guard.
