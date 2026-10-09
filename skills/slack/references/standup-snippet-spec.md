# Standup Snippet Spec

Canonical spec for the daily standup snippet rendered by wk-sitrep start.
Public team artifact -- every rule below is a HARD RULE.

## Structure (Context C -- HTML for clipboard)

```
- pointing_left Yesterday:
  - {achievement} <a href="...">repo#NNN</a>
  - {group label}:
    - <a href="...">repo#NNN</a> -- {short description}
- pointing_right Today:
  - {priority} <a href="...">repo#NNN</a>
  - {group label}:
    - <a href="...">repo#NNN</a> -- {short description}
- raised_hand Blockers:
  - {blocker} <a href="...">{link label}</a>
```

- Yesterday, Today, Blockers are top-level `<li>` of a single `<ul>`; sub-points
  are nested `<ul><li>` children. Never emit as `<p>`, `<b>`, or `<h*>`.
- Each leaf bullet carries at most one external link. Multiple artifacts: parent
  bullet (group label, no link) + one child bullet per artifact with its link.
- GitHub PR/issue link labels: always `repo#number`. Bare `#NNN` forbidden.
- **Emoji LEADS every heading** -- emoji is first character of
  Yesterday/Today/Blockers bullet. Never trail it.
- Blockers always present: emit heading with `- None` child when empty.
- Build copy button with `ClipboardItem` writing `text/html` with real `<a>` tags
  and `<ul><li>` nesting. Never copy `textContent` only.

## Privacy filter (HARD RULE)

Apply to every candidate item before it lands in the snippet:

- Drop interview/hiring/candidate items in specific form. If interview must
  appear, render generically ("L4 SE candidate interview 12pm") -- no names,
  CodeSignal URLs, Greenhouse/scorecard links.
- Drop personal HR, performance, QPR, or compensation actions.
- Drop personal communications (farewell replies, DMs, condolences).
- Drop anything flagged as private or undecided for public sharing.
- When uncertain, omit. Standup is public; dashboard is private.

## Caller contract

When invoked as `wk-slack Standup Snippet`, return:

- HTML payload (`<ul>...</ul>`) ready to embed in dashboard card and copy via
  `ClipboardItem`.
- Plaintext fallback (Context B) for markdown brief: `-` bullets, 2-space indent,
  bare URLs.
- Filtered-out items (so caller keeps them in private dashboard).

Callers must not re-implement the structure, link format, or privacy filter
inline -- invoke this section instead.
