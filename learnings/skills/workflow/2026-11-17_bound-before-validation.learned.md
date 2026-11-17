---
skill: wk-workflow
date: 2026-11-17
type: correction
severity: medium
verified-against-source: yes
---

A new step that consumes an input before the existing validation runs inherits none of that validation's bounds.

**What happened:** A fix added a database named-lock call whose name was built from a request field, and a code comment
asserted the name always fits the database's length limit because the field is a fixed-length hash. The field's
format validation lived on the model and ran only at record creation, after the new call, while the controller checked
only "non-empty string". An over-long input therefore made the lock call raise, turning a former 422 into a 500.
Adversarial review caught it; the author's tests used only well-formed inputs.

**Root cause:** The bound was derived from the validated shape of the value, not from the guards that had actually
run at the new call site. Validation order in the call chain was never traced.

**Suggested fix:** Add an edit-scope preflight: when a new step consumes an input, list which validations have run at
that exact line (walk entrypoint → new call). Any bound or format assumption in code or comments must cite a guard
that precedes it; otherwise guard locally and add a sad-path test with a malformed input that would otherwise pass the
earlier, weaker checks.
