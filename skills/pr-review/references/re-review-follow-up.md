# Re-review follow-up

Detect prior comments by the current user (`gh api user --jq '.login'`) and close the loop before new issues:

- **Fix applied** → validate against current code, draft acknowledgment.
- **Wrong fix** → follow-up grounded in current code.
- **Deferred** → plus-one for low; nudge for concerns.
- **Pushback** → answer with evidence or restate.
- **No response / resolved** → skip.

A modified file proves an attempt, not a fix. Thread actions are live (not pending review). Dedup against prior threads.
