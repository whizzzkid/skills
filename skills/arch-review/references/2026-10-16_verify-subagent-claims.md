---
class: principle
---

# A research summary is a lead, not a source

**Rule** — before a draft or findings report is complete, open the primary source behind every claim that the
recommendation or a security/compliance conclusion depends on. A contradicted or overstated claim is corrected; an
unread source marks the claim Unverified.

**Why** — a spec repeated a research summary that called one control a substitute for another and labelled a vendor
feature with a maturity it did not have. Both contradicted the cited sources and surfaced only at the independent
adversarial review. The summary linked its source, so the doc looked cited; nobody re-read the source while composing.
Summaries drop qualifiers, and security properties live in the qualifiers. Waiting for the merge gate turns a
draft-time read into a late rewrite.

**Where** — `SKILL.md` → Step 2 (Gather Context) HARD RULE; applies to both REVIEW and WRITE mode.
