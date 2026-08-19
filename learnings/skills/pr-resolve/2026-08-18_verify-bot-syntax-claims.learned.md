---
skill: wk-pr-resolve
date: 2026-08-18
type: correction
severity: high
verified-against-source: yes
---

Verify bot syntax/language claims against framework documentation before accepting

**What happened:** A bot reviewer flagged TypeScript syntax (generics like `querySelectorAll<HTMLAnchorElement>`, non-null assertion `!`) in an Astro `<script>` block as invalid. The agent accepted the claim and rewrote the script as `is:inline` with plain JS, which was wrong — Astro's bundler processes non-`is:inline` `<script>` blocks and fully supports TypeScript syntax. The user corrected this.

**Root cause:** The agent treated the bot's syntax finding as authoritative without verifying against Astro's documentation. Astro has two script modes: (1) module scripts (default) processed by the bundler, supporting TypeScript; (2) `is:inline` scripts bypassing the bundler, requiring plain browser JS. The bot's analysis didn't distinguish between these modes.

**Suggested fix:** Add a Step 4 sub-rule: "When a bot flags syntax as invalid in a framework-managed file (Astro, Svelte, Vue SFC, etc.), verify the claim against the framework's compilation/bundling pipeline before accepting. Framework-processed blocks often support syntax the bot's static analysis doesn't account for. Drive the finding by checking whether the build succeeds with the flagged syntax."
