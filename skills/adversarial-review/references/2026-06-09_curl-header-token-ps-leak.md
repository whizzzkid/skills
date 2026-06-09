---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** Flag any API token expanded inside a `curl -H "Authorization:
  Bearer $VAR"` argument; require a `chmod 600` temp file with `-H @file`.
- **Why:** Process arguments are visible to `ps aux` on multi-user hosts — a
  different exposure path than the stderr leakage sweep 2.1 already covers.
- **Where:** Sweep 2.1 (Vulnerability-class sweep), curl `-H` token bullet +
  `grep -nE 'curl[^|]*-H[^|]*\$\{?[A-Z_]+'`.
