---
skill: wk-pr-resolve
date: 2026-06-26
type: correction
severity: high
---

Read the user-provided artifact first before any implementation.

**What happened:** User said "there is a config safety issue, there's a comment on the PR." The agent fetched the comment but then ignored it and implemented a performance fix instead. The actual fix (7-line private method extraction for guard-pattern consistency) was not done until multiple CI rounds later, after introducing two additional bugs in the process.

**Root cause:** The agent saw the bot review comment, noted one finding as the stated issue, but then got distracted by a different finding in the same comment and acted on that instead. Each subsequent CI run introduced a new finding that the agent chased, compounding the deviation.

**Suggested fix:** When the user points to a specific artifact (PR comment, CI log, bot review), extract and name the exact finding they referenced before writing any code. If multiple findings are present, ask which one the user means rather than inferring. Do not act on adjacent findings until the user's stated issue is resolved.
