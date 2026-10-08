# Description Quality Gate (subroutine)

Invoked from any writable stage (Stage 2, 3, 4). Idempotent — safe to call
repeatedly per branch; skips silently after the first successful append.

## Thinness criteria

Treat `fields.description` as **thin** when any hold:

- Empty, null, or whitespace-only.
- Body text (after stripping markup) fewer than 40 characters.
- Body repeats only the ticket summary or a placeholder (`TBD`, `n/a`,
  `see slack`, etc.).

## Enrichment flow

- Thin → propose appending a structured context block. Never overwrite
  existing content — wrap it as `<existing details>`.
- Pre-fill `Date` with today's date (UTC, `YYYY-MM-DD`). Pre-fill
  `Problem` / `Decision` / `Trade-offs` / `Context` from the
  highest-signal source available at this stage (branch name, recent
  prompts, PR title/body, linked commits); leave empty otherwise.
- Append template:

  ```
  <existing details>

  ---

  Date: <YYYY-MM-DD>
  Problem:
  Decision:
  Trade-offs:
  Context:

  ---
  ```

- Confirm before writing — Manual ticket operations HARD RULE applies.
  Present the proposed merged description, wait for explicit approval,
  then call `editJiraIssue`.
- Skip silently when description already exceeds the thinness threshold OR
  this branch already had a successful enrichment append this session.

Report once on append:

> "Jira: {KEY} description enriched with context block."
