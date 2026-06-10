---
skill: wk-workflow
date: 2026-06-10
type: gap
severity: medium
---

When switching a consumer script from a hardcoded filename to directory scanning, audit the upstream producer first.

**What happened:** A release script was changed from looking for one fixed filename to scanning an entire output directory with `readdirSync`. The initial implementation did not check what the upstream build script actually wrote to that directory. The build script still produced a tarball in addition to the individual binaries, so the new scan would have published the tarball as an unintended package entity. The adversarial review caught this via sibling-script audit, but the planning phase missed it.

**Root cause:** The planning phase identified the change needed in the consumer (the release script) but did not include a step to enumerate every file the producer (the build script) creates. "What does the directory actually contain?" is a required pre-condition when switching from a named-file pattern to a directory-scan pattern.

**Suggested fix:** Add a planning probe: when a script switches from `statSync(specificFile)` / named-file lookup to `readdirSync(dir)` or a glob, grep the upstream build/compile script that populates the directory and list every file it writes. Include a filter step that explicitly includes or excludes each file type — never rely on directory contents being exactly the expected set.
