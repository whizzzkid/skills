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
  - mcp__claude_ai_Slack_Org_Offical__slack_send_message
  - mcp__claude_ai_Slack_Org_Offical__slack_send_message_draft
  - mcp__claude_ai_Slack_Org_Offical__slack_search_public_and_private
  - mcp__claude_ai_Slack_Org_Offical__slack_search_channels
  - mcp__claude_ai_Slack_Org_Offical__slack_read_channel
  - mcp__claude_ai_Slack_Org_Offical__slack_read_thread
  - mcp__claude_ai_Slack_Org_Offical__slack_read_user_profile
  - mcp__claude_ai_Slack_Org_Offical__slack_add_reaction
  - mcp__claude_ai_Slack_Org_Offical__slack_search_users
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: communication
metadata:
  author: whizzzkid
  version: '2026.05.25-212935'
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-4.1-mini
    gemini: gemini-2.5-flash

---

# wk-slack

Post Slack messages in Nishant's voice: emoji-led heading, concise tl;dr,
structured body, optional CC, warm close. Always Slack mrkdwn — never
standard Markdown.

## When to Use

- Posting a feature announcement or milestone to a public channel
- Sharing a PR or doc for review
- Sending a status update or weekly digest
- Asking for approvals, feedback, or eyes on something
- Any Slack message where voice and format matter

---

## Step 1: Resolve channel and intent

- Identify the target channel. If not named, ask.
- Clarify the message type — pick one:
  - **announcement** — a milestone, launch, or plan going public
  - **review-request** — asking for eyes on a PR, doc, or spec
  - **status-update** — progress report or digest
  - **ask** — a specific request for action or approval
  - **fyi** — informational link or note, no action needed
- Collect content: links, epic lists, PR numbers, context sentences.

---

## Step 2: Draft with the message template

Apply the template matching the message type:

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

- **Heading emoji is topical** — pick an emoji that matches the subject
  (`:eyes:` for review, `:mega:` for milestone, `:dart:` for goal,
  `:page_facing_up:` for doc, `:git:` for code, `:tada:` for launch).
- **Em-dash `—` in headings** — separates the noun from the context:
  `*Fresh Eyes Q1 FY27 — Vision doc is up for review*`.
- **tl;dr is conversational, not corporate** — "We've been heads-down
  turning async discussions into a structured plan" not "This document
  summarizes Q1 FY27 objectives."
- **Numbered lists for ordered/sequential items** — epics, stack PRs,
  rollout steps.
- **Bullets for unordered** — pending reviews, options, links.
- **Nested sub-bullets** for stacked PRs or multi-part items.
- **Closing CTA is an invitation, not a demand** — "Would love eyes on
  sequencing and the open questions" not "Please review by EOD."
- **Warm sign-off when ending a week or heading OOO** — "Have a good
  weekend folks" / "I'll be away Monday".
- **Excitement is genuine and brief** — "Exciting things are coming!!!"
  works; excessive hype does not.
- **Direct asks use "Hey Folks"** — informal opener, one crisp sentence,
  link, done.
- **Never over-tag** — CC only people whose attention the message
  genuinely requires. One or two `<@handle>` is normal; a list of five
  is noise.
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
- Whether it was sent as a top-level message or thread reply

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

- Slack MCP connector (`mcp__claude_ai_Slack_Org_Offical__*`)
- Channel ID or channel name to resolve to ID via `slack_search_channels`
- User handle (from `slack_read_user_profile` if only a name is given)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn slack`).
