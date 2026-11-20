---
skill: wk-pr
date: 2026-11-20
type: gap
severity: low
verified-against-source: n/a
---

Screenshot attachment for PR descriptions has no sanctioned route, and the ad-hoc upload was blocked.

**What happened:** The plan asked for screenshots in the PR description. The agent tried to upload them to internal
HTML hosting via a presigned URL, and the permission classifier denied it as exfiltration. The PRs shipped without
images.

**Root cause:** The skill has no step for attaching images. The GitHub CLI can't upload attachments, so agents
improvise an upload.

**Suggested fix:** When a plan asks for screenshots, ask the user at plan time how to attach them (drag-drop by the
user, a committed docs asset, or an approved host). Otherwise list the local screenshot paths in the PR body and hand
the attachment off to the user.
