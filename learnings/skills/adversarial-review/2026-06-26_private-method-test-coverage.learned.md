---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: low
---

Bot findings flagging test gaps on private helpers and shared code paths are dismissible when the public interface already exercises them.

**What happened:** Bot flagged two Minor findings: (1) missing unit tests for a private helper method tested only through the public API; (2) missing test for `info` severity in a partition predicate that already had `minor` tested.

**Root cause:** Bot checks scope by changed lines, not by reachable code paths. A private method tested transitively through its caller, and two severities sharing the same branch, both appear as gaps from a line-coverage lens.

**Suggested fix:** When evaluating bot test-coverage/test-scope findings against private methods or near-duplicate code paths, check whether the concern is already exercised transitively before accepting it as a real gap. Standard Ruby/RSpec practice: private methods are tested through the public interface; coupling tests to private helpers couples tests to implementation detail.
