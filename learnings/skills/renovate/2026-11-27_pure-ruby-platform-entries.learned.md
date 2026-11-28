---
skill: wk-renovate
date: 2026-11-27
type: pattern
severity: low
verified-against-source: yes
---

Dependabot bundler lockfiles add generic pure-ruby platform entries for native gems the lock already covers per-platform.

**What happened:** Every single-gem Dependabot PR added bare entries (e.g. `ffi (x.y.z)`, `nokogiri (x.y.z)`) with no
platform suffix, alongside a lock whose PLATFORMS list only names specific arch/OS triples that already have
precompiled entries. A grouped PR also carried unrelated transitive bumps.

**Root cause:** Dependabot resolves with a generic `ruby` platform, independent of the lock's PLATFORMS list.

**Suggested fix:** In Step 3's lockfile diff check, call out unsuffixed native-gem entries as a known Dependabot
artifact to drop; the scoped re-resolve should never introduce them.
