---
skill: wk-pr-review
date: 2026-07-15
type: correction
severity: medium
---

Posted the pending review but never opened its html_url in the browser; the user had to point out "you forgot to open the review for me."

**What happened:** Phase 5 requires capturing `html_url` from the POST response and running the platform `open`/`xdg-open` alongside printing the URL. The review was created and the URL printed, but the `open` command was never run — and after recreating the review to add comments, it was again not opened.

**Root cause:** The open-in-browser step was dropped when the create-review call's jq parse errored and attention shifted to verifying the review landed; the follow-up recreation flow also omitted it.

**Suggested fix:** Treat "open the html_url" as a non-optional final action of Phase 5 that runs on every review create/recreate, independent of whether response parsing succeeded — verify the review via a separate query, but always fire `open`.
