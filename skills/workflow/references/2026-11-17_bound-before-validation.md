---
class: principle
---

- **Rule** — When a new step consumes an input, walk the call chain from the entrypoint to the new call and list the
  validations that have actually run at that line. Every bound or format assumption — in code or in a comment — must
  cite one of those guards; otherwise guard locally and add a sad-path test whose malformed input passes the earlier,
  weaker checks.
- **Why** — A fix built a database named-lock name from a request field and a comment asserted the name always fit
  the length limit because the field is a fixed-length hash. The format validation lived on the model and ran only at
  record creation, after the new call; the controller checked only "non-empty string". An over-long input made the
  lock call raise, turning a former 422 into a 500. The bound came from the value's validated shape, not from the
  guards in force at the call site, and well-formed-only tests could not expose it.
- **Where** — `SKILL.md` Phase 2, beside the edit-scope pre-flights; indexed in `edit-scope-preflights.md`.
