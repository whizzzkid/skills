---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
---

A new regression test went red after a correct fold; the fault was the test harness's
inability to express the input, not the fix.

**What happened:** A fold fixed a guard hook, and a new case asserting the fixed
behavior failed while every other case passed. The fix was in fact correct — verified by
driving the hook directly with the same input, which produced the expected result. The
harness built its payload by interpolating the command-under-test into a shell string
wrapped in single quotes, so the one new case whose input contained a single quote
closed the wrapper and silently corrupted the payload. Nothing in the failure output
pointed at the harness; the obvious reading was "the fold is wrong".

**Root cause:** The skill's verify gate treats a red test as a verdict on the change.
It has no step telling the agent to establish that the harness can faithfully carry the
new input before trusting the result. A fixture layer that mangles input fails
open-looking: it reports a plausible assertion failure rather than an error, so it reads
as evidence about the code instead of evidence about itself.

**Suggested fix:** When a newly added case fails while pre-existing cases pass,
reproduce the same input against the artifact directly before touching the fold. If the
direct run disagrees with the harness, the harness is the defect — fix it in the same
pass and count it as audit cleanup. Corollary worth stating: a test fixture that
interpolates test input into a shell command string cannot represent input containing
quote characters; pass such input through the environment instead. Related to the
existing "report is a hypothesis" rule, but the untrustworthy source here is the
project's own test harness rather than a field report.
