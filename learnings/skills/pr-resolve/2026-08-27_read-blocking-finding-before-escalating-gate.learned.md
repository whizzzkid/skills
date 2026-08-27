---
skill: wk-pr-resolve
date: 2026-08-27
type: correction
severity: high
verified-against-source: yes
---

A bot review left a PR at REVIEW_REQUIRED; the agent escalated the gate to the user as a wait/dismiss/override decision instead of reading the bot's blocking finding and fixing it.

**What happened:** The {bot} review sat as COMMENTED (not APPROVED), leaving the PR BLOCKED. The agent diagnosed the gate mechanics (sticky COMMENTED review, re-trigger timeouts) and presented the user three options — wait for infra, dismiss the review, or admin-override merge — treating "unblock the review gate" as a decision only the user could make. The user corrected: "you should've done this on your own." The bot had in fact posted a **Major blocking finding** ("default table sort orders by a removed column") with a concrete fix; reading it and fixing it (change the default sort) flipped the bot to APPROVED automatically.

**Root cause:** The agent treated a `COMMENTED`/`REVIEW_REQUIRED` bot review as a gate-state problem to route around, without first reading the bot's finding body. A bot that auto-approves-on-fix will keep the PR blocked precisely because there is an unaddressed finding — the review state IS the finding, not an independent infra gate.

**Suggested fix:** When a bot review holds a PR at REVIEW_REQUIRED, ALWAYS fetch and read the bot's finding bodies (including "findings outside diff" posted as issue/summary comments, not just inline threads) BEFORE considering any gate-level action. A blocking finding with a concrete fix is an obvious-fix to implement, not a decision to escalate. Only escalate the gate itself (dismiss/override/wait) after confirming there is no addressable finding — an auto-approve-on-fix bot flips to APPROVED once the finding lands.
