---
skill: wk-pr-resolve
date: 2026-08-07
type: pattern
severity: medium
verified-against-source: yes
---

Treat successful execution of the exact reviewed command as stronger evidence than a bot's static shell-quoting hypothesis.

**What happened:** A review bot predicted that nested quoting would break a CI command, while the completed job log showed the same command invoking the intended migration and passing its behavioral tests.

**Root cause:** Static review inferred an extra quoting transformation without checking the command hook's observed argv and exit path. The resolution workflow reproduced the claim from the job log before changing code.

**Suggested fix:** When a bot flags shell or wrapper behavior, inspect the latest job log for the exact rendered command and downstream sentinel before accepting a patch. A successful sentinel tied to that command supports an evidence-backed dismissal; a merely green aggregate build does not.
