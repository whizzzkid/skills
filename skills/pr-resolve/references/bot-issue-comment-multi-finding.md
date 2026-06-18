---
class: principle
---

**Rule:** When one bot issue comment bundles multiple distinct findings, split them into one suggestion each at triage (Step 4), but recombine all accepted findings from that comment into a single reply at Step 8.

**Why:** You cannot reply to sub-sections of an issue comment — each `issues/{n}/comments` entry has one ID. Splitting at triage keeps decisions per-finding; recombining at reply avoids double-posting.

**Where:** Step 4 (split) and Step 8 (combined reply).
