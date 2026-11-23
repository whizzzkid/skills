---
skill: wk-pr
date: 2026-11-20
type: correction
severity: medium
verified-against-source: n/a
---

Resolve the issue-tracker base URL from a command before writing it into a PR body. Never type a plausible host from memory.

**What happened:** The first PR body linked the ticket under an invented tracker hostname. The mistake was only caught afterwards, and the body was edited once the real site was resolved through the tracker connector.

**Root cause:** Rule 4 (every identifier in the body comes from a command run this turn) is worded around run ids, SHAs and PR numbers, so a ticket URL did not register as an identifier that needs a source.

**Suggested fix:** Add "issue-tracker URLs" to Rule 4's identifier list. Before composing the body, resolve the tracker site from the connector's accessible-resources call, or from the body of a sibling PR.
