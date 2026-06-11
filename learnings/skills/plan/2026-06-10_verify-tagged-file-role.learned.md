---
skill: wk-plan
date: 2026-06-10
type: correction
severity: medium
---

Verify that a user-tagged file matches the role they describe before accepting it as a plan target.

**What happened:** The user tagged a file as "the one that validates checks on target repos" but tagged a config-safety check file instead of the check-validation file that actually performs that role. The agent accepted the tagged file without cross-checking the description against the file's content, and proceeded to plan changes to the wrong file. The user caught the error and said "I mis-tagged, you should've brought it up."

**Root cause:** During Step 1 (research), the plan probe reads the user's artifact references at face value. When a user says "update X which does Y" but the file's actual description contradicts Y, and a better-matching file exists in the same directory, the agent lacks a cross-check step.

**Suggested fix:** Add a "file-role sanity check" to Step 1 of wk-plan: when the user tags a file by path and describes its role in prose, read the file's actual description/purpose and compare. If a sibling file in the same directory is a better match for the described role, surface the ambiguity before drafting the plan. One-line check: "The file you tagged does X — you described a file that does Y; did you mean `{better-match}`?"
