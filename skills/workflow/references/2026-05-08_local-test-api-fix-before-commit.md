## Test external API fixes locally before committing

- **Rule:** After writing a fix to an external API call, rerun the call locally with the new parameters and confirm 2xx before invoking `wk-commit`.
- **Why:** A premature commit on a guessed fix freezes a wrong root cause into the branch. The local rerun catches the case where the proposed fix doesn't address the actual missing requirement.
- **Where:** Phase 2 (Implement) → "External-call reproduction before fix and commit" HARD RULE.
