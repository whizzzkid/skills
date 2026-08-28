---
skill: wk-workflow
date: 2026-08-28
type: gap
severity: medium
verified-against-source: n/a
---

Extract branch logic unreachable by server-rendered specs into a pure module with unit tests up front.

**What happened:** A client-side controller gained branch logic (id-collision suffixing, URL-fragment parsing) that a server-rendered request spec structurally cannot exercise — server-emitted ids never collide, so the suffixing path was untested. A review round flagged the test-scope gap and forced a mid-cycle refactor: extract the DOM-free logic into its own module and add offline unit tests.

**Root cause:** The plan added the logic inline in the controller without asking "which branches can the existing spec harness actually reach?" Request specs cover rendered markup, not client-only state transitions, so any collision/parsing branch is invisible to them.

**Suggested fix:** When a task adds client-side controller logic with branches driven by client-only state (collisions, fragment/hash parsing, in-memory dedup), plan the pure/DOM-free extraction and its unit tests as part of the same task — do not wait for a test-scope review finding to force the split.
