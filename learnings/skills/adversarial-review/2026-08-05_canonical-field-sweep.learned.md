---
skill: wk-adversarial-review
date: 2026-08-05
type: pattern
severity: high
verified-against-source: yes
---

Metadata validators need semantic mutation probes for every value consumed by a public projection.

**What happened:** A typed metadata contract checked that required fields existed, but accepted an
impossible calendar date, a drifting display name and support address, and vendor URLs with
credentials, custom ports, queries, fragments, or extra path segments. Its placeholder scanner also
missed nested and documented public-source roots because directory URLs lost their trailing slash.

**Root cause:** Shape validation and selected URL-component checks were treated as equivalent to a
canonical-value contract. The adversarial sweep had to mutate each projected field and place a
sentinel at every recursive source boundary to expose the fail-open paths.

**Suggested fix:** For public artifact contracts, enumerate every consumed field and source root;
mutate each field semantically, contaminate every URL component, and place sentinels one directory
level below every recursive root. Require each probe to name the expected validation path and sort
filesystem inputs before asserting aggregated failures.
