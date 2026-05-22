---
class: principle
date: 2026-05-22
source: user-request via /wk-sharpen skills/workflow/
---

- **Rule:** After Phase 3 (Test) and before invoking `wk-adversarial-review`, run a refactor-opportunity scan over the diff and its neighbouring code — look for reuse of existing helpers/constants, near-duplicate blocks, premature abstractions, and readability wins; apply, defer with a Follow-ups note, or skip per the Rule of Three.
- **Why:** Adversarial review catches correctness and policy issues but does not prompt for readability/dedup; cleanups bundled into the same change are cheap, cleanups deferred to follow-up PRs rarely happen.
- **Where:** New Phase 3.5 section between Phase 3 (Test) and Phase 4 (Adversarial Review); pipeline arrow and Plan Presentation step list updated to include it.
