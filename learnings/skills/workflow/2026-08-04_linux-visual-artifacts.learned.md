---
skill: wk-workflow
date: 2026-08-04
type: pattern
severity: medium
verified-against-source: yes
---

Review platform-specific visual baselines from the CI artifact.

**What happened:** A visible change passed local screenshots but required separate Linux visual baselines after the remote comparison surfaced the exact affected snapshots.

**Root cause:** Review screenshots and test baselines had distinct generation platforms and purposes, so updating one did not update the other.

**Suggested fix:** For visible changes with platform-pinned baselines, plan a CI artifact review step and replace only snapshots whose actual, expected, and diff images confirm the intended change.
