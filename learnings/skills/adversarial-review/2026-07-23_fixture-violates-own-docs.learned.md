---
skill: wk-adversarial-review
date: 2026-07-23
type: gap
severity: low
---

A PR that both documents authoring guidance and adds an example/fixture of that same artifact type must have the fixture obey the guidance — grep the fixture against the rule the diff just wrote.

**What happened:** A PR added docs telling repo-check authors to OMIT a `content_hash:` field, but the same PR's own example fixture file carried that field. A review bot caught the self-contradiction; the adversarial sweep did not.

**Root cause:** The docs-vs-code sweeps checked prose claims against implementation, but did not cross-check newly-added sample/fixture artifacts against the authoring rules the same diff introduced.

**Suggested fix:** When a diff both states a "authors should (include|omit) field X" rule and adds an example/fixture/template of that artifact class, grep each added fixture for field X and flag any fixture that violates the rule the PR just documented — intra-PR guidance-vs-fixture consistency, not only prose-vs-code.
