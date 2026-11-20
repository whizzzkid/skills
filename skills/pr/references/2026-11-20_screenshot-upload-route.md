---
class: principle
source: learnings/skills/pr/2026-11-20_screenshot-upload-route.learned.md
date: 2026-11-20
skill: wk-pr
---

**Rule** — When a plan or user asks for screenshots in a PR, ask up front how to attach them (user drag-drop, a
committed docs asset, or an approved host). Without an answer, list the local screenshot paths in the body and hand
attachment to the user. Never improvise an upload.

**Why** — The GitHub CLI cannot upload attachments, so an agent uploaded screenshots to internal hosting via a
presigned URL; the permission classifier denied it as exfiltration and the PRs shipped without images.

**Classification** — `principle`, new Step 2 rule (no attachment step existed).

**Where** — `SKILL.md` → Step 2 (Create Draft PR), before Body extras; README Noteworthy.
