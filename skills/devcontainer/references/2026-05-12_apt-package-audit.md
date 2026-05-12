---
date: 2026-05-12
slug: apt-package-audit
---

- **Rule:** Install only apt packages whose absence breaks `bundle install`; drop `curl`, `git`, `libssl-dev`, and `libmysqlclient-dev` (when the project uses `trilogy`).
- **Why:** `curl`/`git` already ship in the `jdx/mise` base; mise Ruby bundles OpenSSL; `trilogy` speaks MySQL natively. Extra packages add minutes to image build with no behavior win.
- **Where:** Step 2 → "Apt package audit" sub-section + Quick Reference DB-adapter check.
