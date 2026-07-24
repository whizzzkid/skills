---
skill: wk-sharpen
date: 2026-07-24
type: surprise
severity: low
verified-against-source: yes
---

Reproducing a PreToolUse guard requires staging its payloads through the file-write tool — a Bash
call containing the test shape is blocked by the very guard under test.

**What happened:** Verifying a scope guard meant driving it with a command shape that combines a
recursive-search verb with an out-of-repo absolute path. Issuing that shape from a Bash call is
exactly what the guard blocks, so the reproduction attempt would be intercepted before the hook
could be invoked deliberately. Writing each payload to a JSON file with the file-write tool and
then invoking the hook with a redirect worked: the agent's own command line carries no search verb,
so it passes, while the payload's contents are never inspected. Four payloads then established the
mechanism cleanly, and the guard's own test suite corroborated it.

**Root cause:** A PreToolUse guard inspects the agent's outgoing tool call, so any faithful test
input is itself a blocked call. The skill's verification step says to "drive the artifact directly
with the same input" without noting that for this class of artifact the obvious way to supply that
input is self-defeating.

**Suggested fix:** When the artifact under verification is a hook that gates the agent's own tool
calls, stage each test payload with the file-write tool and feed it to the hook by redirect, rather
than composing the shape inline in a shell command. Never reach for the guard's opt-out to run the
test — that is the bypass the guard's own rules forbid, and it would also void the result.
