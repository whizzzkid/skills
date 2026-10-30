---
class: principle
skill: wk-buildkite
date: 2026-10-30
severity: high
---

**Rule** — A background CI watch loop must prove each poll parsed: run under explicit `bash -c` with pipeline and build
as separate positional args, print a first-poll line and a line on every state change, and treat an empty/unparsable
state as a loud non-zero exit, never a silent re-poll.

**Why** — A loop that split a combined "pipeline build" value with `set -- $p` ran in zsh, which does not word-split
unquoted parameters. Every `bk` call got a malformed argument, every `jq` parse failed without output, and the failure
branch never fired — the loop read as "still watching" while the build was red, until the user intervened. Verified:
the same `jq` call on the `bk` error text fails with `Invalid numeric literal`. The snippet in `SKILL.md` was exercised
against a stub `bk`: a good stream prints `poll 1: running` then `poll 3: failed` (rc 1); an error stream prints
`poll 1: UNPARSABLE state` (rc 2).

**Escalation** — The zsh word-splitting trap is already a shipped rule in `wk-workstyle-shell`
(`references/zsh-bash-portability.md`, installed before this report). Re-violated in a `set --` position → escalated
one rung, `**Very important:**` → `**CRITICAL:**`, and `set -- $p` added as a named position. The buildkite fold is the
load-bearing half: a liveness assertion catches *any* silent parse failure, not only word-splitting.

**Where** — `SKILL.md` → "Monitoring after push", HARD RULE after the announcement rule.
