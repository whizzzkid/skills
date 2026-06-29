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
