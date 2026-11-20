---
skill: wk-workstyle-docs
date: 2026-11-20
type: correction
severity: low
verified-against-source: yes
---

A new code comment claimed the tests stub a global, and they don't.

**What happened:** The agent added a reason comment to a lint-ignore saying the test suite stubs the browser global.
A grep of the tests found no such stub, so the comment was rewritten to cite the library that sets the global.

**Root cause:** The comment was written from assumption, and the grep came after the claim instead of before it.

**Suggested fix:** Before writing a comment that makes a factual claim about tests or a dependency, grep or read the
source that would prove it, then write the comment.
