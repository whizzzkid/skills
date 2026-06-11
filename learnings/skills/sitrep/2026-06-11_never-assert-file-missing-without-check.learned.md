---
skill: wk-sitrep
date: 2026-06-11
type: correction
severity: high
---

Never assert a file does not exist without running a filesystem check first.

**What happened:** When the user asked why the standup was incomplete, the agent explained "there was no snapshot" — but the snapshot file was present at the expected path. The agent had simply not read it; it reasoned from its own omission and falsely declared the file absent.

**Root cause:** Agent confused "I did not read X" with "X does not exist." No `ls` or `Read` was attempted before making the claim.

**Suggested fix:** Any "X does not exist / was not found" assertion must be preceded by a concrete filesystem check (`ls`/`Read`/`find`). If the check was not run, the correct statement is "I did not read X" — never "X is missing." This applies generally across all skills, not just sitrep.
