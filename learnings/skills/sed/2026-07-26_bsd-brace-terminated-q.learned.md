---
skill: wk-sed
date: 2026-07-26
type: surprise
severity: medium
verified-against-source: yes
---

BSD/macOS `sed` aborts the entire script when `}` directly terminates a `q`, so a frontmatter
extractor produced no output for any file and classified every memory as `neither`.

**What happened:** A memory-frontmatter extractor written as
`sed -n '1{/^---$/!q}; 1d; /^---$/q; p'` returned empty stdout for every input. The caller kept
only stdout (`body=$(fm "$f")` inside a per-file loop), so each file parsed as having no
frontmatter and fell into the `neither` bucket — a 100% all-reject. Because an empty Source 3
queue produces no visible work, nothing prompted an investigation; the batch read as drained.

**Root cause:** BSD `sed`'s `q` takes an optional exit-code argument, and the parser reads the
following `}` as trailing text of that argument, failing with
`extra characters at the end of q command` (rc=1) before processing any input. GNU `sed` accepts
the spelling, so the same script passes on Linux CI and fails only on macOS.

**Correction to the obvious reading:** the trigger is *not* "`q` inside `{}` followed by further
commands". Driving BSD `sed` directly: `sed -n '1{/^---$/!q}'` with nothing after the block fails
identically (rc=1), while `1{/^---$/!q;}`, the newline-separated form, and a top-level `q` with
following commands all return rc=0. The trigger is `q}` adjacency alone.

**Suggested fix:** Terminate the command with `;` or a newline inside the brace —
`sed -n '1{/^x$/!q;}'` — and prefer `awk` for frontmatter/range extraction outright.

**Divergence from the `awk` siblings:** the two known `awk` silent-zero traps (PCRE shorthand
escapes; `END{exit N}` overriding a rule-body status) are silent *at the tool* — valid program,
empty stderr, status 0. This one is loud at the tool and silenced only by the **call site**
discarding status and stderr via `$( )`. A positive control catches the `awk` pair; catching this
additionally requires branching on the exit status. Caught here only by per-shape canaries, which
scored 0 under the broken extractor and flat=4 / nested=3 under the corrected one.
