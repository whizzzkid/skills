---
skill: wk-adversarial-review
date: 2026-05-19
type: gap
severity: high
---

Inline test helper that copies production function body is tautological — never catches implementation drift.

**What happened:** A test spec defined a `let(:call_emit)` lambda whose body was a verbatim copy of the production function it purported to test. The test stubs were applied to the lambda, not the real code. If the real function changed, the tests passed unchanged — making the coverage meaningless. The adversarial subagent caught this; mechanical sweeps did not.

**Root cause:** Sweep 2.15 (workstyle pass) does not check for inline function duplicates in specs. The pattern is common when testing bin-script top-level methods that can't be easily required in isolation — authors copy the function body into the spec context instead of extracting a module.

**Suggested fix:** Add to sweep 2.15: for each new `let` block or `before` block in a spec that defines a multi-line callable, grep the diff for an identical or near-identical code block in the production source. Flag as `test-tautology` if found. Threshold: >3 identical non-trivial lines. The fix is always to extract the function to a testable module/class and require it directly.
