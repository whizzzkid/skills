# Code Standards — Extended

Lower-frequency, mechanical code standards relocated from `SKILL.md` Phase 2 to
keep the body under its size ceiling. Apply each with the same authority as the
inline standards; relocation does not lower their priority.

- **Bound recursive repository searches:** prefer `git grep` for tracked content.
  Otherwise exclude dependency, distribution, coverage, cache, and generated-output directories before execution.
- **Confirm example formats before encoding:** treat a version/naming/query
  string (esp. in a CLI snippet) as illustrative, not normative — confirm the
  production format before encoding it across >1 file.
- **Parsing tool output:** capture both streams (`2>&1`) and grep an
  always-emitted line, never a flag-gated one (a `--quiet`/`--json`-gated line
  yields empty silently). Multi-match `sed -n 's/.*marker//p'` → `tail -1`
  (canonical line is last), not `head -1`. Match an error string only after
  reproducing the failure against a real fixture and capturing the exact text.
- **External API fields:** reuse the client library schema/types when available;
  hardcode allowlists only when no library type encodes them, and cite the
  upstream source plus re-sync obligation.
- **Content-lint hooks:** scope to the file class and added lines only;
  smoke-test against an out-of-scope file that legitimately contains the pattern.
- **Env vars in docs:** document where stored, who can edit it, propagation, and
  unset default.
- **Structured-row insert:** before inserting/upserting a row into a tabular/list
  data file (CSV, YAML/JSON list, fixtures), scan sibling rows for
  convention-populated fields; if every existing row sets a field the new row
  leaves blank, ask the user to supply it — tools accept the omission silently.
- **Coercion same-class:** a coercion (`.to_s`, `&.`, `String()`,
  optional-chaining, null-coalescing) on one arg/field → audit every arg of the
  same semantic class (role + nullability + type shape); also same-class guards,
  redactions, retry wrappers, logging.
- **Sandboxed-step env forwarding:** a var read inside a container/CI-runner
  step is dead until the step's `env:` allowlist forwards it; env-stubbed tests
  still pass. Trace producer → allowlist → reader in one change (mirror a sibling
  secret); confirm via a real build log.
- **Reuse hygiene:** before copying fallback chains/defaults/conditionals, trace
  each variable's source, path, and meaning in the new context. Reusing a
  bounded helper in a broader-range context: verify the helper's internal bounds
  fit the new range first — a range-capping helper reused for a same-day / wider
  query silently returns empty (no error). Fix by extracting a bounds-free shared
  helper, not by calling the capped one.
- **No hardcoded env-specific constant beside a dynamic sibling:** before
  hardcoding OS, arch, version, or path, grep the file — if a sibling derives the
  same value dynamically (`uname -s`/`-m`, etc.), reuse that computation, never
  re-hardcode what a sibling derives.
- **Validation bounds derive from the schema:** derive a length / range / enum bound
  from the live schema or authoritative source, never a hardcoded copy — a widening
  migration then needs no code change. Pair it with a drift-guard test asserting the
  derived bound still matches the source, so divergence fails in CI instead of in
  staging.
- **Publish an enforced limit in the same change that enforces it:** surface the
  per-field bound in the contract clients actually read (API schema, docs, error
  payload) alongside the new enforcement. A limit enforced but unpublished is
  discovered by losing data.
- **Portable home paths:** in skills, configs, and committed scripts, reference
  user-land paths via `$HOME/...` (or `${HOME}`), never a hardcoded
  machine-absolute home directory.
- **Boot / internal-symbol calls:** code at app boot/load, or touching
  undocumented third-party internals (singleton, monitor, constant), ships its
  `rescue` + observability-notify in the first draft, not post-review. An
  existence-check on one raising object of several is not coverage;
  wrap-and-continue unless a halt is intended.
- **Full-boot repro through a secrets layer:** before the first boot, read the
  config resolver/schema and the repo's existing env-override (dev-container /
  compose) file to enumerate every required key in one pass; inject them
  together, then boot once. Reuse that env-override convention rather than
  editing a generated "DO NOT EDIT" file. A trial-and-error boot loop (boot →
  read the missing-key error → add → re-boot) is the signal to stop and read the
  schema. Prove the root cause by matching produced-artifact fingerprints
  against the exact failing artifacts.

- **TOML-table-anchoring:** before patching a TOML file, identify the first
  `[table]` header and insert global keys immediately above it. TOML table scope
  extends until the next header — a context-free append after the last table
  silently nests keys inside that table. Validate both parsing and the resolved
  configuration after insertion.

## Base resolution

Resolve the PR base branch dynamically — never hardcode `main`:

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD --short | sed 's@^origin/@@')
git diff "$(git merge-base HEAD "origin/$BASE")...HEAD"
```

## Existing-gate preservation

- **Existing-gate preservation:** never add a `skip_*`/`bypass_*`/`force_*` parameter that disables an existing feature gate, guardrail, or rate limit without explicit user confirmation. A new code path is not a license to bypass — when a gate genuinely cannot be honored (e.g., its input is unavailable at call time), document it as a known limitation, never silently remove the protection.

- **File permissions:** executable scripts `chmod +x`; source-only scripts 644.
- **Diagrams:** Mermaid over ASCII; `wk-mermaid` owns diagram-type selection.
- **ADRs:** record significant architectural decisions in `docs/adr/` (`wk-docs` owns the template).
