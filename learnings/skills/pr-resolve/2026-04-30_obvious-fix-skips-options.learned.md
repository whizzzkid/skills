---
skill: wk:pr-resolve
date: 2026-04-30
type: gap
severity: medium
---

When all active comments are classified `obvious-fix`, the skill skips per-comment consultation, surprising the user who expected per-comment options.

**What happened:** Step 4 classified both active bot comments as `obvious-fix` (already addressed by a prior commit). Step 5's auto-apply preview block was shown with an `all-review` override hint, then proceeded to Step 6 after a brief override window. The user pushed back asking "why did you stop showing me options?" — the `all-review` escape hatch was buried in a single sentence and the default behavior (skip per-comment loop) was not what the user wanted.

**Root cause:** The skill explicitly states: "If **all** active comments are `obvious-fix`, present the preview and skip Step 5's per-comment loop entirely — proceed to Step 6 after the override window closes." This optimization assumes users want to skip ceremony when no judgment is needed, but in practice users still want explicit per-item confirmation gates, especially when classifications are agent-determined and could be wrong. The `all-review` override is also too quiet — a single phrase in the middle of a paragraph is easy to miss.

**Suggested fix:** Either (a) make per-comment consultation the default even for `obvious-fix` items (with an explicit user-given "auto" or "yes-to-all" override unlocking the bulk path), or (b) make the `all-review` override prompt much more prominent — its own line, framed as a yes/no question requiring affirmative response rather than silent acceptance via timeout. Option (a) is safer: it preserves the one-at-a-time consultation invariant from Hard Rule 5 of Step 5 ("HARD RULE: one comment per message — never batch") which currently has a built-in exception that contradicts user expectations.
