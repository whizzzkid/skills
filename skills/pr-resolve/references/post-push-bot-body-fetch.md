---
class: principle
---

# Post-push, fetch full bot comment bodies, not just thread IDs

**Rule** — After each push, refresh bot threads against HEAD AND fetch the full
comment BODIES (not just thread IDs). Classify each by `(path, line, concern)`: a
match from this session is an already-addressed echo (reply with the commit link,
resolve, no re-prompt); a non-match is a genuinely-new finding → route to Step 4
triage. Never ID-refresh-only.

**Why** — A push that triggers CI can spawn new bot inline findings (review bots). An ID-only refresh registers that a thread exists but not its
content, so a genuinely-new finding stays invisible until a manual Step 3 re-run
or a user redirect surfaces it. Fetching bodies post-push makes new findings
discoverable without a second invocation.

**Where** — `wk-pr-resolve` Step 8 (post-push handling); the CI-pass Step 3
re-run (Step 9.5) remains the backstop.
