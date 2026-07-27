---
skill: wk-awk
date: 2026-07-25
type: surprise
severity: medium
verified-against-source: yes
---

In `awk`, an `END { exit N }` overrides the status of an earlier `exit` in a rule body, silently
inverting a per-file predicate.

**What happened:** A predicate classifying files by frontmatter was written as
`… {ok-condition; exit 0} END {exit 1}` — "exit 0 the moment the file qualifies, otherwise exit 1
at end of input". It reported *every* file as failing, including files that plainly qualified. The
all-reject result looked like a real (and alarming) finding about the input set rather than a
broken predicate.

**Root cause:** `exit` inside a rule body does not terminate the program — it stops reading input
and **jumps to the `END` block**. `END` then runs `exit 1`, and that status replaces the 0. The
qualifying branch and the failing branch therefore converge on the same exit status. Confirmed by
driving `awk` directly: `printf 'a\n' | awk '{exit 0} END{exit 1}'` returns rc=1.

**Suggested fix:** Never encode the verdict in the rule body's `exit` argument when an `END` block
also exits. Set a flag and let `END` compute the status:

```awk
/qualifies/ { ok = 1; exit }      # exit == stop reading, then fall into END
END         { exit !ok }
```

This is the second distinct *silent zero* mechanism in `awk` (the first: PCRE shorthand escapes
degrading to escaped literals). Both yield a syntactically valid program, no stderr output, and a
confidently wrong all-reject result — which argues for a dedicated `wk-awk` skill, since two
non-obvious findings now exist for this tool and both are invisible without a control.

**Corroborating note:** a positive control caught this in one step — the same filter scored 0 files
with the broken form and 7 with the corrected one. The requirement to move a control's count before
believing a filter's zero is load-bearing, not ceremonial.
