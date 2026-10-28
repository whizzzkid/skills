---
skill: wk-workflow
date: 2026-10-28
type: gap
severity: medium
verified-against-source: yes
---

Running only the feature's own test suite missed a repo-wide style check that CI enforced.

**What happened:** After adding localized strings, the agent ran only the suite for the feature it changed. CI failed on
a repository-wide test that scans every source file for visible-text style rules (here, curly apostrophes in UI
strings). One translation used a straight apostrophe.

**Root cause:** The suite selector made a narrow run feel authoritative. Repo-wide lint-like tests live in a different
suite and cover any file, so they belong to every change.

**Suggested fix:** When a repo has a test-suite selector, always run the changed feature's suite plus any repository-wide
or lint-style suite before pushing — or the full gate when it is affordable. Treat new user-visible strings as a trigger
to run style and localization suites specifically.
