---
skill: wk-sitrep
date: 2026-10-23
type: pattern
severity: low
verified-against-source: n/a
---

An inline jq generator fed by two heredocs builds the whole live page without any script file.

**What happened:** The page generator was passed as the jq program via a command substitution around a quoted heredoc,
and the item data came in on stdin from a second quoted heredoc. The standup copy-button markup was lifted from the
previous page with grep rather than retyped. The output went straight to the live file; the 66-item page rendered
correctly on the first check. A later patch (recording auto-launched reviews) replaced one placeholder line using
shell parameter substitution on the file contents, which avoids awk/sed backslash mangling of `\#`.

**Root cause:** Not a failure. The write-scope rule forbids helper files outside the sitrep directory, so an inline
program plus stdin data is the only compliant way to generate spans reliably. A smoke test with empty data also
confirmed the program before the real run; a scratch output file written inside the sitrep directory for that test
must be deleted immediately.

**Suggested fix:** Document the two-heredoc jq shape in the generation guidance, plus the rule that the placeholder
Auto-Actions line is replaced in place (not appended) when review launches are recorded.
