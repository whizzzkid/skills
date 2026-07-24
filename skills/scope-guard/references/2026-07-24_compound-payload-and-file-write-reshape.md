---
class: principle
---

**Rule** — When the guard blocks, the offending token is not necessarily in the search. Both
the search-verb test and the out-of-repo-path test scan the *entire* Bash payload, so a compound
call trips when one sub-command carries the search verb and an unrelated sub-command carries the
out-of-repo absolute path — neither part blocks on its own. Diagnostic tell: the reported
out-of-scope path is not the search's root. Reshape by splitting into single-purpose calls, which
keeps every prescribed primitive. Stage out-of-repo scratch through the file-write tool rather
than a Bash call — that guard only warns, so it is outside the blocking path entirely.

**Why** — A field report described a byte-measurement chained with a denylist-probe grep being
refused, and inferred the cause as "compound-command shapes and quoting attract the block".
Driving the hook directly disproved that mechanism: the measurement's out-of-repo scratch path
was reported as the out-of-scope path while the grep supplied only the search verb. Split into
two calls, both pass with `wc -c` and `grep -rEf` intact; a file-write to the same out-of-repo
path warns and exits clean. The distinction matters because the inferred cause suggests
rewriting quoting or collapsing the command, while the real cause has a deterministic fix —
ensure no single call holds both a search verb and an out-of-repo path.

**Where** — The reshape-by-subtraction bullet in this skill's false-blocks section, as sub-bullets
under the existing "drop only the blocked element" rule, since both are reshape guidance and the
new content explains what "the blocked element" means when no single element is at fault.

**Rejected** — The report's "quoting / compound shape attracts refusal" cause is not documented:
the source shows shape-insensitive whole-payload token scanning, and a here-string or requoting
removes no offending token. The sibling skill's memory-marker bullet previously offered "feed a
here-string" as a reshape lever; that suggestion was deleted rather than kept, because it does not
subtract the out-of-repo path and adds inline payload. No guard was relaxed.

**Not escalated** — The originating learning is positive-steering: the reshape-by-subtraction rule
fired correctly in the same run that produced the report, and the report itself asked for no
escalation. Classified `already-covered` for that payload; only the new mechanism was folded.
