---
class: principle
---

**Rule** — A fake/stub CLI must gate any output it writes on the same flag that gates it in production. If the real tool only writes the body under a specific flag (`--fail-with-body`, etc.), the stub must branch on that flag's presence in `$@`, not write unconditionally.

**Why** — A stub that mimics the happy-path shape (writes body unconditionally) makes a production regression away from that flag undetectable: the test passes whether or not the flag survives — the exact regression the test exists to catch. The stub becomes a shape-mimicker, not a contract gate.

**Where** — Sweep 2.47. Any test helper that fakes a flag-conditional tool. Model both flag-present and flag-absent behavior.
