---
skill: wk-workflow
date: 2026-05-12
type: gap
severity: high
---

When a PR adds a new CLI flag or public surface, run a pre-PR checklist before opening it. Skipping this causes 3–5 rounds of bot review back-and-forth, each costing a full CI cycle (~5 min) per missed item.

**What happened:** PR #NNN (`--iterate-on`) required 5+ rounds of `wk-pr-resolve` invocations. Every round addressed one predictable bot finding at a time: input edge cases, env-var conflict rule, cross-doc drift, null defense, test enumeration drift, redundant guard cleanup. Each finding was individually small but cost a full push+CI cycle.

**Root cause:** The initial PR addressed the happy path but didn't systematically check the predictable finding categories that Copilot and {bot} always audit. These categories are deterministic across every feature PR in this repo.

**Suggested fix:** Before opening a PR that adds a new CLI flag, verify all of these in the initial commit set:

1. **Input parsing completeness:** For every accepted format, write happy-path AND rejection tests for every empty/missing/malformed sub-component (empty org, empty repo, extra slashes, whitespace around delimiters, numeric parse failures).

2. **Conflict rule + env var interaction:** If `clap::Arg::conflicts_with_all` lists args with `env = "..."` backing, use a post-parse `ArgMatches::value_source() == Some(ValueSource::CommandLine)` check instead. Add a positive-case test that sets those env vars alongside the new flag and asserts success.

3. **External input null defense:** Any `gh api --jq '.field'` output uses `'.field // empty'` to convert null → empty at the jq layer. Never add a `== "null"` Rust guard on top — it's dead code (see self-review learning) and creates false-positive risk.

4. **Cross-doc consistency:** After writing docs, grep the diff for every mention of the new flag across `SKILL.md`, `docs/wish/reference/*.md`, and in-code `help` strings. Verify: conflict lists match, accepted formats match, error codes match. Doc drift between these surfaces is the most common bot finding class.

5. **Diagnostic help completeness:** A `WishError` variant's `help` string must cover every failure mode that returns it — not just the most obvious one.

6. **Test count in PR description:** Either omit exact test counts from the body or update them on every push. Stale counts are flagged by bots.

Each missed item = one push + one bot review cycle. Addressing all upfront collapses 5 cycles into 0.
