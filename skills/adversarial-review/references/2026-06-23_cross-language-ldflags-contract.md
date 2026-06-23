---
class: principle
skill: wk-adversarial-review
date: 2026-06-23
---

**Rule**

When a build script passes `-ldflags "-X pkg.Symbol=value"` to a Go build (or any
stringly-typed cross-language symbol contract), require a test that builds the
real binary with that exact flag and asserts the stamped value via the binary's
own output. A string-match assertion in the builder's test is insufficient.

**Why**

The symbol name (`main.BuildVersion`) is an unchecked contract between the shell
builder and Go; a rename on either side passes both suites silently. A shell-log
string match locks neither the symbol name nor the output path.

**Where**

Step 2 mechanical sweep catalog, row 2.53 (Blocker — test-coverage gap).
