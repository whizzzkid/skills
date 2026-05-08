## Verify required API fields before writing the fix

- **Rule:** Reproduce the failing API call locally and read the response body before writing any fix.
- **Why:** A 4xx status code is ambiguous; the response body usually names the missing or invalid field. Guessing from the status alone produces a fix that targets the wrong root cause and forces a second PR.
- **Where:** Phase 2 (Implement) → "External-call reproduction before fix and commit" HARD RULE.
