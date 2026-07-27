---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

The Step 3 prohibited-subject bullet never names the grep direction, so the gate can be
implemented inverted — and inverted it is silently permissive.

**What happened:** Step 3 says to `command grep` the learning's core subject term "against"
the denylist. Read plainly, that phrasing puts the denylist on the receiving end of the
grep, so I ran the file as the haystack with my subject as a literal needle
(`command grep -qi -- "$term" <denylist>`). Every subject term scanned clean. The denylist
holds **regexes**, so a literal needle can match only the rare plain-literal line — the
clean verdict was a dead zero, not a result.

The skill's own mandated canary caught it: expanding a denylist pattern of shape
`a[-_]?b` to the literal `a-b` and feeding it through the same invocation produced no
match, proving the gate could not fire at all. Re-running with the denylist supplying the
patterns (`printf '%s\n' "$subject" | command grep -qiE -f <denylist>`) made the canary
fire immediately, and the real subject scan then returned a trustworthy clean.

**Root cause:** "grep X against Y" does not fix which operand is the pattern source. Step 5's
staged-scan bullet resolves the ambiguity by naming the flag (`grep -iEf <denylist>`), but
the Step 3 bullet, written later and read first, does not — so the two gates over the same
file are specified at different precision, and only one of them is unambiguous.

The asymmetry is what makes this dangerous. A pattern-file gate inverted into a
literal-needle grep fails *open*: it returns success and a clean verdict, so nothing in the
run signals a problem. Only the canary distinguishes it, and the canary is a separate bullet
a run under budget pressure may treat as ceremony.

**Suggested fix:** State the direction in the Step 3 bullet itself — the subject text is the
input, the denylist supplies the patterns via `-f`. Naming the flag inline (as Step 5
already does) removes the ambiguity at the point of use rather than relying on the canary to
detect a wrong reading after the fact. Consider also stating once, where the denylist is
first introduced, that it is a pattern file and never a haystack; both gates then inherit the
same direction from a single statement.
