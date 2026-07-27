---
skill: wk-sharpen
date: 2026-07-25
type: correction
severity: medium
verified-against-source: yes
---

The stated justification for "never reimplement the hook's matcher" — that comment lines
in the pattern file match every markdown heading — is false for the actual pattern file,
which weakens a CRITICAL rule for anyone who checks the reason against the source.

**What happened:** During the Step 5 scan a hand-rolled `grep -iEf <denylist>` over the
edited files returned zero hits. Knowing the skill warns that `#` comment lines in the
pattern file "match every markdown heading", the zero was treated as a suspected
false-clean and investigated. Driving the real file disproved the warning: the denylist's
comment lines are full English sentences (`# Prohibited terms — ... one per line.`), and
as EREs those match only their own literal text, not `# Title` or `## Section`. Confirmed
directly — a heading fed to `grep -inE -f <denylist>` did **not** fire, while a real
listed term did. So the zero was genuine, and the predicted noise cannot occur with this
file's contents.

**Root cause:** The rule's "fails in both directions" rationale generalizes from the
*possibility* that a pattern file carries bare `#` comments to a claim about the file this
repo actually ships. Only the second stated mechanism (a probe token taken from the first
line self-matches, yielding a false-clean) holds here. The conclusion — run the owning
hook — is still correct, but it now rests on a reason a reader can falsify in one command.

**Suggested fix:** Restate the justification as conditional rather than asserted: a
foreign matcher *may* mis-handle the pattern file (bare `#` comments, PCRE inline flags),
and you cannot tell which failure applies without checking — so run the hook instead of
auditing the denylist's comment style. Emphasize the false-*clean* direction as the
governing risk (a hand-rolled zero is unverifiable) rather than the noise direction, which
this file cannot produce. A rule whose cited mechanism is refutable against the source
invites an agent to conclude the hand-rolled scan is safe.
