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
- **Reuse hygiene:** before copying fallback chains/defaults/conditionals, trace
  each variable's source, path, and meaning in the new context.
- **No hardcoded env-specific constant beside a dynamic sibling:** before
  hardcoding OS, arch, version, or path, grep the file — if a sibling derives the
  same value dynamically (`uname -s`/`-m`, etc.), reuse that computation, never
  re-hardcode what a sibling derives.
- **Boot / internal-symbol calls:** code at app boot/load, or touching
  undocumented third-party internals (singleton, monitor, constant), ships its
  `rescue` + observability-notify in the first draft, not post-review. An
  existence-check on one raising object of several is not coverage;
  wrap-and-continue unless a halt is intended.
