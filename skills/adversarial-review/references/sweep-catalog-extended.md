# Extended Mechanical Sweep Catalog

Part of the Step 2 catalog — apply each row under the **same unconditional rule**
as the inline catalog whenever its trigger matches. These are lower-frequency,
shape-specific sweeps relocated here to keep `SKILL.md` under the body-size
ceiling; relocation does not lower their priority.

| ID | Trigger | Check | Severity | Fix / escalation |
|---|---|---|---|---|
| 2.41 | Comment claims a concurrency/signal race is "eliminated"/"removed" | A reorder of `signal.Stop` (or equivalent) narrows but does not drain a buffered channel — a queued signal still executes the exit path. | Suggestion | Reword to "narrows the window" unless a done-channel/atomic-flag guard truly closes it; Blocker if the comment is load-bearing for safety. |
| 2.42 | New parameterized integration test iterating a helper's nil/error paths | Grep the helper's unit spec; if it already asserts all iterated cases return the same value, the integration iterations re-test internals. | Suggestion | Keep one representative case at the integration boundary; drop the rest. |
| 2.45 | Diff adds a seed/sync/fetch step that gates a baseline read before a downstream write-back | The write-back (or any downstream mutation) must gate on the seed helper's actual **return value**, not a re-check of the seed's trigger precondition (`if X.success?` when the seed also ran on `X.success?`). A seed that only blocks itself leaves the write-back running from a stale baseline — the clobber it was added to prevent. Also treat a command exiting 0 with empty stdout (`git show` of a missing blob) as failure. | Blocker | Capture the helper's return value and gate the write-back on it; add an `out.strip.empty?` guard. |
| 2.46 | Validator over a partial-override / optional-field struct (empty = keep existing) | All-or-nothing drop discards valid overrides when any field is invalid; one bad field is a per-field hallucination, not a corrupt record. | Suggestion | Validate per-field: zero+log invalid fields (fail-open), keep valid, drop the record only when all fields invalid. |
