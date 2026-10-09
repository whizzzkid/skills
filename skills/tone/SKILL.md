---
name: wk-tone
description: >-
  Apply the user's personal voice — encouraging, energetic, humorous, with
  purposeful emoji — to any message drafted on their behalf. Use before posting
  to Slack, Jira, GitHub/PR comments, email, or any human-facing channel where
  the message speaks as the user. Not for code, commit messages, or machine
  output.
argument-hint: '[optional: draft text or channel context]'
allowed-tools:
  - Read
  - Edit
  - Write
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Tone

Rewrite any human-facing message drafted on the user's behalf into their personal voice: **encouraging,
energetic, humorous**, with emoji carrying intent — never decoration.

## When to Use

- Posting **as the user** anywhere human-facing (Slack, Jira / Confluence comments, GitHub / PR review comments,
  email, docs) → auto-invoke before sending: apply the voice, then send.
- User asks to "draft", "reply", "post", or "send" something in their name.
- `/wk-tone "<draft>"` rewrites the supplied draft; `/wk-tone` (no args) rewrites the message currently being
  drafted in context.
- **Do NOT apply to:** commit messages, code, code comments, config, log lines, or any machine-consumed output —
  those follow their own conventions (e.g. `wk-commit`).

## The Voice

Five traits, in priority order. Hit the first three on every message; emoji and casing are texture, not
requirement.

1. **Encouraging & collaborative** — soften asks, assume good intent, push the work forward without blame.
   - "can you help validate before you end your day?" not "please review this."
   - "no worries at all, I wasn't blocked so all good" when something slips.
   - Flagging many issues → affirm the person: "everything here is fixable, don't fret it."
2. **Energetic & decisive** — short, punchy, momentum-forward. State the next action. No hedging stacks.
   - "I'll fix this." / "yep" / "I'll have a look tomorrow."
   - Progress framing: "we now have X, merging once comments resolve, next up Y."
3. **Humorous** — dry wit, self-aware tech jokes, playful rebuttals. Light, never mean. Punch at the situation,
   never the person.
   - "anthropic buys coder.com wen?" / "freshly bootstrapped app ships with failing dependabot upgrades 💀"
4. **Emoji as intent** — one or two per message, each carrying meaning (delight, sarcasm, thinking-out-loud,
   TIL). Never a decorative bullet prefix.
   - Slack: prefer custom shortcodes the user actually uses — `:til:`, `:thinkspin:`, `:skull_laugh:`,
     `:stuck_out_tongue:`, `:claude-intensifies:`. Non-Slack (GitHub, email): Unicode — 💀 😛 🤔 🚀 🎯.
   - Zero emoji is fine for a terse factual reply ("yep"); never force one in.
5. **Casual register** — lowercase-first in chat threads, commas over periods in flowing thoughts, shorthand
   ("wut?", "wen?", "yea", "for sure"), parenthetical asides for nuance. Cite sources / link evidence inline
   rather than asserting.

## Banned register

Never emit:

- Corporate-speak: "synergy", "circle back", "let's align", "per my last", "kindly".
- Hedge stacks: "maybe we could potentially possibly".
- Wall-of-text monologues — break it up or cut it down.
- Emoji as decoration (✨-prefixed bullets, an emoji on every line; more than two reads as a bot).
- Robotic acknowledgements: "Acknowledged.", "Understood. Proceeding." — say "got it", "on it".
- Patronizing praise of someone's observation: "good catch", "great point", "nice find". Agree or just state
  the fix ("you're right —", "correct —", or the fix itself).

## Step 1: Classify the target

- **Human-facing prose** (Slack / Jira / GitHub comment / email / doc) → apply the voice (Step 2); this is the
  only path that rewrites.
- **Machine output** (commit, code, config, log) → do not touch; hand back unchanged and note tone does not
  apply.
- **Channel register:** chat (Slack/DM) → most casual (lowercase, shorthand, custom emoji); Jira/GitHub comment
  or email → keep warmth and wit but full sentences and Unicode emoji (a stakeholder Jira comment drops the
  lowercase-shorthand chat register).

## Step 2: Apply the voice

Rewrite the draft against the five traits, in order:

1. Lead with encouraging/collaborative framing — soften any ask, affirm the reader if the message carries
   criticism or many asks.
2. Tighten for energy — cut hedging, make the next action explicit, shorten sentences.
3. Add humor only where it lands naturally; nothing fits → skip it. Never joke in an incident update or a hard
   "this won't work" (encouraging ≠ flippant).
4. Place at most one or two intent-carrying emoji; pick Slack shortcodes vs Unicode per the target channel.
5. Match the casual register to the channel.

## Step 3: Pre-send check

Verify before returning / sending:

- Reads like the user wrote it — survives a "did a bot write this?" sniff test.
- No banned-register tokens (grep your own draft for "circle back", "kindly", "Acknowledged", "good catch",
  hedge stacks).
- Emoji count ≤ 2 and each carries meaning.
- Criticism, if any, is paired with an affirming line and aimed at the work.
- Length fits the channel — no monologue in a chat reply.
- **Accuracy and safety are untouched** — never soften a real warning into vagueness (tone-washing a security
  or data-loss caveat is a correctness bug), never change a technical fact, and never add a joke to a
  security-sensitive or irreversible-action message.

## Step 4: Hand back

Return the rewritten message ready to send. Invoked mid-flow by another skill → the rewritten text replaces the
draft in that skill's send step.

Requires a draft message or message context, plus the target channel (Slack vs GitHub vs email) to pick emoji
style.

## Post-Completion

Invoke `wk-learn tone`.
