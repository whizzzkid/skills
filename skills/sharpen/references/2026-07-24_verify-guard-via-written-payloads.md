---
class: principle
skill: wk-sharpen
date: 2026-07-24
severity: low
---

**Rule** — When the artifact under verification is a guard on the agent's own tool calls, stage each
test payload with the file-write tool and feed it to the hook by redirect. Composing the faithful
test shape inline in a shell command is itself the call the guard blocks. Never reach for the
guard's opt-out to run the test.

**Why** — The verification step says to "drive the artifact directly with the same input" without
noting that for this class of artifact the obvious way to supply that input is self-defeating: a
guard inspects the outgoing tool call, so any faithful input *is* a blocked call and the
reproduction dies before the hook is deliberately invoked. Two properties make the written-payload
route work and are worth naming: the hook reads its payload from stdin, so a redirect carries the
shape without the agent's own command line containing it; and the file-write path of such guards
typically warns rather than blocks, so staging the payload trips nothing. The opt-out is excluded on
two counts — it is the bypass the guard's own rules forbid, and disabling the code under test voids
the result.

**Where** — Step 1's report-is-hypothesis HARD RULE, as a sub-bullet of the
drive-the-artifact-directly rule, which is the instruction that was silently unsatisfiable.

**Rejected** — Nothing relaxed. The per-guard stdin/exit contract stays documented in the guard's
own skill; only the generic verification mechanic folded here, so the two do not duplicate.
