---
class: principle
---

**Rule:** When a finding suggests adopting a pattern already used elsewhere in
the codebase, verify the scenario matches before copying it in. Precedent alone
never proves this context needs the pattern.

**Why:** A bot finding prompted adding auth-guard calls to a download function
after observing sibling scripts use that pattern. But the guard belongs to gated
operations (a no-auth runtime state is valid); the download fetched a public
artifact via a CLI that manages its own credentials — no guard needed. "Pattern
exists here, therefore this context needs it" is a false inference; the auth
model (gated vs. CLI-managed credentials) had to be checked first.

**Where:** Step 4, after "Missing-documentation findings" — verify the scenario
(auth model, runtime state, credential ownership) matches before adopting a
cited pattern.
