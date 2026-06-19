---
skill: wk-workflow
date: 2026-06-18
type: correction
severity: medium
---

Hardcoded a platform/architecture string in a beta code path when an analogous stable code path already computed it dynamically.

**What happened:** The beta binary name was written as a hardcoded string (e.g., `<tool>-beta-linux-x64`) even though the immediately preceding stable binary path computed `os` and `arch` from `uname -s` / `uname -m`. The user had to point this out explicitly: "maybe instead of hard-coding we should determine the platform and architecture like we do it at the other call site?"

**Root cause:** When adding a parallel code path (beta alongside stable), the agent did not cross-check whether the stable path had already solved the same sub-problem. The beta path was authored in isolation.

**Suggested fix:** Before hardcoding any constant that encodes environment-specific data (OS, arch, version, path), grep the file for analogous values in existing paths. If a sibling path already computes the value dynamically, reuse that computation rather than hardcoding.
