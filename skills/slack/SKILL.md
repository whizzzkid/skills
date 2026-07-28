---
name: wk-slack
description: >-
  Compose and send Slack messages — announcements, PR review requests, status
  updates, and channel posts — following the user's established communication
  style and Slack mrkdwn formatting rules. Use when asked to post on Slack,
  draft a Slack message, announce a feature, share a PR for review, or send
  a status update to a public or private channel.
argument-hint: '[channel] [message-intent]'
allowed-tools:
  - "mcp__claude_ai_Slack_*__slack_send_message"
  - "mcp__claude_ai_Slack_*__slack_send_message_draft"
  - "mcp__claude_ai_Slack_*__slack_search_public_and_private"
  - "mcp__claude_ai_Slack_*__slack_search_channels"
  - "mcp__claude_ai_Slack_*__slack_read_channel"
  - "mcp__claude_ai_Slack_*__slack_read_thread"
  - "mcp__claude_ai_Slack_*__slack_read_user_profile"
  - "mcp__claude_ai_Slack_*__slack_add_reaction"
  - "mcp__claude_ai_Slack_*__slack_search_users"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: communication
metadata:
  author: whizzzkid
  version: "2026.07.28-171109"
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-5.6-terra
    google: gemini-2.5-flash

---

# wk-slack

Post Slack messages in Nishant's voice: emoji-led heading, concise tl;dr,
structured body, optional CC, warm close. Always Slack mrkdwn — never
standard Markdown.

## When to Use

- Feature announcement or milestone → public channel
- Sharing a PR or doc for review
- Status update or weekly digest
- Asking for approvals, feedback, or eyes on something
- Any Slack message where voice and format matter

---

## Step 1: Resolve channel and intent

- Identify target channel → if not named, ask.
- Pick message type:
  - **announcement** — milestone, launch, or plan going public
  - **review-request** — eyes on a PR, doc, or spec
  - **status-update** — progress report or digest
  - **ask** — specific request for action or approval
  - **fyi** — informational link or note, no action needed
- Collect content: links, epic lists, PR numbers, context sentences.

---

## Step 2: Draft with the message template

Apply template matching the message type:

### Announcement / review-request

```
:emoji: *Heading — Subtitle or Context*

tl;dr one or two sentence summary of what's happening and why.

:section-emoji: Detail line or paragraph.

1. First item — short description
2. Second item — short description
3. ...

:link-emoji: Link label: <url|display text>

Closing ask or CTA — what you need from readers.
```

### Status update / digest

```
*Heading*

Pending / done items:
• Item — <url|link>
• Item — <url|link>
    ◦ Sub-item — <url|link>

Closing note (sign-off, next steps, or weekend wish).
```

### Ask / approval request

```
Hey <@handle> [or "Folks"],

One-line context — what you need and why.

:link-emoji: <url|label>

Optional: what happens next or deadline.
```

---

## Step 3a: Pick the right formatting context

**HARD RULE — Slack has three formatting contexts. Pick the right
one before writing anything; mixing them silently breaks links and
structure.**

- **Context A — Slack API / Bot messages (`chat.postMessage`):** Slack
  mrkdwn. Links `<url|label>`; bold `*text*`; italic `_text_`; bullets
  `-` at line start, 4-space indent for nesting. Never use HTML tags —
  they post as literal text.
- **Context B — Plain text typed/pasted into compose box:** bare URLs
  auto-linkify; mrkdwn `*bold*` and `_italic_` render. `<url|label>`
  does **not** render — appears as literal angle brackets. Use bare
  URLs when no label available; else use Context C for clickable labels.
- **Context C — Copy-to-clipboard from a web dashboard into compose
  box:** write `text/html` to clipboard via `ClipboardItem` with real
  `<a href>` tags and nested `<ul><li>` structure → Slack desktop
  respects the HTML MIME type on paste, renders clickable labels with
  preserved indentation. `textContent`-only copies strip every link.
  Fall back to `navigator.clipboard.writeText(el.innerText)` when
  `ClipboardItem` is unavailable (older browsers, insecure context) —
  labels degrade to plain text but the copy still works.

