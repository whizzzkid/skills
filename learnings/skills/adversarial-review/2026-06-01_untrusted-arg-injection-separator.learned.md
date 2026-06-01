---
skill: wk-adversarial-review
date: 2026-06-01
type: gap
severity: high
---

Untrusted filenames passed to a subcommand without a `--` separator is an argument-injection class the sweeps missed.

**What happened:** A security bot flagged argument injection: untrusted
filenames (from a sandbox-writable directory) were passed to `tar czf ... "${files[@]}"`
with no `--` option terminator. A basename like `-I.jsonl` or
`--use-compress-program=evil` is parsed by the subcommand as an option, not a
file — an RCE path. A realpath/symlink guard does NOT catch this, because a
leading-dash file legitimately lives under the trusted root; the guard validates
the path, not the basename's option-likeness.

**Mechanism:** Any external command invoked with a variable/array/glob expansion
of attacker-influenceable names, where the command does option parsing and no
`--` precedes the positional args. Common offenders: `tar`, `rm`, `cp`, `grep`,
`chmod`, `git`, `curl`.

**Detection sketch:** Add a sweep — grep the diff for commands invoked with
array/glob expansion and no `--` terminator:
`grep -nE '\b(tar|rm|cp|mv|grep|chmod|chown|git|curl)\b[^|]*("\$\{[a-z_]+\[@\]|/\*)' | grep -v ' -- '`.
For each hit, check whether the expanded values originate from an untrusted
source (sandbox-writable dir, user upload, API payload). Flag as blocker when
untrusted and no `--` present.

**Confidence:** high (mechanical grep detection possible).
