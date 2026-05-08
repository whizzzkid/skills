## Run the full pre-push gate, not a subset

- **Rule:** Before any `git push`, run every test suite, lint, and type check the repo wires into its pre-push hook (e.g., `lefthook run pre-push`).
- **Why:** Independent suites can assert on the same source with different matchers — passing one does not imply the others pass. A locally-verified bats run can land alongside a broken rspec run because they're separate gates.
- **Where:** Phase 3 (Test) → Verification bullet "full pre-push gate the repo defines".
