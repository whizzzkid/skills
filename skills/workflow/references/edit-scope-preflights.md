# Edit-Scope Pre-Flights

Before tests, enumerate every affected site; fix all in one pass:

- **Signature widening** — grep every caller/initializer; fix same commit.
- **`replace_all: true`** — grep first; reject if any occurrence needs different treatment.
- **Agent-brief identifiers** — grep declaring source; quote exact names, never recalled.
- **Guard modification** — verify upstream change doesn't already make the guard correct.
- **Test-harness reachability** — unreachable branches → extract pure module with unit tests.
- **Shared-contract ownership** — grep for existing format owner; import, don't duplicate.
- **False-positive scoping** — fix targets the offending class, not severity ladder.
