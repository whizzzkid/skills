---
class: principle
date: 2026-07-27
severity: medium
---

# Author the review payload with Write by default, not after a block

**Rule** — Compose the pending-review JSON with the **Write tool** to
`/tmp/agent/gh/<owner>/<repo>/pulls/{n}/self-review.json`, then use bash only for
`gh api … --input <file>`. Never `--input -` with a heredoc.

**Why** — A review body is arbitrary prose: slashes, regex literals, code snippets,
URLs. Any PreToolUse gate that scans **command text** can read one of those tokens as a
path or a denied endpoint and block before the command ever runs — the composition is
wasted for a reason the prose never intended. The Write path removes the exposure
instead of dodging one matcher: the command carries a filename and no prose, so there is
nothing left to scan. That property holds against any text-scanning gate, which is why
the rule does not name one.

The previous guidance was scoped to the endpoint-string denial and framed as recovery
*after* a block, so it could not prevent the block it described.

## The reported mechanism is not confirmed — the remedy does not depend on it

The report named a specific cause (a path-scope hook reading `/word/i.match?(…)` as a
filesystem path) and flagged it `verified-against-source: no`. Driving this repo's
`skills/scope-guard/hooks/scope-guard.sh` with that exact payload shape **disproves** it
for the hook available to read: the Bash guard classifies each command segment by its
own argv and only charges path operands of `find`/`fd`/`grep -r`/`rg`/`ls -R`, so a
`gh api … <<EOF` segment yields no candidates and exits 0. A positive control
(`grep -r foo /etc`) still blocked at exit 2 in the same run, so the hook was live and
the clean result is real, not a dead probe.

The culprit was therefore a different repo's hook whose source is not readable from
here. So the fold states the remedy and a *generic* trigger ("a gate that scans command
text") and asserts no mechanism. Do not "fix" `wk-scope-guard` against this learning —
it is not the offender, and relaxing it would trade a correctness property for a symptom.

## Same-pass contradiction fix

Step 4's canonical example still showed `--input -` with the body inline in a heredoc —
the exact shape the new rule forbids. Left alone, the skill would carry a HARD RULE and
a worked example that disagree, and the example wins in practice. Step 4 now writes the
JSON and posts the file. `skills/gh/SKILL.md` needed no change: its `jq -n --arg body
"$text" | gh api … --input -` form already keeps prose out of the command text.
`skills/pr-review/SKILL.md` carries the same violating heredoc and is corrected in its
own pass, which owns that file's version bump.

**Where** — `SKILL.md` → Step 0.5 (HARD RULE) and Step 4 (create the pending review).