Default Context C for a dashboard copy button. Context A only when
posting via the Slack API. Context B only for ad-hoc plaintext drops.

---

## Step 3: Apply formatting rules (mrkdwn — not Markdown)

**HARD RULE — never use standard Markdown in Slack messages.** Slack
renders its own `mrkdwn` dialect; `**bold**` appears as literal asterisks.

| Element | Slack mrkdwn | Never use |
|---------|-------------|-----------|
| Bold | `*text*` | `**text**` |
| Italic | `_text_` | `*text*` (when italic) |
| Strikethrough | `~text~` | `~~text~~` |
| Link with label | `<url\|label>` | `[label](url)` |
| Unordered bullet | `•` or `-` at line start | `*` as bullet |
| Sub-bullet | `    ◦ ` (4-space indent + ◦) | `  -` nested |
| Section header | `:emoji: *Bold line*` | `## Heading` |
| Code inline | `` `code` `` | same |
| Code block | ` ```code``` ` | same |
| Emoji | `:name:` | Unicode directly for custom emojis |
| Flow arrow | `→` | `->` |

Convert before sending: `**...**` → `*...*`, `~~...~~` → `~...~`,
`[label](url)` → `<url|label>`.

---

## Step 4: Voice and style rules

Derived from real messages posted by the user:

- **Heading emoji is topical** — match the subject (`:eyes:` review,
  `:mega:` milestone, `:dart:` goal, `:page_facing_up:` doc, `:git:`
  code, `:tada:` launch).
- **Em-dash `—` in headings** separates noun from context:
  `*Fresh Eyes Q1 FY27 — Vision doc is up for review*`.
- **tl;dr conversational, not corporate** — "We've been heads-down
  turning async discussions into a structured plan", not "This document
  summarizes Q1 FY27 objectives."
- **Numbered lists for ordered/sequential** — epics, stack PRs, rollout steps.
- **Bullets for unordered** — pending reviews, options, links.
- **Nested sub-bullets** for stacked PRs or multi-part items.
- **Closing CTA is an invitation, not a demand** — "Would love eyes on
  sequencing and the open questions", not "Please review by EOD."
- **Warm sign-off when ending a week or heading OOO** — "Have a good
  weekend folks" / "I'll be away Monday".
- **Excitement genuine and brief** — "Exciting things are coming!!!"
  works; excessive hype does not.
- **Direct asks use "Hey Folks"** — informal opener, one crisp sentence,
  link, done.
- **Never over-tag** — CC only people whose attention is genuinely
  required. One or two `<@handle>` is normal; a list of five is noise.
- **No signature block / no "Thanks, Nishant"** — the Slack profile is
  the signature.

---

## Step 5: Pick the right send mechanism

| Situation | Tool |
|-----------|------|
| Ready to post now | `slack_send_message` |
| Want user to review first | `slack_send_message_draft` — show the draft, wait for approval |
| Unsure of channel ID | `slack_search_channels` first |
| Replying to a thread | `slack_send_message` with `thread_ts` |

**HARD RULE — always show the composed message to the user before posting,
unless they have explicitly asked for a fire-and-forget post.** Slack messages
are hard to retract; approval is cheap.

---

## Step 6: Post and confirm

After sending, confirm:
- Channel name
- Permalink or message ts
- Top-level message or thread reply

---

## Standup Snippet

Canonical spec for the daily standup snippet rendered by wk-sitrep start
(and any other caller). Public team artifact — every rule below is a HARD RULE.

**Structure (Context C — HTML for clipboard, bullets shown for
illustration):**

```
- 👈🏽 Yesterday:
  - {achievement} <a href="…">repo#NNN</a>
  - {group label}:
    - <a href="…">repo#NNN</a> — {short description}
    - <a href="…">repo#NNN</a> — {short description}
- 👉🏽 Today:
  - {priority} <a href="…">repo#NNN</a>
  - {group label}:
    - <a href="…">repo#NNN</a> — {short description}
- ✋🏽 Blockers:
  - {blocker} <a href="…">{link label}</a>
```

