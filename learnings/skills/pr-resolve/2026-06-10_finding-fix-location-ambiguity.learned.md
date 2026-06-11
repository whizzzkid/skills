---
skill: wk-pr-resolve
date: 2026-06-10
type: gap
severity: low
---

When a bot finding is anchored on file A but the fix belongs in file B, the suggestion must state this explicitly.

**What happened:** A bot commented on a source file's comment block that advertised a URL inconsistent with what the README documented. The agent presented this as a single merged finding covering both files, but did not clearly state that the README was already correct and only the source-file comment needed updating. The user had to ask "do the comments apply to readme?" to clarify.

**Root cause:** The suggestion format ("Suggested fix" field) described what to change conceptually but did not explicitly name which file to edit and which to leave alone — especially important when the bot's anchor file (release.mjs) is not the file that needs changing (the README was already correct).

**Suggested fix:** When a finding's anchor file and the file containing the actual fix differ, lead the "Suggested fix" with an explicit line: "Fix is in `{file-to-change}` — `{anchor-file}` is already correct and does not need changes." This prevents the user from wondering whether both files need editing.
