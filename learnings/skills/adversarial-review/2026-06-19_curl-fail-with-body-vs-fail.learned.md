---
skill: wk-adversarial-review
date: 2026-06-19
type: gap
severity: medium
---

curl `--fail` suppresses response body before writing to `-o` on HTTP errors

**What happened:** A debug affordance was added to capture Cloudsmith's response
body on publish failure — the script used `mktemp` to create a response file,
passed it via `-o`, and `cat`'d it in the `||` error block. However, the curl
invocation still used `-f`/`--fail`, which exits with status 22 before writing
anything to the `-o` target on HTTP 4xx/5xx. The `cat` call always emitted an
empty body on the exact failure cases the debug was intended for.

**Root cause:** `--fail` and `--fail-with-body` differ in a subtle but important
way: `--fail` exits before writing the body; `--fail-with-body` (curl 7.76+)
exits non-zero but still writes the response body to the `-o` target. Any
"capture response for debugging" pattern that combines `-f` with `-o file` is
broken by design — the flag conflicts with its own intent.

**Suggested fix:** Add sweep 2.1 / error-handling category check: when the diff
shows a tempfile/response-file pattern (`mktemp` + `-o "${file}"` + `cat
"${file}"` in an error handler), verify the curl flags do NOT include `-f`/`--fail`.
If `-f` is present and the error handler reads the response file, flag as a
blocker — the response file will always be empty on the cases that trigger the
error handler.
