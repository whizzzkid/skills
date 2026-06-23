---
skill: wk-adversarial-review
date: 2026-06-23
type: gap
severity: high
---

Cross-language stringly-typed contract requires an end-to-end stamped binary test.

**What happened:** A shell build script passes `-ldflags "-X main.BuildVersion=${VERSION}"` to `go build`. The Ruby spec asserted only that the ldflags *string* appears in the fake build log — but no test verified that a Go binary built with that flag actually emits the stamped value from `--version`. The symbol name `main.BuildVersion` is a stringly-typed contract between shell and Go; a rename on either side passes both test suites silently.

**Root cause:** The adversarial-review sweep correctly identified the shell-spec coverage gap but did not initially surface the deeper cross-language contract gap — the shell spec's string match does not substitute for a Go exec test that builds with `-ldflags` and asserts the output.

**Suggested fix:** When the diff includes a shell script passing `-ldflags "-X pkg.Symbol=value"` to a Go build, add a sweep check: does any Go test build the binary with that exact flag and assert the binary's output matches the stamped value? A shell string match is insufficient — it does not lock the symbol name or the output path. Flag this as a test-coverage blocker when absent.
