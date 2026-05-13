---
skill: wk-sharpen
date: 2026-05-13
type: correction
severity: medium
---

Read the full learning file before declaring it already-covered.

**What happened:** A learning file was classified as already-covered based on matching two surface-level rules in the skill, without reading the file in full. The file contained several additional patterns (mise profiles, host config mounts, postStartCommand autostart, apt audit, log paths) that were not in the skill yet. The user had to intervene and redirect to finish the incorporation.

**Root cause:** The check "does the skill already cover this topic?" was answered at the topic level rather than at the content level. Two matching rules were enough to satisfy the check, leaving the rest of the file unread.

**Suggested fix:** In the sharpen "already-covered" check, require reading the full learning file before declaring it covered. Match at the individual rule/bullet level, not the topic level. If any line in the file teaches something not already in the skill, treat as "partial" and distill the missing parts.
