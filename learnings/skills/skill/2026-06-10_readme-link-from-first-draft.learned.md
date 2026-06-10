---
skill: wk-skill
date: 2026-06-10
type: gap
severity: medium
---

Example `wk-<name>` identifiers in a skill README must use relative markdown links from the first draft.

**What happened:** The wk-skill README used a bare backtick example of the naming convention. The `check-skill-links` pre-commit hook blocked the commit requiring a re-edit.

**Root cause:** wk-skill Step 6 mentions the first-draft link rule in the Step 8 commit note but not in the README authoring guidance where the author writes examples.

**Suggested fix:** Add a note to Step 6 (README authoring): even illustrative or placeholder `wk-<name>` tokens in a README must either be written as relative links or use non-backtick notation to avoid triggering the link-check hook.
