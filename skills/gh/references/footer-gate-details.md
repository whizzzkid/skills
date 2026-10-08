# Outbound Footer — Detailed Rules

## Footer Block (verbatim)

```
---
<sup>Generated using [wk-skills](https://github.com/whizzzkid/skills/tree/main@%7B<UTC>%7D) and multiple agents/models. DM me your feedback.</sup>
```

## Scope

- **The footer covers every agent-authored outbound body — not only GitHub.**
  Any body this agent composes for an external system carries this canonical
  footer: Jira issue/comment bodies (MCP `addCommentToJiraIssue`/
  `editJiraIssue`), Slack messages, doc bodies. The owning skill injects it at
  render time; a non-GitHub write path is not an exemption. A terse factual
  status line (lifecycle comment) is still an outbound body — it carries the
  footer too.
- **Paste the literal footer block below into the payload at render time —
  never hand-write or paraphrase the attribution.** Composing an ad-hoc
  string (e.g. a `Assisted by Claude Code (model)` line) at payload-build
  time defeats the verbatim guarantee and ships a non-canonical footer.
  Read this block from the skill and inject it; do not reconstruct it from
  memory. The block is verbatim except the `<UTC>` timestamp field (below).

## Point-in-Time Link

Pin the `wk-skills` link to the post-time snapshot. The link path is
`tree/main@%7B<UTC>%7D`, where `<UTC>` is a render-time UTC timestamp — so a
reader sees the skills exactly as they were when the message posted. A bare
repo-root link tracks moving HEAD and misattributes once HEAD advances. Stamp
it per post:
- `date -u +%Y-%m-%dT%H:%M:%SZ` → substitute for `<UTC>`.
- URL-encode only the braces (`{`→`%7B`, `}`→`%7D`); `@`, `T`, `:`, `Z` stay
  literal. Raw braces 404; GitHub resolves `main@{<ts>}` to the commit
  at/before that instant and renders the tree as of then.

## Commit-Message Footer vs Outbound Footer

**The commit-message footer is a DIFFERENT string — never ship it on a
GitHub/outbound body.** The `wk-commit` trailer (`🦾 Generated with
[wk-skills](...) and multiple models.`) belongs only in commit messages and
PR-body trailers; both footers open with "Generated ... wk-skills", so the two
are easy to conflate — type neither from memory.

## Pre-Emit Gate

**Run mechanically on EVERY outbound body before posting, no
exceptions.** A footer defect on one surface is almost always on every body
posted the same way, so sweep all surfaces (PR body, review bodies, every
comment/reply) in one pass. For each body string:

```bash
grep -qF 'DM me your feedback.</sup>' <<<"$body" || echo "REJECT: canonical footer absent"
grep -qF '🦾 Generated with' <<<"$body" && echo "REJECT: commit-trailer variant present"
grep -qE 'tree/main@%7B[0-9T:Z-]+%7D' <<<"$body" || echo "REJECT: footer link not pinned to post-time snapshot"
awk 'prev!="" && $0=="---"{f=1} {prev=$0} END{exit f}' <<<"$body" || echo "REJECT: non-blank line directly above ---  → renders as setext H2 heading"
```

A REJECT on either line blocks the post — fix the footer and re-check before writing.
A render-time append is NOT this gate — appending is not verifying. Re-run these
greps on the FINAL body string immediately before EACH POST (every inline reply,
not only the PR description); a per-reply body composed from memory is the
common skip that ships the commit-trailer variant.

## Placement Rules

- Footer is the **last** content in the message. Nothing follows it.
- Separate from prior content with a **blank line** above the `---` — build the
  block as `"\n\n---\n<sup>…"` (two newlines). A single `\n` is a line break, not
  a blank line: a non-blank line immediately followed by `---` is a GFM setext H2
  heading (renders the paragraph large/bold), not a horizontal rule.
- When the calling skill already specifies a richer footer (e.g.,
  `wk-commit` PR-body sync footer, `wk-pr-review` review-body
  closing line), append this footer **after** the skill-specific
  one — never replace the skill-specific footer.
- When editing an existing PR body that already contains this
  footer, do not duplicate it — re-emit the body with the footer
  appearing exactly once at the end.
- **Post-write gate for PR bodies:** re-fetch the server-returned body and rerun
  footer placement validation. Generated reference metadata after the footer →
  preserve it before the footer, submit once more, then re-fetch; recurrence stops.

## Surfaces

Apply to:

- PR descriptions (body of `gh pr create` and `gh pr edit`).
- Review bodies (the top-level `body` of a `/pulls/{n}/reviews` POST).
- Inline review comments (each entry's `body` in the `comments[]`
  array — the footer goes at the end of the comment body).
- Conversation comments on PRs and issues.
- Replies to existing review threads.

## Exceptions

- Suggestion fences (` ```suggestion `) embedded inside a comment
  body do not carry the footer themselves; the footer applies to
  the enclosing comment.
- Resolution / state-change mutations (resolving a thread, marking
  a PR ready, merging) carry no message body and are exempt.

If the calling skill emits a payload via a template (heredoc, file,
jq construction), inject the footer at template-render time so a
forgotten append cannot ship a footer-less message.
