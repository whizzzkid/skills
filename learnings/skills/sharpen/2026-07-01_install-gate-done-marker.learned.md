---
skill: wk-sharpen
date: 2026-07-01
type: correction
severity: low
---

Step 8 install gate greps for literal `Done!`, but the skills CLI now ends with
`Installed N skills` instead — grepping only for `Done!` yields a false-negative.

**What happened:** After editing skills, the Step 8 install command
(`npx skills add . -g -y -a=claude`) completed successfully, but the output's
terminal marker was `◇ Installed 61 skills`, not `Done!`. Grepping for `Done!`
returned nothing, prompting three redundant re-runs to hunt for the expected
string before accepting success.

**Root cause:** The gate hard-codes one exact success string. The CLI's terminal
marker changed across versions; a single-literal check is brittle.

**Suggested fix:** In Step 8, accept either `Done!` or `Installed <N> skills`
(count ≥ 1) as proof of a successful install. Prefer probing for a success
marker set over a single literal, and treat a boxed/paginated tail that omits
the literal as "check the count line", not "install failed".
