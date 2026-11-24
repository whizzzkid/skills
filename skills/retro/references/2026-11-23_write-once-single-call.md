---
class: principle
date: 2026-11-23
skill: wk-retro
severity: high
---

# Compute N, validate, and write the session file in one Bash call

- **Rule:** Run N derivation, the validation gate, and the write as one Bash
  invocation. Take N from the highest existing index (`.md` or `.learned.md`),
  never from a file count or a hand-typed number. Write under noclobber and
  refuse an existing target. Draft into a per-run `mktemp` dir.
- **Why:** The recipe split `FILE=` and `cp "$DRAFT" "$FILE"` across tool calls.
  Shell variables do not survive that boundary, so the agent re-typed the path
  with the wrong session number. The plain `cp` then silently replaced another
  session's undistilled retro file, which was recoverable only from that
  session's transcript. A count-based N also collides once indices have a gap,
  and a fixed shared draft path races concurrent sessions.
- **Where:** Step 3 — new HARD RULE "compute N, validate, and write in ONE Bash
  call", backed by the rewritten [`validation-gate.md`](validation-gate.md).
- **Escalation:** "never reuse a filename" was installed before the report
  (2026-06-16) and was re-violated, so it moved one rung to `**Important:**`.
  The structural fix (one call, no-clobber) is a correctness repair of the
  recipe, not a further rung.