- Yesterday, Today, Blockers are top-level `<li>` of a single `<ul>`;
  sub-points are nested `<ul><li>` children. Never emit them as `<p>`,
  `<b>`, or `<h*>` — flat headings collapse Slack's paste indentation.
- Each leaf bullet carries **at most one** external link. Multiple
  artifacts → parent bullet (group label, no link) + one child bullet
  per artifact, each carrying its single link.
- GitHub PR/issue link labels are always `repo#number` (e.g.,
  `somerepo#NNN`). Bare `#NNN` forbidden — repo context is lost on
  paste outside the original surface.
- **Emoji LEADS every heading — `👈🏽`/`👉🏽`/`✋🏽` is the first character of the
  Yesterday/Today/Blockers bullet respectively. Never trail the emoji at the end
  of a heading line (`Yesterday 👈🏽` is wrong; `👈🏽 Yesterday` is right).**
- Blockers always present: emit `- ✋🏽 Blockers:` with a single `- None` child
  when there are none. Never drop the heading or its emoji.
- Build the copy button with `ClipboardItem` writing `text/html` with
  real `<a>` tags and `<ul><li>` nesting. Never copy `textContent` only
  — it strips every link.

### Standup privacy filter (HARD RULE)

Apply to every candidate item **before** it lands in the snippet. The
morning/evening dashboard may keep filtered items privately; the standup may not.

- Drop interview, hiring, or candidate-pipeline items in specific form.
  If an interview must appear, render generically (e.g., "L4 SE
  candidate interview 12pm") — never include candidate names,
  CodeSignal URLs, Greenhouse/scorecard links, or any other
  hiring-pipeline PII.
- Drop personal HR, performance, QPR, or compensation actions (e.g.,
  "QPR self-review window closes", "1:1 with manager").
- Drop personal communications (farewell replies, DMs, condolences,
  social-channel pings).
- Drop anything the caller flagged as private or has not yet decided to
  share publicly.
- When uncertain, omit. Standup is public; dashboard is private.

### Caller contract

When invoked as `wk-slack §Standup Snippet`, return:

- HTML payload (`<ul>…</ul>`) ready to embed in a dashboard card and
  copy to clipboard via `ClipboardItem`.
- Plaintext fallback (Context B) for the markdown brief: `-` bullets,
  2-space indent for nesting, bare URLs.
- Filtered-out items (so the caller keeps them in the private dashboard).

Callers (wk-sitrep) must **not** re-implement the structure, link
format, or privacy filter inline — invoke this section instead.

---

## Quick Reference

| Message type | Opener pattern |
|---|---|
| Announcement | `:emoji: *Subject — Subtitle*` |
| Milestone | `:mega: *Bold milestone statement*` |
| Review request | `:eyes: *Subject — doc/PR is up for review*` |
| Status digest | `*Pending Reviews:* \n • item \n • item` |
| Ask / approval | `Hey Folks, \n One-line ask. \n :link: <url\|label>` |
| FYI link-drop | Short sentence + `<url\|display text>` |

---

## Common Mistakes

- Using `**bold**` — renders as literal `**`. Always `*bold*`.
- Using `[label](url)` — renders as literal brackets. Always `<url|label>`.
- Posting without showing draft — ask before sending to public channels.
- Over-tagging — tag only who genuinely needs the ping.
- No emoji in heading for announcements — pick a topical one, it aids scannability.
- Using nested `-` for sub-bullets — use `    ◦ ` (4-space indent + ◦).
- Writing a formal "Thanks" sign-off — Slack is informal; end with the ask or a warm note.

---

## Requirements

- Slack MCP connector (`mcp__claude_ai_Slack_*`)
- Channel ID, or channel name → resolve to ID via `slack_search_channels`
- User handle (from `slack_read_user_profile` if only a name is given)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn slack`).
