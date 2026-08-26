---
skill: wk-buildkite
date: 2026-08-26
type: gap
severity: medium
verified-against-source: yes
---

Document the retry-command shape and a query-only-token fallback for confirmed infrastructure failures.

**What happened:** A failed job was confirmed as a spot-instance termination, but `bk job retry` rejected a pipeline flag and then the available query-only token rejected the mutation.

**Root cause:** CLI help confirms `bk job retry` accepts only a job UUID, while the live API error confirms the configured token cannot perform mutations.

**Suggested fix:** Teach the skill to call `bk job retry <job-id> --yes --no-pager` without a pipeline flag, and when mutation access is unavailable, use a signed empty CI-retry commit only after logs prove an infrastructure-only failure.
