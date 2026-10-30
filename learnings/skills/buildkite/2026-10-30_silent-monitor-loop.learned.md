---
skill: wk-buildkite
date: 2026-10-30
type: correction
severity: high
verified-against-source: yes
---

A background CI watch loop stayed silent while the build failed, because its parsing broke without any output.

**What happened:** The watch loop split "pipeline build" pairs with `set -- $p`. The shell was zsh, which does not
word-split unquoted parameters, so every `bk` call got a malformed pipeline argument. Each `jq` parse then failed with
no output, and the loop's failure branch never fired. The user had to say "you are not watching".

**Root cause:** The loop depended on bash word-splitting but ran in zsh, and it had no assertion that each poll actually
parsed. Reproduced directly: the same `jq` call errored with "Invalid numeric literal".

**Suggested fix:** Run watch loops under an explicit `bash -c`, pass the pipeline and build as separate arguments, and
emit on every state change, including a first-poll line, so a broken parse shows up immediately.
