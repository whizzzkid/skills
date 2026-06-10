---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: medium
---

Source-comment URL claims should be verified against the repo's actual access mechanism.

**What happened:** A script's top-of-file comment advertised a public CDN URL pattern (`https://dl.{service}.io/public/...`) as the stable download path. The actual deployment was a private repo requiring authenticated CLI lookup of a different CDN URL. README already documented the correct mechanism; the source comment was never updated. A bot reviewer flagged the inconsistency between the comment and README.

**Root cause:** The adversarial sweep checks for stale inline comments about code logic but does not cross-reference URL claims in source comments against the documented access mechanism in README/docs.

**Suggested fix:** When a script's top-of-file comment contains a URL (especially a download or API URL), grep README and docs for the same hostname/path pattern and verify they agree:
```bash
grep -rn 'https://' scripts/ .buildkite/ | grep -o 'https://[^"' ]*' | sort -u
```
If the source comment URL differs from what README instructs users to do, flag it as a cross-doc inconsistency. Private repos are especially prone to this: the public-URL comment pattern is copied from examples but the actual download requires auth.
