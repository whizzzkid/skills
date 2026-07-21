# Code Standards — Extended

Lower-frequency, mechanical code standards relocated from `SKILL.md` Phase 2 to
keep the body under its size ceiling. Apply each with the same authority as the
inline standards; relocation does not lower their priority.

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
- **Reuse hygiene:** before copying fallback chains/defaults/conditionals, trace
  each variable's source, path, and meaning in the new context.
- **No hardcoded env-specific constant beside a dynamic sibling:** before
  hardcoding OS, arch, version, or path, grep the file — if a sibling derives the
  same value dynamically (`uname -s`/`-m`, etc.), reuse that computation, never
  re-hardcode what a sibling derives.
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
