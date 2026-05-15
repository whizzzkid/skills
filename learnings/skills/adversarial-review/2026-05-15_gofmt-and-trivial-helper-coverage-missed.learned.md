---
skill: wk-adversarial-review
date: 2026-05-15
type: gap
severity: medium
---

Two findings on PR #NNN (`feat/check-attribution` in `$GITHUB_ORG/{repo}`) slipped past adversarial review and were caught only by a post-push `/wk-workstyle` scan and a `{bot}` re-review:

1. **`gofmt` alignment drift in `tools/{repo}/types.go`.** Adding `CheckURL`/`CheckProject` to the `Finding` struct widened the field column, but the siblings `File`, `LineStart`, `LineEnd`, `Issue`, `Severity`, `InDiff`, `Unvalidated` were left at the old alignment. `gofmt -l` flags this; the pre-push run did not catch it because no mechanical sweep invokes a formatter against the diff's language.
2. **Trivial-helper coverage gap on `repoProject`.** A new 3-line helper with a fallback branch (no-slash → return slug unchanged) shipped without a direct unit test. The post-push bot review (`test-coverage` finding) flagged it; pre-push review did not. Step 2.15 (workstyle pass) lists "missing sad-path tests" as a category, but trivial helpers tend to read like leaf utilities and get skipped — the heuristic is too coarse to fire reliably on a 3-line function.

**Root cause — two distinct gaps:**

a) **No formatter invocation.** Step 2 mechanical sweeps cover greps for known classes (vulnerability, sibling-script, version-pin, hardcoded base, etc.) and a workstyle pass, but never run the project's own canonical formatter (`gofmt`, `prettier`, `rubocop -a --dry-run`, `ruff format --check`, `cargo fmt --check`). These are the cheapest, most deterministic adversarial signals available — they always exist when the language has them, they exit non-zero on drift, and they need no LLM reasoning. The skill leaves them on the table and instead relies on `wk-workstyle` to surface alignment issues, which it does not — workstyle defers to the formatter rather than re-implementing its rules.

b) **Trivial-helper coverage class not enumerated.** Step 2.15 mentions "missing sad-path tests for new error-handling branches" but does not explicitly call out *new helper functions with branchy logic that lack a direct unit test*, even when transitively covered. Bots routinely flag this class (`test-coverage` was the exact label the {bot} bot used here). The skill's "behavioral over structural" framing — inherited from `wk-testing-skeleton` — biases against asking for direct unit tests on helpers, but the bot's flag is correct: the no-slash fallback branch had zero coverage from any caller in the integration tests, since every real caller passes a well-formed `owner/repo` slug.

**Suggested fix:**

Add a new mechanical sweep, *Step 2.16 Formatter pre-check*: "Detect the project's canonical formatter from existing config (`.gofmt` is implicit for Go, `.prettierrc*` for JS/TS, `.rubocop.yml` for Ruby, `pyproject.toml`/`ruff.toml` for Python, `rustfmt.toml` for Rust). Invoke it in check-only mode on every file in the diff. Any drift is a blocker — adding it on top of the diff costs nothing and prevents a CI cycle." This is strictly cheaper than the post-hoc `/wk-workstyle scan` discovery path.

Extend Step 2.15 (workstyle pass) coverage list to include: *"New helper functions with any branching (`if/else`, ternary, `switch`, fallback `return`) that lack a direct unit test — transitive coverage from callers is insufficient when the caller only exercises the happy path."* Cite that this is the class bots most reliably flag, so catching it locally is high-value.

**Why neither was caught here:** The agent did `go vet`, `go test ./...`, and `bundle exec rubocop` on touched Ruby files in the pre-push sweep, but never ran `gofmt -l` on the Go files. `go test` passes regardless of formatting; `go vet` does not enforce alignment. The workstyle pass that eventually surfaced the alignment delta ran *after* push, as part of a manual `/wk-workstyle scan`. Same shape for `repoProject` — the agent reasoned "covered transitively by `TestDiscoverChecks` / `TestDiscoverRepoChecks_*`" and skipped a direct test; the bot disagreed and was right (the no-slash branch had no caller-driven coverage).
