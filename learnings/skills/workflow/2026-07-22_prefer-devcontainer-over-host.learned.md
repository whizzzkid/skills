---
skill: wk-workflow
date: 2026-07-22
type: correction
severity: medium
---

When a repo ships a devcontainer, prefer it for build/test tooling over host-native runners — don't default to the host just because docs don't spell out a devcontainer workflow.

**What happened:** The agent ran tests/lint host-native and hit a broken host database (a stuck package-manager version upgrade). It concluded the documented path was host-native and stayed there. The user asked "why are we not using the devcontainer?" and then explicitly instructed to switch — the project had a working `.devcontainer/` (app + db + cache + queue services) all along.

**Root cause:** The agent treated "the project guide documents host-native commands" as "host-native is the intended path," and never checked for a `.devcontainer/` directory when the host toolchain broke. Absence of a documented devcontainer workflow is not evidence a devcontainer is absent.

**Suggested fix:** In the environment/pre-flight phase, probe for a `.devcontainer/` (or equivalent container dev setup) before selecting a tooling environment; when one exists and is runnable, prefer it, and when the host toolchain breaks, check for a containerized alternative before diagnosing/repairing the host in place.
