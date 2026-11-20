---
skill: wk-learn
date: 2026-11-20
type: correction
severity: low
verified-against-source: n/a
---

The agent wrote a learning file to a guessed skills-home path instead of the resolved `$WK_SKILLS_HOME`.

**What happened:** The Write tool needs an absolute path, so the agent typed one from memory and created stray
directories outside the skills home. It moved the file after checking with `echo "$WK_SKILLS_HOME"`.

**Root cause:** Step 1 only tests that the variable is set and never prints its value, and the Write tool cannot
expand shell variables.

**Suggested fix:** Have Step 1 print the resolved value (`echo "$WK_SKILLS_HOME"`) and require Write paths to be built
from that output.
