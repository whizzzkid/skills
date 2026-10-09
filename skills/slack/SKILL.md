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
  version: "2026.10.09-184159"
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-5.6-terra
    google: gemini-2.5-flash

---

# wk-slack

Post Slack messages in Nishant's voice: emoji-led heading, concise tl;dr, structured body, optional CC, warm close.
Always Slack mrkdwn — never standard Markdown.

Use for: announcements, PR/doc review requests, status updates/digests, approval asks, any voice-sensitive post.

## Step 1: Resolve channel and intent

- Identify the target channel; if not named, ask.
- Pick the type: **announcement** (milestone/launch/plan going public), **review-request** (eyes on PR/doc/spec),
  **status-update** (progress/digest), **ask** (action or approval), **fyi** (link or note, no action).
- Collect content: links, epic lists, PR numbers, context sentences.

## Step 2: Draft from the template

Apply the template for the type from [references/message-templates.md](references/message-templates.md).

## Step 3a: Pick the right formatting context

**HARD RULE — Slack has three formatting contexts. Pick the right one before writing anything; mixing them silently
breaks links and structure.**

- **Context A — Slack API / Bot messages (`chat.postMessage`):** mrkdwn: links `<url|label>`, bold `*text*`, italic
  `_text_`, bullets `-` at line start, 4-space indent for nesting. Never use HTML tags — they post as literal text.
- **Context B — plain text typed/pasted into the compose box:** bare URLs auto-linkify; `*bold*` and `_italic_` render;
  `<url|label>` does **not** render (literal angle brackets). Use bare URLs when no label is available; else use
  Context C for clickable labels.
- **Context C — copy-to-clipboard from a web dashboard into the compose box:** write `text/html` via `ClipboardItem`
  with real `<a href>` tags and nested `<ul><li>` — Slack desktop honors the HTML MIME type and keeps labels and
  indentation. `textContent`-only copies strip every link. Fall back to `navigator.clipboard.writeText(el.innerText)`
  when `ClipboardItem` is unavailable (older browsers, insecure context): labels degrade to plain text, copy still
  works.

Default to Context C for a dashboard copy button, Context A only when posting via the Slack API, Context B only for
ad-hoc plaintext drops.

## Step 3: Apply formatting rules (mrkdwn — not Markdown)

**HARD RULE — never use standard Markdown in Slack messages.** Slack renders `mrkdwn`; `**bold**` shows literal
asterisks.

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

Convert before sending: `**...**` → `*...*`, `~~...~~` → `~...~`, `[label](url)` → `<url|label>`.

## Step 4: Voice and style

- Pick a topical heading emoji (`:eyes:` review, `:mega:` milestone, `:dart:` goal, `:page_facing_up:` doc, `:git:`
  code, `:tada:` launch); announcements always get one.
- Separate noun from context with an em-dash in headings: `*Fresh Eyes Q1 FY27 — Vision doc is up for review*`.
- Write the tl;dr conversationally ("We've been heads-down turning async discussions into a structured plan"), not
  corporately ("This document summarizes Q1 FY27 objectives.").
- Number ordered items (epics, stack PRs, rollout steps); bullet unordered ones; nest sub-bullets as `    ◦ ` for
  stacked PRs or multi-part items, never nested `-`.
- Close with an invitation ("Would love eyes on sequencing and the open questions"), not a demand ("Please review by
  EOD").
- Add a warm sign-off only when ending a week or heading OOO ("Have a good weekend folks" / "I'll be away Monday").
- Keep excitement genuine and brief ("Exciting things are coming!!!"); no excessive hype.
- Open direct asks with "Hey Folks": one crisp sentence, link, done.
- Never over-tag: CC only people whose attention is genuinely required; one or two `<@handle>` is normal, five is noise.
- No signature block, no "Thanks, Nishant": the Slack profile is the signature.

## Step 5: Pick the send mechanism

Take the first that applies: 1) channel ID unknown → `slack_search_channels` first; 2) user should review first →
`slack_send_message_draft`, show it, wait for approval; 3) thread reply → `slack_send_message` with `thread_ts`;
4) ready now → `slack_send_message`.

**HARD RULE — always show the composed message to the user before posting, unless they have explicitly asked for a
fire-and-forget post.** Slack messages are hard to retract; approval is cheap.

## Step 6: Post and confirm

Report channel name, permalink or message ts, and whether it is top-level or a thread reply.

## Standup Snippet

See [references/standup-snippet-spec.md](references/standup-snippet-spec.md) for the full standup structure (Context C
HTML), privacy filter, and caller contract. Every rule there is a HARD RULE. Callers must not re-implement the
structure, link format, or privacy filter inline — invoke the spec instead.

## Requirements

- Slack MCP connector (`mcp__claude_ai_Slack_*`).
- Channel ID, or channel name resolved via `slack_search_channels`.
- User handle (via `slack_read_user_profile` if only a name is given).

## Post-Completion

Invoke `wk-learn slack`.
